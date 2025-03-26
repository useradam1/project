#version 460 core
const float SHIFT = 0.001;
layout(location = 0) out vec4 OutColor;
in vec2 uv; // -1.0 to 1.0
uint pixelIndex;
uint rngState;

struct Material {
	vec4 diffuse_color;
	vec4 specular_color;
	vec3 emmision;
	vec3 smoothness;
	vec3 density;
};
layout(std430, binding = 5) buffer Materials { Material materials[]; };

struct Transform {
	mat4 srt_transform;
	mat4 trs_transform;};
layout(std430, binding = 40) buffer Transforms {Transform transforms[];};

struct Camera {
	mat4 projection;
	int transform_index;
	int max_bounce_count;
	int num_samples;
	float iso;};
layout(std430, binding = 41) buffer Cameras {Camera cameras[];};
uniform int CAMERAS_COUNT;

struct Procedural {
	int material_index;
	int object_type;
	int transform_index;
	int padding;};
layout(std430, binding = 42) buffer Procedurals {Procedural procedurals[];};
uniform int PROCEDURALS_COUNT;


struct Triangle {
	vec3 posA;
	vec3 posB;
	vec3 posC;
	vec3 normalA;
	vec3 normalB;
	vec3 normalC;
	vec3 uvA;
	vec3 uvB;
	vec3 uvC;};
layout(std430, binding = 43) buffer Triangles {Triangle triangles[];};
layout(std430, binding = 44) buffer Triangles_indexes {vec2 triangles_indexes[];};

struct BVH {
	int next_left_bvh;
	int next_right_bvh;
	int start_index;
	int stop_index;
	vec3 volumeA;
	vec3 volumeB;};
layout(std430, binding = 45) buffer BoundingVolumeHierarchy {BVH boundings[];};

struct ProceduralMesh {
	int material_index;
	int bvh_index;
	int alignment_triangle_index;
	int transform_index;};
layout(std430, binding = 46) buffer ProceduralMeshes {ProceduralMesh procedurals_meshes[];};
uniform int PROCEDURALS_MESHES_COUNT;


float RandomNormal(){
	rngState = rngState * 747796405 + 2891336453;
	uint result = ((rngState >> ((rngState >> 28) + 4)) ^ rngState) * 277803737;
	result = (result >> 22) ^ result;
	return result / 4294967295.0;
}
float Random(){
	return (RandomNormal()-0.5)*2.0;
}
#define PI 3.14159265359
vec2 Random2DCircle(){
	float t = Random() * PI;
	return vec2(sin(t),cos(t)) * sqrt(RandomNormal());
}
float RandomNormalDistribution(){
	float theta = 2 * 3.1415926 * RandomNormal();
	float rho = sqrt(-2.0 * log(RandomNormal()));
	return rho * cos(theta);
}
vec3 RandomShpereDirection(){
	return normalize(vec3(RandomNormalDistribution(),RandomNormalDistribution(),RandomNormalDistribution()));
}
vec3 RandomHemisphereDirection(vec3 normal){
	vec3 dir = normalize(vec3(RandomNormalDistribution(),RandomNormalDistribution(),RandomNormalDistribution()));
	if(dot(normal, dir)<0.0) dir *= -1.0;
	return dir;
}

Camera global_camera;
Transform global_transform_camera;

struct Ray{
	vec3 ro;
	vec3 rd;
	float ior_stack[20];
	int ior_depth;
};
Ray global_ray;
vec3 global_inv_ray_direction;
vec3 ro;
vec3 rd;

struct IntersectInfo{
	bool is_inside;
	float distance;
	vec3 position;
	vec3 normal;
};

struct Intersect{
	bool is_intersect;
	IntersectInfo intersect_info;
	Material material;
};
Material void_material = Material(
	vec4(0),
	vec4(0),
	vec3(0),
	vec3(0),
	vec3(0)
);
Intersect closer_intersect = Intersect(
	false,
	IntersectInfo(
		false,
		-1.0,
		vec3(0),
		vec3(0)
	),
	void_material
);
Procedural procedural;
mat4 procedural_srt_transform;
mat4 procedural_inv_srt_transform;
mat3 procedural_mat_rotation;



