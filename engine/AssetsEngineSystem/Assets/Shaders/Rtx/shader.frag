#version 460 core
const float SHIFT = 0.001;
layout(location = 0) out vec4 OutColor;
in vec2 uv; // -1.0 to 1.0
uint pixelIndex;
uint rngState;

struct Material {
	vec3 density;
	vec4 diffuse_color;
	vec4 specular_color;
	vec3 emmision;
	vec3 smoothness;
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

struct BVH {
	int next_left_bvh;
	int next_right_bvh;
	int start_index;
	int stop_index;
	vec3 volumeA;
	vec3 volumeB;};
layout(std430, binding = 44) buffer BoundingVolumeHierarchy {BVH boundings[];};

struct ProceduralMesh {
	int material_index;
	int bvh_index;
	int bvh_depth;
	int alignment_triangle_index;
	int transform_index;};
layout(std430, binding = 45) buffer ProceduralMeshes {ProceduralMesh procedurals_meshes[];};
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


struct Ray{
	vec3 ro;
	vec3 rd;
	float ior_stack[20];
	int ior_depth;
};

struct IntersectInfo{
	bool is_intersect;
	bool is_inside;
	float distance;
	vec3 position;
	vec3 normal;
};

IntersectInfo NONE_INTERSECT = IntersectInfo(
	false,
	false,
	-1.0,
	vec3(0),
	vec3(0)
);

struct Intersect{
	bool is_intersect;
	Ray inter_ray;
	IntersectInfo intersect_info;
	Material material;
};



IntersectInfo elipsIntersection(in vec3 rro, in vec3 rrd, in mat4 srt_transform) {
    mat4 invTransform = inverse(srt_transform);
    
    // Локальные координаты луча
    vec3 ro_local = (invTransform * vec4(rro, 1.0)).xyz;
    vec3 rd_local = (invTransform * vec4(rrd, 0.0)).xyz;
    float rd_len = length(rd_local);
    if(rd_len == 0.0) return NONE_INTERSECT;
    rd_local /= rd_len;

    // Оптимизированное квадратное уравнение
    float b = dot(ro_local, rd_local);
    float c = dot(ro_local, ro_local) - 1.0;
    float discriminant = b*b - c;
    
    if(discriminant < 0.0) return NONE_INTERSECT;
    
    // Вычисление корней
    float sqrt_disc = sqrt(discriminant);
    float t1 = -b - sqrt_disc;
    float t2 = -b + sqrt_disc;
	bool is_inside = t1 > 0.0;
    float t = is_inside ? t1 : (t2 > 0.0 ? t2 : -1.0);
    
    if(t < 0.0) return NONE_INTERSECT;

    // Оптимизированные вычисления мировых координат
    float t_world = (t / rd_len);
    vec3 world_hit = rro + rrd * t_world;
    
    // Быстрое вычисление нормали
    vec3 local_normal = ro_local + rd_local * t;
    mat3 normal_mat = transpose(mat3(invTransform));
    vec3 world_normal = normalize(normal_mat * local_normal);

    return IntersectInfo(
        true,
		!is_inside,
        t_world,
        world_hit,
        world_normal * (is_inside?1.0:-1.0)
    );
}


IntersectInfo boxIntersection(in vec3 rro, in vec3 rrd, in mat4 srt_transform) {

	mat3 ModelRot = mat3(
		normalize(srt_transform[0].xyz),
		normalize(srt_transform[1].xyz),
		normalize(srt_transform[2].xyz)
	);

	vec3 boxSize = inverse(ModelRot)*mat3(
		srt_transform[0].xyz,
		srt_transform[1].xyz,
		srt_transform[2].xyz
	)*vec3(1.0);


	vec3 boxPos = srt_transform[3].xyz;

	vec3 ro = (ModelRot*(rro-boxPos));
	vec3 rd = (ModelRot*rrd);


    vec3 m = 1.0/(rd); // can precompute if traversing a set of aligned boxes
    vec3 n = m*ro;   // can precompute if traversing a set of aligned boxes
    vec3 k = abs(m)*boxSize;

    vec3 t1 = -n - k;
    vec3 t2 = -n + k;

    float tN = max( max( t1.x, t1.y ), t1.z );
    float tF = min( min( t2.x, t2.y ), t2.z );

    if( tN>tF || tF<0.0) return NONE_INTERSECT;


	vec3 hitpos;
	vec3 hitnor;
	float dist;
	bool is_inside = !(tN>0.0);
    if(!is_inside){
		hitnor = step(vec3(tN),t1);
		dist = tN;
		hitpos = rro+rrd*dist;
	} // ro ouside the box
    else{
		hitnor = step(t2,vec3(tF));
		dist = tF;
		hitpos = rro+rrd*dist;
	}  // ro inside the box
    hitnor *= -sign(rd);

	hitnor = hitnor*ModelRot;



	return IntersectInfo(
		true,
		is_inside,
		dist,
		hitpos,
		hitnor
	);
}


float intersection_count = 0;
IntersectInfo triangleIntersection(in vec3 rro, in vec3 rrd, in int triangle_id) {

	vec3 v0 = triangles[triangle_id].posA;
	vec3 v1 = triangles[triangle_id].posB;
	vec3 v2 = triangles[triangle_id].posC;

	vec3 v1v0 = v1 - v0;
	vec3 v2v0 = v2 - v0;
	vec3 rov0 = rro - v0;

	vec3  n = cross( v1v0, v2v0 );

    float denom = dot(rrd, n);
    // Проверка на параллельность луча и плоскости
    if (abs(denom) < SHIFT) return NONE_INTERSECT;

	vec3  q = cross( rov0, rrd );
	float d = 1.0/dot( rrd, n );
	float u = d*dot( -q, v2v0 );
	float v = d*dot(  q, v1v0 );
	float t = d*dot( -n, rov0 );

	if( u<0.0 || v<0.0 || (u+v)>1.0 || t <= 0.0) return NONE_INTERSECT;

    vec3 normal = normalize(n);
    bool is_inside = (denom > 0.0);
    if (is_inside) {
        normal = -normal; // Инвертируем нормаль, если луч внутри
    }

	intersection_count++;
	return IntersectInfo(
		true,
		false,
		t,
		rro+(rrd*t),
		normal
	);
}

float intersectRayCubeFull(vec3 rayOrigin, vec3 rayDirection, vec3 cubeMin, vec3 cubeMax){
    vec3 invDir = 1.0 / rayDirection;
    vec3 tMin = (cubeMin - rayOrigin) * invDir;
    vec3 tMax = (cubeMax - rayOrigin) * invDir;

    vec3 t1 = min(tMin, tMax);
    vec3 t2 = max(tMin, tMax);
    float tN = max( max( t1.x, t1.y ), t1.z );
    float tF = min( min( t2.x, t2.y ), t2.z );
    if( tN>tF || tF<0.0) return -1.0; // no intersection

	intersection_count++;
	if(tN>0.0){
		return tN; //out
	}
	else return 0.0; //in
}

Intersect GetCloserProceduralIntersect(in Ray ray) {

	Intersect output_intersect = Intersect(
		false,
		ray,
		NONE_INTERSECT,
		materials[0]
	);
	vec3 ro = ray.ro;
	vec3 rd = ray.rd;

	Transform transform_procedural;
	Material material_procedural;
	IntersectInfo intersect_info;

	Procedural procedural;
	//for(int i = 0; i < PROCEDURALS_COUNT; i++) {
	for(int i = 0; i < 0; i++) {
		procedural = procedurals[i];
		transform_procedural = transforms[procedural.transform_index];
		material_procedural = materials[int(procedural.material_index)];

		if(procedural.object_type == 0.0)
			intersect_info = elipsIntersection(ro, rd, transform_procedural.srt_transform);
		else if(procedural.object_type == 1.0)
			intersect_info = boxIntersection(ro, rd, transform_procedural.srt_transform);
		
		if(!intersect_info.is_intersect) continue;

		if(!output_intersect.is_intersect || intersect_info.distance < output_intersect.intersect_info.distance){
			output_intersect.is_intersect = true;
			output_intersect.intersect_info = intersect_info;
			output_intersect.material = material_procedural;
		}
	};

	ProceduralMesh mesh;
	for(int i = 0; i < PROCEDURALS_MESHES_COUNT; i++) {
		mesh = procedurals_meshes[0];
		if(mesh.bvh_index<0) continue;
		transform_procedural = transforms[mesh.transform_index];
		mat4 inv_transform = inverse(transform_procedural.srt_transform);
		ro = (inv_transform * vec4(ray.ro,1)).xyz;
		rd = (inv_transform * vec4(ray.rd,0)).xyz;
		material_procedural = materials[int(mesh.material_index)];

		BVH bvh = boundings[mesh.bvh_index];
		int bvh_alternative[32];
		int bvh_alternative_shift = -1;
		BVH bvh_left;
		BVH bvh_right;

		bool has_intersection = false;

		float bound_volume = intersectRayCubeFull(ro,rd, bvh.volumeA, bvh.volumeB);
		float bound_volume_left;
		float bound_volume_right;
		if(bound_volume < 0.0) continue;

		for(int j = 0; j < mesh.bvh_depth; j++) {

			if(bvh.start_index>=0){
				for(int k = bvh.start_index; k < bvh.stop_index; k++) {
					intersect_info = triangleIntersection(ro, rd, k);
					if(!intersect_info.is_intersect) continue;
					if(!output_intersect.is_intersect || intersect_info.distance < output_intersect.intersect_info.distance){
						output_intersect.is_intersect = true;
						output_intersect.intersect_info = intersect_info;
						output_intersect.material = material_procedural;
						has_intersection = true;
					}
				}
				if(has_intersection) break;
				if(bvh_alternative_shift<0) break;
				bvh = boundings[bvh_alternative[bvh_alternative_shift]];
				bvh_alternative_shift--;
			}
			else{
				if(bvh.next_left_bvh >= 0){
					bvh_left = boundings[bvh.next_left_bvh];
					bound_volume_left = intersectRayCubeFull(ro,rd, bvh_left.volumeA, bvh_left.volumeB);
				}
				else bound_volume_left = -1.0;
				
				if(bvh.next_left_bvh >= 0){
					bvh_right = boundings[bvh.next_right_bvh];
					bound_volume_right = intersectRayCubeFull(ro,rd, bvh_right.volumeA, bvh_right.volumeB);
				}
				else bound_volume_right = -1.0;

				if(bound_volume_left >= 0.0 && bound_volume_right >= 0.0){
					bvh_alternative_shift++;
					if(bound_volume_left<bound_volume_right){
						bvh_alternative[bvh_alternative_shift] = bvh.next_right_bvh;
						bvh = bvh_left;
					}
					else{
						bvh_alternative[bvh_alternative_shift] = bvh.next_left_bvh;
						bvh = bvh_right;
					}
					continue;
				}
				if(bound_volume_left >= 0.0){
					bvh = bvh_left;
					continue;
				}
				if(bound_volume_right >= 0.0){
					bvh = bvh_right;
					continue;
				}
				if(bvh_alternative_shift<0) break;
				bvh = boundings[bvh_alternative[bvh_alternative_shift]];
				bvh_alternative_shift--;
			}
			
		}

	}


	return output_intersect;
};













void Transperent(inout Ray ray, in Intersect closer, in vec4 color){

	float n2 = closer.material.density.x;
	float n1 = ray.ior_stack[ray.ior_depth];
	float a = (-dot(ray.rd, closer.intersect_info.normal));

	float i1 = acos(a);
	float i2 = asin((n1 / n2) * sin(i1));

	float Fresnel = pow(
		(n1 * cos(i1) - n2 * cos(i2)) 
		/ 
		(n1 * cos(i1) + n2 * cos(i2)), 
	2);

	if(RandomNormal() < ( (color.a + Fresnel) - (0.06*n2 - 0.06) )){ // is reflect
		ray.ro = closer.intersect_info.position + (closer.intersect_info.normal * SHIFT);
		ray.rd = normalize(
			mix(
				closer.intersect_info.normal + RandomShpereDirection(), 
				reflect(ray.rd,closer.intersect_info.normal), 
				closer.material.smoothness.z<RandomNormal()?closer.material.smoothness.x:closer.material.smoothness.y
			)
		);
	}
	else{ // is refract
		if(closer.intersect_info.is_inside){
			ray.ior_stack[ray.ior_depth] = 1.0;
			ray.ior_depth -= 1;
		}
		else{
			ray.ior_depth += 1;
			ray.ior_stack[ray.ior_depth] = n2;
		}

		ray.ro = closer.intersect_info.position - (closer.intersect_info.normal * SHIFT);
		ray.rd = normalize(
			mix(
				closer.intersect_info.normal - RandomShpereDirection(), 
				refract(ray.rd, closer.intersect_info.normal, 1.0-pow((n1-n2)/(n1+n2),2.0)), //ray.ior_stack[ray.ior_depth-1]/ray.ior_stack[ray.ior_depth]
				closer.material.smoothness.z<RandomNormal()?closer.material.smoothness.x:closer.material.smoothness.y
			)
		);
	}
}

void NotTransperent(inout Ray ray, Intersect closer){
	ray.ro = closer.intersect_info.position + (closer.intersect_info.normal * SHIFT);
	ray.rd = normalize(
		mix(
			closer.intersect_info.normal + RandomShpereDirection(), 
			reflect(ray.rd,closer.intersect_info.normal), 
			closer.material.smoothness.z<RandomNormal()?closer.material.smoothness.x:closer.material.smoothness.y
		)
	);
}


vec3 render(in Ray ray, in int max_bounce_count) {
	vec3 final_color = vec3(0);
	vec3 ray_color = vec3(1);

	Intersect closer = GetCloserProceduralIntersect(ray);
	if(closer.intersect_info.is_inside){
		ray.ior_depth += 1;
		ray.ior_stack[ray.ior_depth] = closer.material.density.x;
	}
	//pixelIndex += hash3D(closer.intersect_info.position);
	//final_color = closer.intersect_info.normal;
	//final_color.x = (intersection_count/20) * (closer.intersect_info.distance/10);
	final_color.x = (intersection_count/30);
	return final_color;

	for(int i = 0; i < max_bounce_count; i++) {
		if(closer.is_intersect){
			
			bool probability = closer.material.smoothness.z<RandomNormal();
			vec4 color = probability?
					closer.material.diffuse_color
					:
					closer.material.specular_color;

			if(color.a<RandomNormal()) Transperent(ray, closer, color);
			else NotTransperent(ray, closer);

			final_color += closer.material.emmision * ray_color;
			ray_color *= color.xyz;
			if(length(ray_color) <= 0) break;
		}
		else break;
		closer = GetCloserProceduralIntersect(ray);
	}

	return final_color;
}


uniform int FRAME_ID;
layout (binding = 0, rgba8) uniform image2D MainTexture;
vec3 denoise(){
	vec3 mixed_color = imageLoad(MainTexture, ivec2(gl_FragCoord.xy)).xyz;

	int iterations = 1000;
    float radius = 100.0;
    vec2 texelSize = radius / gl_FragCoord.yx;

    float weightSum = 1.0;

	ivec2 offset;
	for(int i = 0; i < iterations; i++) {
		offset = ivec2(gl_FragCoord.xy + (Random2DCircle()*texelSize));
		if (offset.x < 0 || offset.x >= gl_FragCoord.x || offset.y < 0 || offset.y >= gl_FragCoord.y) continue;
		mixed_color += imageLoad(MainTexture, offset).xyz;
		weightSum += 1;
	}

	return mixed_color / weightSum;
}
void main() {
	ivec2 numPixels = ivec2(20000,20000);
	ivec2 pixelCoord = ivec2(numPixels.x*uv.x,numPixels.y*uv.y);
	pixelIndex = (pixelCoord.y * numPixels.x + pixelCoord.x);
	rngState = pixelIndex + FRAME_ID * 719393;

	vec3 final_color = vec3(0);

	for(int i = 0; i < CAMERAS_COUNT; i++) {
		Camera camera = cameras[i];
		Transform transform_camera = transforms[camera.transform_index];

		vec4 ray_eye = vec4( ( inverse(camera.projection) * vec4(uv, 1.0, 1.0) ).xy , 1.0, 0.0); // Преобразуем в направление
		vec4 ray_world = transform_camera.trs_transform * ray_eye;
		vec3 rd = normalize(ray_world.xyz);

		float far_lane_camera = camera.projection[3][2] / (camera.projection[2][2] + 1.0);

		Ray ray = Ray(
			transform_camera.srt_transform[3].xyz,
			rd,
			float[20](1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1),
			10
		);


		vec3 render_color = vec3(0);
		for(int i = 0; i < camera.num_samples; i++) {
			render_color += render(ray, camera.max_bounce_count);
		}
		render_color /= float(camera.num_samples);

		final_color += render_color * camera.iso;
	}
	final_color /= CAMERAS_COUNT;
	float weight = 1.0 / float(FRAME_ID+1);

	vec3 out_color = imageLoad(MainTexture, ivec2(gl_FragCoord.xy)).xyz;
	//vec3 out_color = denoise();

	final_color = (out_color * (1.0-weight)) + (final_color * weight);
	OutColor = vec4(final_color, 1.0);
}