void elipsIntersection(){
	// Локальные координаты луча
	vec3 ro_local = (procedural_inv_srt_transform * vec4(global_ray.ro, 1.0)).xyz;
	vec3 rd_local = (procedural_inv_srt_transform * vec4(global_ray.rd, 0.0)).xyz;
	float rd_len = length(rd_local);
	if(rd_len == 0.0) return;

	// Оптимизированное квадратное уравнение
	rd_local /= rd_len;
	float b = dot(ro_local, rd_local);
	float c = dot(ro_local, ro_local) - 1.0;
	float discriminant = b*b - c;
	if(discriminant < 0.0) return;

	// Вычисление корней
	float sqrt_disc = sqrt(discriminant);
	float t1 = -b - sqrt_disc;
	float t2 = -b + sqrt_disc;
	bool is_inside = t1 < 0.0;
	float t = is_inside ? (t2 > 0.0 ? t2 : -1.0) : t1;

	if(t < 0.0) return;

    // Оптимизированные вычисления мировых координат
    float t_world = (t / rd_len);

	if(
		closer_intersect.intersect_info.distance > 0 &&
		t_world > closer_intersect.intersect_info.distance
	) return;

    vec3 world_hit = global_ray.ro + global_ray.rd * t_world;
    
    // Быстрое вычисление нормали
    vec3 world_normal = normalize(
		transpose(mat3(procedural_inv_srt_transform)) * (ro_local + rd_local * t));

	closer_intersect.is_intersect = true;
	closer_intersect.intersect_info.is_inside = is_inside;
	closer_intersect.intersect_info.distance = t_world;
	closer_intersect.intersect_info.position = world_hit;
	closer_intersect.intersect_info.normal = world_normal * (is_inside?-1.0:1.0);
	closer_intersect.material = materials[procedural.material_index];
}

void boxIntersection(){
	vec3 boxSize = vec3(
		length(procedural_srt_transform[0].xyz),
		length(procedural_srt_transform[1].xyz),
		length(procedural_srt_transform[2].xyz)
	);
	vec3 boxPos = procedural_srt_transform[3].xyz;
	vec3 ro = (procedural_mat_rotation*(global_ray.ro-boxPos));
	vec3 rd = (procedural_mat_rotation*global_ray.rd);


    vec3 n = global_inv_ray_direction*ro;   // can precompute if traversing a set of aligned boxes
    vec3 k = abs(global_inv_ray_direction)*boxSize;

    vec3 t1 = -n - k;
    vec3 t2 = -n + k;

    float tN = max( max( t1.x, t1.y ), t1.z );
    float tF = min( min( t2.x, t2.y ), t2.z );

    if( tN>tF || tF<0.0) return;

	bool is_inside = (tN<0.0);
	float dist = is_inside?tF:tN;

	if(
		closer_intersect.intersect_info.distance > 0 &&
		dist > closer_intersect.intersect_info.distance
	) return;

	vec3 hitpos = global_ray.ro+global_ray.rd*dist;
	vec3 hitnor;
    if(is_inside){
		hitnor = step(t2,vec3(tF));
	}  // ro ouside the box
    else{
		hitnor = step(vec3(tN),t1);
	}  // ro inside the box
    hitnor *= -sign(rd);

	closer_intersect.is_intersect = true;
	closer_intersect.intersect_info.is_inside = is_inside;
	closer_intersect.intersect_info.distance = dist;
	closer_intersect.intersect_info.position = hitpos;
	closer_intersect.intersect_info.normal = hitnor*procedural_mat_rotation;
	closer_intersect.material = materials[procedural.material_index];
}



ProceduralMesh mesh;
BVH bvh;
int bvh_alternative[32];
int bvh_alternative_shift;
BVH left;
BVH right;
vec2 dist_test = vec2(0);

bool has_intersection_triangle;
void triangleIntersection(in int triangle_id) {

	vec3 v0 = triangles[triangle_id].posA;
	vec3 v1 = triangles[triangle_id].posB;
	vec3 v2 = triangles[triangle_id].posC;

	vec3 v1v0 = v1 - v0;
	vec3 v2v0 = v2 - v0;
	vec3 rov0 = global_ray.ro - v0;

	vec3  n = cross( v1v0, v2v0 );

    float denom = dot(global_ray.rd, n);
    // Проверка на параллельность луча и плоскости
    if (abs(denom) < 1e-6) return;

	vec3  q = cross( rov0, global_ray.rd );
	float d = 1.0/dot( global_ray.rd, n );
	float u = d*dot( -q, v2v0 );
	float v = d*dot(  q, v1v0 );
	float t = d*dot( -n, rov0 );

	if( u<0.0 || v<0.0 || (u+v)>1.0 || t <= 0.0) return;
	
	if(
		closer_intersect.intersect_info.distance > 0 &&
		t > closer_intersect.intersect_info.distance
	) return;

    vec3 normal = normalize(n);
    bool is_inside = (denom > 0.0);
    if (is_inside) {
        normal = -normal; // Инвертируем нормаль, если луч внутри
    }

	closer_intersect.is_intersect = true;
	closer_intersect.intersect_info.is_inside = is_inside;
	closer_intersect.intersect_info.distance = t;
	closer_intersect.intersect_info.position = global_ray.ro+(global_ray.rd*t);
	closer_intersect.intersect_info.normal = normal;
	closer_intersect.material = materials[mesh.material_index];

	has_intersection_triangle = true;
}

float intersectRayCubeFull(vec3 cubeMin, vec3 cubeMax){
    vec3 tMin = (cubeMin - global_ray.ro) * global_inv_ray_direction;
    vec3 tMax = (cubeMax - global_ray.ro) * global_inv_ray_direction;

    vec3 t1 = min(tMin, tMax);
    vec3 t2 = max(tMin, tMax);
    float tF = min( min( t2.x, t2.y ), t2.z );
    float tN = max( max( t1.x, t1.y ), t1.z );

    if( tN>tF || tF<0.0) return -1.0; // no intersection

	if(tN>0.0) return tN; //out
	else return 0.0; //in
}

float intersection_count_triangle = 0;
float intersection_count_box = 0;
void UpdateCloserIntersect(){
	closer_intersect.is_intersect = false;
	closer_intersect.intersect_info.is_inside = false;
	closer_intersect.intersect_info.distance = -1.0;
	closer_intersect.material = void_material;

	global_inv_ray_direction = 1.0/global_ray.rd;

	for(int i = 0; i < PROCEDURALS_COUNT; i++) {
		procedural = procedurals[i];
		procedural_srt_transform = transforms[procedural.transform_index].srt_transform;
		procedural_inv_srt_transform = inverse(procedural_srt_transform);
		procedural_mat_rotation = mat3(
			procedural_srt_transform[0].xyz * inversesqrt(dot(procedural_srt_transform[0].xyz,procedural_srt_transform[0].xyz)),
			procedural_srt_transform[1].xyz * inversesqrt(dot(procedural_srt_transform[1].xyz,procedural_srt_transform[1].xyz)),
			procedural_srt_transform[2].xyz * inversesqrt(dot(procedural_srt_transform[2].xyz,procedural_srt_transform[2].xyz))
		);

		if(procedural.object_type == 0.0)
			elipsIntersection();
		if(procedural.object_type == 1.0)
			boxIntersection();
	}

	ro = global_ray.ro;
	rd = global_ray.rd;

	for(int i = 0; i < PROCEDURALS_MESHES_COUNT; i++) {
		mesh = procedurals_meshes[i];
		if(mesh.bvh_index<0) continue;
		procedural_srt_transform = transforms[mesh.transform_index].srt_transform;
		procedural_inv_srt_transform = inverse(procedural_srt_transform);
		global_ray.ro = (procedural_inv_srt_transform * vec4(ro,1)).xyz;
		global_ray.rd = (procedural_inv_srt_transform * vec4(rd,0)).xyz;
		global_inv_ray_direction = 1.0/global_ray.rd;

		bvh_alternative_shift = 0;
		bvh_alternative_shift++;
		bvh_alternative[bvh_alternative_shift] = mesh.bvh_index;

		has_intersection_triangle = false;

		while(bvh_alternative_shift>0) {

			bvh = boundings[bvh_alternative[bvh_alternative_shift]];
			bvh_alternative_shift--;

			
			if(bvh.start_index>=0){
				intersection_count_triangle+=bvh.stop_index-bvh.start_index;
				for(int k = bvh.start_index; k < bvh.stop_index; k++) {
					triangleIntersection(k);
				}
			}
			else{
				left = boundings[bvh.next_left_bvh];
				right = boundings[bvh.next_right_bvh];

				dist_test.x = intersectRayCubeFull(left.volumeA, left.volumeB);
				dist_test.y = intersectRayCubeFull(right.volumeA, right.volumeB);
				intersection_count_box += 2;

				bool isNearestLeft = dist_test.x<dist_test.y;
				float tN = isNearestLeft?dist_test.x:dist_test.y;
				float tF = isNearestLeft?dist_test.y:dist_test.x;

				if(
					tF>=0.0 && (closer_intersect.is_intersect?
					tF<closer_intersect.intersect_info.distance:true)
				){
					bvh_alternative_shift++;
					bvh_alternative[bvh_alternative_shift] = isNearestLeft?bvh.next_right_bvh:bvh.next_left_bvh;
				}
				if(
					tN>=0.0 && (closer_intersect.is_intersect?
					tN<closer_intersect.intersect_info.distance:true)
				){
					bvh_alternative_shift++;
					bvh_alternative[bvh_alternative_shift] = isNearestLeft?bvh.next_left_bvh:bvh.next_right_bvh;
				}
			}
			
		}

		if(has_intersection_triangle){
			closer_intersect.intersect_info.normal = normalize((procedural_srt_transform * vec4(closer_intersect.intersect_info.normal,0)).xyz);
			closer_intersect.intersect_info.position = (procedural_srt_transform * vec4(closer_intersect.intersect_info.position,1)).xyz;
		}
	}

	global_ray.ro = ro;
	global_ray.rd = rd;
}



void Transperent(in vec4 color){

	float n2 = closer_intersect.material.density.x;
	float n1 = global_ray.ior_stack[global_ray.ior_depth];
	float a = (-dot(global_ray.rd, closer_intersect.intersect_info.normal));

	float i1 = acos(a);
	float i2 = asin((n1 / n2) * sin(i1));

	// float Fresnel = pow(
	// 	(n1 * cos(i1) - n2 * cos(i2)) 
	// 	/ 
	// 	(n1 * cos(i1) + n2 * cos(i2)), 
	// 2);
	// Замена точного расчета на аппроксимацию Шлика
	float R0 = pow((n1-n2)/(n1+n2), 2.0);
	float Fresnel = R0 + (1.0 - R0)*pow(1.0 - a, 5.0);

	if(RandomNormal() < ( (color.a + Fresnel) - (0.04*n2 - 0.04) )){ // is reflect
		global_ray.ro = closer_intersect.intersect_info.position + (closer_intersect.intersect_info.normal * SHIFT);
		global_ray.rd = normalize(
			mix(
				closer_intersect.intersect_info.normal + RandomShpereDirection(), 
				reflect(global_ray.rd,closer_intersect.intersect_info.normal), 
				closer_intersect.material.smoothness.z<RandomNormal()?closer_intersect.material.smoothness.x:closer_intersect.material.smoothness.y
			)
		);
	}
	else{ // is refract
		if(closer_intersect.intersect_info.is_inside){
			global_ray.ior_stack[global_ray.ior_depth] = 1.0;
			global_ray.ior_depth -= 1;
		}
		else{
			global_ray.ior_depth += 1;
			global_ray.ior_stack[global_ray.ior_depth] = n2;
		}

		global_ray.ro = closer_intersect.intersect_info.position - (closer_intersect.intersect_info.normal * SHIFT);
		global_ray.rd = normalize(
			mix(
				closer_intersect.intersect_info.normal - RandomShpereDirection(), 
				refract(global_ray.rd, closer_intersect.intersect_info.normal, 1.0-pow((n1-n2)/(n1+n2),2.0)), //ray.ior_stack[ray.ior_depth-1]/ray.ior_stack[ray.ior_depth]
				closer_intersect.material.smoothness.z<RandomNormal()?closer_intersect.material.smoothness.x:closer_intersect.material.smoothness.y
			)
		);
	}
}

void NotTransperent(){
	global_ray.ro = closer_intersect.intersect_info.position + (closer_intersect.intersect_info.normal * SHIFT);
	global_ray.rd = normalize(
		mix(
			closer_intersect.intersect_info.normal + RandomShpereDirection(), 
			reflect(global_ray.rd,closer_intersect.intersect_info.normal), 
			closer_intersect.material.smoothness.z<RandomNormal()?closer_intersect.material.smoothness.x:closer_intersect.material.smoothness.y
		)
	);
}


uniform float TRIANGLE_HIT;
uniform float BOX_HIT;
vec3 RayDebugView(in int debug){
	vec3 fin_color = vec3(intersection_count_triangle/TRIANGLE_HIT, 0 , intersection_count_box/BOX_HIT);
	switch(debug){
		case 0:
			return closer_intersect.is_intersect?vec3(closer_intersect.intersect_info.normal*0.5+0.5):vec3(0);
		case 1:
			if(fin_color.r<1.0) fin_color = vec3(fin_color.r);
			else fin_color = vec3(1,0,0);
			return fin_color;
		case 2:
			if(fin_color.b<1.0) fin_color = vec3(fin_color.b);
			else fin_color = vec3(1,0,0);
			return fin_color;
		case 3:
			if(fin_color.r>1.0 && fin_color.b>1.0) fin_color = vec3(1);
			return fin_color;
		default:
			return vec3(1,0,1);
	}
}

vec3 render(){
	vec3 final_color = vec3(0);
	vec3 ray_color = vec3(1);

	UpdateCloserIntersect();
	//return RayDebugView(3);
	if(closer_intersect.intersect_info.is_inside){
		global_ray.ior_depth += 1;
		global_ray.ior_stack[global_ray.ior_depth] = closer_intersect.material.density.x;
	}


	vec4 color;
	bool probability;

	for(int i = 0; i < global_camera.max_bounce_count; i++) {
		if(closer_intersect.is_intersect){
			
			probability = closer_intersect.material.smoothness.z<RandomNormal();
			color = probability?
					closer_intersect.material.diffuse_color
					:
					closer_intersect.material.specular_color;

			if(color.a<RandomNormal()) Transperent(color);
			else NotTransperent();

			final_color += closer_intersect.material.emmision * ray_color;
			ray_color *= color.xyz;
			if(length(ray_color) <= 0) break;
		}
		else break;
		UpdateCloserIntersect();
	}

	return final_color;
}





uniform int FRAME_ID;
layout (binding = 0, rgba8) uniform image2D MainTexture;
void main() {
	ivec2 numPixels = ivec2(20000,20000);
	ivec2 pixelCoord = ivec2(numPixels.x*uv.x,numPixels.y*uv.y);
	pixelIndex = (pixelCoord.y * numPixels.x + pixelCoord.x);
	rngState = pixelIndex + FRAME_ID * 719393;

	global_ray = Ray(
		vec3(0),
		vec3(0),
			float[20](1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
			10
	);

	vec3 final_color = vec3(0);


	vec4 ray_eye;
	vec4 ray_world;
	vec3 rd;
	float far_lane_camera;
	vec3 render_color;

	for(int i = 0; i < CAMERAS_COUNT; i++) {

		global_camera = cameras[i];
		global_transform_camera = transforms[global_camera.transform_index];

		ray_eye = vec4( ( inverse(global_camera.projection) * vec4(uv, 1.0, 1.0) ).xy , 1.0, 0.0); // Преобразуем в направление
		ray_world = global_transform_camera.trs_transform * ray_eye;
		rd = normalize(ray_world.xyz);

		far_lane_camera = global_camera.projection[3][2] / (global_camera.projection[2][2] + 1.0);


		// rendering start
		render_color = vec3(0);
		for(int i = 0; i < global_camera.num_samples; i++) {

			global_ray.ro = global_transform_camera.srt_transform[3].xyz;
			global_ray.rd = rd;

			render_color += render();

		}
		render_color /= float(global_camera.num_samples);
		// rendering end


		final_color += render_color * global_camera.iso;
	}
	final_color /= CAMERAS_COUNT;

	vec3 buffer_color = imageLoad(MainTexture, ivec2(gl_FragCoord.xy)).xyz;

	float weight = 1.0 / float(FRAME_ID+1);

	final_color = (buffer_color * (1.0-weight)) + (final_color * weight);
	OutColor = vec4(final_color, 1.0);
}