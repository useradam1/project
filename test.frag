#version 460 core
const float SHIFT = 0.001;
const float SHIFTMIN = SHIFT*0.5;
const float EPS = 1e-6;
layout(location = 0) out vec4 OutColor;
in vec2 uv; // -1.0 to 1.0
in vec2 uvnorm; // 0.0 to 1.0
uint pixelIndex;
uint rngState;

struct Material {
	vec3 emmision;
	vec4 outside_color1;
	vec4 outside_color2;
	vec3 outside_smoothness;
	vec3 inside_transition_prob;
	vec4 inside_color1;
	vec4 inside_color2;
	vec3 inside_smoothness;
	vec3 density;
	vec3 scatter_depth;
};
layout(std430, binding = 5) buffer Materials { Material materials[]; };


struct Transform {
	mat4 srt_transform;
	mat4 trs_transform;
	mat4 inv_srt_transform;};
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
	int transform_index;
	int object_type;
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

struct Mesh {
	int bvh_index;
	int padding1;
	int padding2;
	int padding3;};
layout(std430, binding = 45) buffer Meshes {Mesh meshes[];};

struct ProceduralMesh {
	int material_index;
	int transform_index;
	int mesh_index;
	int padding;};
layout(std430, binding = 46) buffer ProceduralMeshes {ProceduralMesh procedurals_meshes[];};
uniform int PROCEDURALS_MESHES_COUNT;


struct ProceduralSDF {
	int material_index;
	int transform_index;
	int object_type;
	int padding;
	mat4 param;};
layout(std430, binding = 47) buffer ProceduralsSDF {ProceduralSDF procedurals_sdf[];};
uniform int PROCEDURALS_SDF_COUNT;



float RandomUniform(){
	rngState = rngState * 747796405 + 2891336453;
	uint result_RandomUniform = ((rngState >> ((rngState >> 28) + 4)) ^ rngState) * 277803737;
	result_RandomUniform = (result_RandomUniform >> 22) ^ result_RandomUniform;
	return clamp(result_RandomUniform / 4294967295.0, 0.0, 1.0);
}
float Random(){
	rngState = rngState * 747796405 + 2891336453;
	uint result_RandomUniform = ((rngState >> ((rngState >> 28) + 4)) ^ rngState) * 277803737;
	result_RandomUniform = (result_RandomUniform >> 22) ^ result_RandomUniform;
	return clamp(result_RandomUniform / 4294967295.0, 0.0, 1.0)*2.0-1.0;
}
#define PI 3.14159265359
vec2 Random2DCircle(){
	float t_Random2DCircle = Random() * PI;
	return vec2(sin(t_Random2DCircle),cos(t_Random2DCircle)) * sqrt(RandomUniform());
}
float RandomNormalDistribution(){
	float theta_RandomNormalDistribution = 2 * PI * RandomUniform();
	float rho_RandomNormalDistribution = sqrt(-2.0 * log(RandomUniform()));
	return clamp(rho_RandomNormalDistribution * cos(theta_RandomNormalDistribution) * 0.25, -1.0, 1.0);
}
float RandomNormalDistributionUniform(){
	float theta_RandomNormalDistribution = 2 * PI * RandomUniform();
	float rho_RandomNormalDistribution = sqrt(-2.0 * log(RandomUniform()));
	return clamp(rho_RandomNormalDistribution * cos(theta_RandomNormalDistribution) * 0.25, -1.0, 1.0)*0.5+0.5;
}
vec3 RandomSphereDirection(){
	return normalize(vec3(RandomNormalDistribution(),RandomNormalDistribution(),RandomNormalDistribution()));
}


Camera global_camera;
Transform global_transform_camera;


float ior_stack[10] = float[10](1,1,1,1,1,1,1,1,1,1);
int ior_depth = 5;



struct Ray{
	vec3 ro;
	vec3 rd;
};
Ray global_ray;
vec3 global_inv_rd;


vec3 global_ro_orig;
vec3 global_rd_orig;



struct IntersectInfo{
	int is_inside;
	float distance;
	vec3 position;
	vec3 normal;
	vec3 local_position;
	vec3 local_normal;
};

struct Intersect{
	bool is_intersect;
	int intersect_id;
	IntersectInfo intersect_info;
	Material material;
	int material_index;
};
Material void_material = Material(
	vec3(0),

	vec4(0,0,0,1),
	vec4(0,0,0,1),
	vec3(0),

	vec3(0),

	vec4(0,0,0,1),
	vec4(0,0,0,1),
	vec3(0),

	vec3(1),
	vec3(1)
);
Intersect closer_intersect = Intersect(
	false, -1,
	IntersectInfo(
		0,
		-1.0,
		vec3(0),
		vec3(0),
		vec3(0),
		vec3(0)
	),
	void_material,
	-1
);
bool has_intersection;

Procedural procedural;
mat4 procedural_inv_srt_transform;




const vec3 plane_normal = vec3(0,1,0);
void planeIntersection(){
	float denom_planeIntersection = dot(global_ray.rd, plane_normal);
	if (abs(denom_planeIntersection) < EPS) return;

	float min_distance = -dot(global_ray.ro, plane_normal)/denom_planeIntersection;
	if(min_distance < 0.0) return;

	vec3 local_pos = global_ray.ro + global_ray.rd * min_distance;
	vec2 plane_size = abs(local_pos.xz);
	if(plane_size.x > 1.0 || plane_size.y > 1.0) return;

	if(
		closer_intersect.intersect_info.distance >= 0 &&
		min_distance > closer_intersect.intersect_info.distance + SHIFT
	) return;

	bool is_inside = denom_planeIntersection>0.0;
	has_intersection = true;

	closer_intersect.is_intersect = true;
	closer_intersect.intersect_info.is_inside = -1;
	closer_intersect.intersect_info.distance = min_distance;
	closer_intersect.intersect_info.local_position = local_pos;
	closer_intersect.intersect_info.local_normal = is_inside?-plane_normal:plane_normal;
	closer_intersect.material = materials[procedural.material_index];
	closer_intersect.material_index = procedural.material_index;
}

void elipsIntersection(){
	float ray_len_elipsIntersection = length(global_ray.rd);
	if(ray_len_elipsIntersection == 0.0) return;
	vec3 rd_local_elipsIntersection = global_ray.rd / ray_len_elipsIntersection;

	float b_elipsIntersection = dot(global_ray.ro, rd_local_elipsIntersection);
	float c_elipsIntersection = dot(global_ray.ro, global_ray.ro) - 1.0;
	float h_elipsIntersection = b_elipsIntersection*b_elipsIntersection-c_elipsIntersection;
	if(h_elipsIntersection<0.0) return;

	h_elipsIntersection = sqrt( h_elipsIntersection );
	vec2 dist = vec2(-b_elipsIntersection-h_elipsIntersection,-b_elipsIntersection+h_elipsIntersection);
	bool is_inside = dist.x < 0.0;
	float min_distance = (is_inside ? (dist.y > 0.0 ? dist.y : -1.0) : dist.x);

	if(min_distance<0.0) return;

	float t_world_elipsIntersection = min_distance/ray_len_elipsIntersection;

	if(
		closer_intersect.intersect_info.distance >= 0 &&
		t_world_elipsIntersection > closer_intersect.intersect_info.distance + SHIFT
	) return;

	vec3 local_pos = global_ray.ro + rd_local_elipsIntersection * min_distance;

	has_intersection = true;

	closer_intersect.is_intersect = true;
	closer_intersect.intersect_info.is_inside = is_inside?1:0;
	closer_intersect.intersect_info.distance = t_world_elipsIntersection;
	closer_intersect.intersect_info.local_position = local_pos;
	closer_intersect.intersect_info.local_normal = is_inside?-normalize( local_pos ):normalize( local_pos );
	closer_intersect.material = materials[procedural.material_index];
	closer_intersect.material_index = procedural.material_index;
}

void boxIntersection(){
	if (
	(abs(global_ray.rd.x) < EPS && abs(global_ray.ro.x) > 1.0) ||
	(abs(global_ray.rd.y) < EPS && abs(global_ray.ro.y) > 1.0) ||
	(abs(global_ray.rd.z) < EPS && abs(global_ray.ro.z) > 1.0)) return;

	vec3 n_boxIntersection = global_inv_rd*global_ray.ro;
	vec3 k_boxIntersection = abs(global_inv_rd);
	vec3 t1_boxIntersection = -n_boxIntersection-k_boxIntersection;
	vec3 t2_boxIntersection = -n_boxIntersection+k_boxIntersection;

	vec2 dist = vec2(
		max( max( t1_boxIntersection.x, t1_boxIntersection.y ), t1_boxIntersection.z ),
		min( min( t2_boxIntersection.x, t2_boxIntersection.y ), t2_boxIntersection.z )
	);
	if( dist.x>dist.y || dist.y<0.0) return;
	bool is_inside = dist.x < 0.0;
	float min_distance = (is_inside ? (dist.y > 0.0 ? dist.y : -1.0) : dist.x);

	if( min_distance < 0.0 ||
		closer_intersect.intersect_info.distance >= 0 &&
		min_distance > closer_intersect.intersect_info.distance + SHIFT
	) return;

	vec3 local_pos = global_ray.ro + global_ray.rd * min_distance;
	vec3 local_normal = (is_inside ? 
		step(t2_boxIntersection,vec3(dist.y)) : 
		step(vec3(dist.x),t1_boxIntersection)) * (-sign(global_ray.rd));

	has_intersection = true;

	closer_intersect.is_intersect = true;
	closer_intersect.intersect_info.is_inside = is_inside?1:0;
	closer_intersect.intersect_info.distance = min_distance;
	closer_intersect.intersect_info.local_position = local_pos;
	closer_intersect.intersect_info.local_normal = local_normal;
	closer_intersect.material = materials[procedural.material_index];
	closer_intersect.material_index = procedural.material_index;
}

ProceduralMesh procedural_mesh;
Mesh mesh;
BVH bvh;
int bvh_alternative[32];
int bvh_alternative_shift;
BVH left;
BVH right;
vec2 dist_test = vec2(0);


void triangleIntersection(int triangle_id) {

	vec3 v0_triangleIntersection = triangles[triangle_id].posA;
	vec3 v1_triangleIntersection = triangles[triangle_id].posB;
	vec3 v2_triangleIntersection = triangles[triangle_id].posC;

	vec3 v1v0_triangleIntersection = v1_triangleIntersection - v0_triangleIntersection;
	vec3 v2v0_triangleIntersection = v2_triangleIntersection - v0_triangleIntersection;
	vec3 rov0_triangleIntersection = global_ray.ro - v0_triangleIntersection;

	vec3 n_triangleIntersection = cross( v1v0_triangleIntersection, v2v0_triangleIntersection );

    float denom_triangleIntersection = dot(global_ray.rd, n_triangleIntersection);
    // Проверка на параллельность луча и плоскости
    if (abs(denom_triangleIntersection) < 1e-6) return;

	vec3 q_triangleIntersection = cross( rov0_triangleIntersection, global_ray.rd );
	float d_triangleIntersection = 1.0/dot( global_ray.rd, n_triangleIntersection );
	float u_triangleIntersection = d_triangleIntersection*dot( -q_triangleIntersection, v2v0_triangleIntersection );
	float v_triangleIntersection = d_triangleIntersection*dot(  q_triangleIntersection, v1v0_triangleIntersection );
	float min_distance = d_triangleIntersection*dot( -n_triangleIntersection, rov0_triangleIntersection );

	if( u_triangleIntersection<0.0 || v_triangleIntersection<0.0 || (u_triangleIntersection+v_triangleIntersection)>1.0 || min_distance <= 0.0) return;
	
	if(
		closer_intersect.intersect_info.distance >= 0 &&
		min_distance > closer_intersect.intersect_info.distance + SHIFT
	) return;

    bool is_inside = (denom_triangleIntersection > 0.0);

	closer_intersect.is_intersect = true;
	//closer_intersect.intersect_info.is_inside = is_inside?1:0;
	closer_intersect.intersect_info.is_inside = -1;
	closer_intersect.intersect_info.distance = min_distance;
	closer_intersect.intersect_info.local_position = global_ray.ro+global_ray.rd*min_distance;
	closer_intersect.intersect_info.local_normal = is_inside?-normalize(n_triangleIntersection):normalize(n_triangleIntersection);
	closer_intersect.material = materials[procedural_mesh.material_index];
	closer_intersect.material_index = procedural.material_index;

	has_intersection = true;
}

float intersectRayCubeFull(vec3 cubeMin, vec3 cubeMax){
    vec3 tMin_intersectRayCubeFull = (cubeMin - global_ray.ro) * global_inv_rd;
    vec3 tMax_intersectRayCubeFull = (cubeMax - global_ray.ro) * global_inv_rd;

    vec3 t1_intersectRayCubeFull = min(tMin_intersectRayCubeFull, tMax_intersectRayCubeFull);
    vec3 t2_intersectRayCubeFull = max(tMin_intersectRayCubeFull, tMax_intersectRayCubeFull);
    vec2 dist = vec2(
		max( max( t1_intersectRayCubeFull.x, t1_intersectRayCubeFull.y ), t1_intersectRayCubeFull.z ),
		min( min( t2_intersectRayCubeFull.x, t2_intersectRayCubeFull.y ), t2_intersectRayCubeFull.z )
	);
    if( dist.x>dist.y || dist.y<0.0) return -1.0; // no intersection
	return max(0.0,dist.x);
}



ProceduralSDF procedural_sdf;

float sdBoxFrame( vec3 p ) {
	p = abs(p)-vec3(1);
	vec3 QsdBoxFrame = abs(p+procedural_sdf.param[0][0])-procedural_sdf.param[0][0];
	return min(min(
		length(max(vec3(p.x,QsdBoxFrame.y,QsdBoxFrame.z),0.0))+min(max(p.x,max(QsdBoxFrame.y,QsdBoxFrame.z)),0.0),
		length(max(vec3(QsdBoxFrame.x,p.y,QsdBoxFrame.z),0.0))+min(max(QsdBoxFrame.x,max(p.y,QsdBoxFrame.z)),0.0)),
		length(max(vec3(QsdBoxFrame.x,QsdBoxFrame.y,p.z),0.0))+min(max(QsdBoxFrame.x,max(QsdBoxFrame.y,p.z)),0.0));
}
float sdTorus( vec3 p ) {
	vec2 QsdTorus = vec2(length(p.xz)-procedural_sdf.param[0][0],p.y);
	return length(QsdTorus)-procedural_sdf.param[0][1];
}
float sdSphere( vec3 p ) {
	return length(p)-procedural_sdf.param[0][0];
}



float sdFunc(vec3 p) {
	vec3 q_sdFunc = p-procedural_sdf.param[2][3]*clamp(round(p/procedural_sdf.param[2][3]),-procedural_sdf.param[2].xyz,procedural_sdf.param[2].xyz);
	if(procedural_sdf.object_type == 0) return sdBoxFrame(q_sdFunc); 
	if(procedural_sdf.object_type == 1) return sdTorus(q_sdFunc);
	if(procedural_sdf.object_type == 2) return sdSphere(q_sdFunc);
	return 0.0;
}
const vec2 e = vec2(0.0001,0);
vec3 calcNormal(vec3 p) {
    return normalize(vec3(
        sdFunc(p + e.xyy) - sdFunc(p - e.xyy),
        sdFunc(p + e.yxy) - sdFunc(p - e.yxy),
        sdFunc(p + e.yyx) - sdFunc(p - e.yyx)
    ));
}
bool opUnion( float d1, float d2 ) {
    return d1 < d2;
}
bool opSubtraction( float d1, float d2 ) {
    return -d1 > d2;
}
bool opIntersection( float d1, float d2 ) {
    return d1 > d2;
}
bool opXor( float d1, float d2 ) {
    return min(d1,d2) > -max(d1,d2);
}

void SDFIntersection(){
	mat4[10] sdf_inversed;
	mat3[10] sdf_rays;
	vec2 sdf_curent_distance = vec2(0);
	vec2 sdf_min_distance = vec2(0);
	float sdf_current_shift = 0.0;
	bool sdf_first_hit = true;
	int sdf_index_of_last_hit = -1;
	int sdf_operator = 0;
	for(int i = 0; i < PROCEDURALS_SDF_COUNT; i++) {
		procedural_sdf = procedurals_sdf[i];
		procedural_inv_srt_transform = transforms[procedural_sdf.transform_index].inv_srt_transform;
		sdf_inversed[i] = procedural_inv_srt_transform;
		sdf_rays[i][0] = (procedural_inv_srt_transform * vec4(global_ro_orig,1)).xyz;
		sdf_rays[i][1] = (procedural_inv_srt_transform * vec4(global_rd_orig,0)).xyz;
		sdf_rays[i][2].x = length(sdf_rays[i][1]);
	}

	float min_distance = 0.0;

	for(int i = 0; i < 500; i++) {
		sdf_first_hit = true;
		sdf_index_of_last_hit = -1;
		if(
			closer_intersect.intersect_info.distance < 0 ? min_distance > 100.0:
			min_distance > closer_intersect.intersect_info.distance
		) break;
		for(int j = 0; j < PROCEDURALS_SDF_COUNT; j++) {
			procedural_sdf = procedurals_sdf[j];
			sdf_operator = int(procedural_sdf.param[3][3]);
			sdf_curent_distance.x = sdFunc(sdf_rays[j][0])/sdf_rays[j][2].x;
			sdf_curent_distance.y = abs(sdf_curent_distance.x);
			if(sdf_first_hit){
				sdf_min_distance = sdf_curent_distance;
				sdf_index_of_last_hit = j;
				sdf_first_hit = false;
			}
			else if(
				sdf_operator==0?
				opUnion(sdf_curent_distance.x , sdf_min_distance.x):
				sdf_operator==1?
				opSubtraction(sdf_curent_distance.x , sdf_min_distance.x):
				sdf_operator==2?
				opIntersection(sdf_curent_distance.x , sdf_min_distance.x):
				sdf_operator==3?
				opXor(sdf_curent_distance.x , sdf_min_distance.x):
				false
			){
				sdf_min_distance = sdf_curent_distance;
				sdf_index_of_last_hit = j;
			}
		}
		min_distance += sdf_min_distance.y;
		for(int j = 0; j < PROCEDURALS_SDF_COUNT; j++) sdf_rays[j][0] += sdf_rays[j][1] * sdf_min_distance.y;
		if(sdf_min_distance.y <= SHIFTMIN) break;
	}

	if(sdf_index_of_last_hit<0) return;



	bool is_inside = sdf_min_distance.x<0;
	vec3 local_pos = sdf_rays[sdf_index_of_last_hit][0];


	has_intersection = true;

	procedural_sdf = procedurals_sdf[sdf_index_of_last_hit];
	procedural_inv_srt_transform = sdf_inversed[sdf_index_of_last_hit];

	closer_intersect.is_intersect = true;
	closer_intersect.intersect_id = sdf_index_of_last_hit;
	closer_intersect.intersect_info.is_inside = is_inside?1:0;
	closer_intersect.intersect_info.distance = min_distance;
	closer_intersect.intersect_info.local_position = local_pos;
	closer_intersect.intersect_info.local_normal = (is_inside?
				-calcNormal(local_pos):calcNormal(local_pos));
	closer_intersect.material = materials[procedural_sdf.material_index];
	closer_intersect.material_index = procedural_sdf.material_index;
}





float intersection_count_triangle = 0;
float intersection_count_box = 0;
void UpdateCloserIntersect(){
	closer_intersect.is_intersect = false;
	closer_intersect.intersect_info.is_inside = 0;
	closer_intersect.intersect_info.distance = -1.0;
	closer_intersect.material = void_material;
	closer_intersect.material_index = -1;

	global_ro_orig = global_ray.ro;
	global_rd_orig = global_ray.rd;







	for(int i = 0; i < PROCEDURALS_COUNT; i++) {
		procedural = procedurals[i];
		procedural_inv_srt_transform = transforms[procedural.transform_index].inv_srt_transform;
		global_ray.ro = (procedural_inv_srt_transform * vec4(global_ro_orig,1)).xyz;
		global_ray.rd = (procedural_inv_srt_transform * vec4(global_rd_orig,0)).xyz;
		global_inv_rd = 1.0/global_ray.rd;


		has_intersection = false;

		if(procedural.object_type == 0)
			elipsIntersection();
		if(procedural.object_type == 1)
			boxIntersection();
		if(procedural.object_type == 2)
			planeIntersection();
		
		if(has_intersection){
			closer_intersect.intersect_id = i;
			closer_intersect.intersect_info.normal = normalize(
				transpose(mat3(procedural_inv_srt_transform)) *
				closer_intersect.intersect_info.local_normal
			);
			closer_intersect.intersect_info.position = (
				global_ro_orig + global_rd_orig * closer_intersect.intersect_info.distance
			);
		}
	}



	// has_intersection = false;
	// SDFIntersection();
	// if(has_intersection){
	// 	closer_intersect.intersect_info.normal = normalize(
	// 		transpose(mat3(procedural_inv_srt_transform)) *
	// 		closer_intersect.intersect_info.local_normal
	// 	);
	// 	closer_intersect.intersect_info.position = (
	// 		global_ro_orig + global_rd_orig * closer_intersect.intersect_info.distance
	// 	);
	// }



	for(int i = 0; i < PROCEDURALS_MESHES_COUNT; i++) {
		procedural_mesh = procedurals_meshes[i];
		if(procedural_mesh.mesh_index<0) continue;
		mesh = meshes[procedural_mesh.mesh_index];
		if(mesh.bvh_index<0) continue;
		procedural_inv_srt_transform = transforms[procedural_mesh.transform_index].inv_srt_transform;
		global_ray.ro = (procedural_inv_srt_transform * vec4(global_ro_orig,1)).xyz;
		global_ray.rd = (procedural_inv_srt_transform * vec4(global_rd_orig,0)).xyz;
		global_inv_rd = 1.0/global_ray.rd;

		bvh_alternative_shift = 1;
		bvh_alternative[bvh_alternative_shift] = mesh.bvh_index;

		has_intersection = false;

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

		if(has_intersection){
			closer_intersect.intersect_id = i;
			closer_intersect.intersect_info.normal = normalize(
				transpose(mat3(procedural_inv_srt_transform)) *
				closer_intersect.intersect_info.local_normal
			);
			closer_intersect.intersect_info.position = (
				global_ro_orig + global_rd_orig * closer_intersect.intersect_info.distance
			);
		}
	}

	global_ray.ro = global_ro_orig;
	global_ray.rd = global_rd_orig;

}



#define spector_color_size 0.0
#define spector_color_shift 0.0
#define spector_color_amplitude 0.001
const float purple_color = 790.0;
const float blue_color =   mix(680.0,purple_color,spector_color_size);
const float green_color =  mix(600.0,blue_color,spector_color_size);
const float red_color =    mix(480.0,green_color,spector_color_size);

const vec4 spectrum[4] = vec4[](
	vec4(0.1, 0.0, 0.3333, ((1.0/(purple_color*purple_color*EPS))+spector_color_shift)*spector_color_amplitude),

	vec4(0.0, 0.0, 0.3333, ((1.0/(blue_color*blue_color*EPS))+spector_color_shift)*spector_color_amplitude),

	vec4(0.0, 0.5, 0.0, ((1.0/(green_color*green_color*EPS))+spector_color_shift)*spector_color_amplitude),

	vec4(0.9, 0.0, 0.0, ((1.0/(red_color*red_color*EPS))+spector_color_shift)*spector_color_amplitude)
);

vec4 current_ray_color = vec4(1,1,1,1.0/red_color);
void SelectRayDispersion(int index){
	int indexA = int(mod(float(index),3.0));
	int indexB = indexA+1;
	current_ray_color = mix(spectrum[indexA],spectrum[indexB],
	RandomUniform()
	);
}



bool NewRay(float alpha_chanael, float smoothness){


	float n1 = ior_stack[ior_depth];
	float n2;
	if(closer_intersect.intersect_info.is_inside==1)
		n2 = ior_stack[ior_depth-1];
	else n2 = closer_intersect.material.density.x;

	if(alpha_chanael>=1.0){
		global_ray.ro = closer_intersect.intersect_info.position + (closer_intersect.intersect_info.normal * SHIFT);
		vec3 direction = mix(
			RandomSphereDirection() + closer_intersect.intersect_info.normal, 
			reflect(global_ray.rd,closer_intersect.intersect_info.normal), 
			smoothness);
		float len = length(direction);
		if(len > SHIFT) global_ray.rd = direction/len;
		else global_ray.rd = closer_intersect.intersect_info.normal;
		return false;
	}
	else if(alpha_chanael<0.0){
		if(closer_intersect.intersect_info.is_inside>=0){
			if(closer_intersect.intersect_info.is_inside==1){
				ior_stack[ior_depth] = 1.0;
				ior_depth -= 1;
			}
			else{
				ior_depth += 1;
				ior_stack[ior_depth] = n2;
			}
		}

		global_ray.ro = closer_intersect.intersect_info.position - (closer_intersect.intersect_info.normal * SHIFT);
		vec3 direction;
		if(closer_intersect.material.inside_transition_prob.x<RandomUniform()){
			direction = mix(
			RandomSphereDirection() - closer_intersect.intersect_info.normal, 
			refract(global_ray.rd, closer_intersect.intersect_info.normal, n1/(n2+current_ray_color.a)),
			max(smoothness+current_ray_color.a,1.0));
		}
		else{
			direction = mix(
			RandomSphereDirection() - closer_intersect.intersect_info.normal, 
			refract(global_ray.rd, closer_intersect.intersect_info.normal, n1/(n2+current_ray_color.a)),
			max((closer_intersect.material.inside_smoothness.z<RandomUniform()?
			closer_intersect.material.inside_smoothness.x:
			closer_intersect.material.inside_smoothness.y)+current_ray_color.a,1.0));
		}
		float len = length(direction);
		if(len > SHIFT) global_ray.rd = direction/len;
		else global_ray.rd = -closer_intersect.intersect_info.normal;
		return closer_intersect.intersect_info.is_inside>=0;
	}


	float cosTheta = clamp(abs(dot(global_ray.rd, closer_intersect.intersect_info.normal)), 0.0, 1.0);

	// Расчет коэффициента Френеля при нормальном падении
	float F0 = pow((n1 - n2) / (n1 + n2), 2.0);
	// Приближение Шлика
	float Fresnel = F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);

	// Проверка на полное внутреннее отражение
	float criticalAngle = n2 / n1;
	if(n1 > n2 && sin(acos(cosTheta)) > criticalAngle) {
		Fresnel = 1.0;
	}

	if(RandomUniform() <= ( (alpha_chanael + Fresnel) )){ // is reflect
		global_ray.ro = closer_intersect.intersect_info.position + (closer_intersect.intersect_info.normal * SHIFT);
		vec3 direction = mix(
			RandomSphereDirection() + closer_intersect.intersect_info.normal, 
			reflect(global_ray.rd,closer_intersect.intersect_info.normal), 
			smoothness);
		float len = length(direction);
		if(len > SHIFT) global_ray.rd = direction/len;
		else global_ray.rd = closer_intersect.intersect_info.normal;
		return false;
	}
	else{ // is refract
		if(closer_intersect.intersect_info.is_inside>=0){
			if(closer_intersect.intersect_info.is_inside==1){
				ior_stack[ior_depth] = 1.0;
				ior_depth -= 1;
			}
			else{
				ior_depth += 1;
				ior_stack[ior_depth] = n2;
			}
		}

		global_ray.ro = closer_intersect.intersect_info.position - (closer_intersect.intersect_info.normal * SHIFT);
		vec3 direction;
		if(closer_intersect.material.inside_transition_prob.x<RandomUniform()){
			direction = mix(
			RandomSphereDirection() - closer_intersect.intersect_info.normal, 
			refract(global_ray.rd, closer_intersect.intersect_info.normal, n1/(n2+current_ray_color.a)),
			max(smoothness+current_ray_color.a,1.0));
		}
		else{
			direction = mix(
			RandomSphereDirection() - closer_intersect.intersect_info.normal, 
			refract(global_ray.rd, closer_intersect.intersect_info.normal, n1/(n2+current_ray_color.a)),
			max((closer_intersect.material.inside_smoothness.z<RandomUniform()?
			closer_intersect.material.inside_smoothness.x:
			closer_intersect.material.inside_smoothness.y)+current_ray_color.a,1.0));
		}
		float len = length(direction);
		if(len > SHIFT) global_ray.rd = direction/len;
		else global_ray.rd = -closer_intersect.intersect_info.normal;
		return closer_intersect.intersect_info.is_inside>=0;
	}
}



float scatter_distance[10] = float[10](1,1,1,1,1,1,1,1,1,1);
int scatter_stack[10] = int[10](-1,-1,-1,-1,-1,-1,-1,-1,-1,-1);
int scatter_depth = 5;



vec3 render(){
	vec3 final_color = vec3(0);
	vec3 ray_color = current_ray_color.rgb;

	UpdateCloserIntersect();

	//return closer_intersect.material.outside_color1.rgb;

	bool probability;
	vec4 color;
	bool is_refract;

	vec3 direction;
	float dir_leng;

	int current_scatter_index;
	Material material;

	for(int i = 0; i < global_camera.max_bounce_count; i++) {
		if(!closer_intersect.is_intersect) break;

		current_scatter_index = scatter_stack[scatter_depth-1];
		if(current_scatter_index==-1){
			probability = closer_intersect.material.outside_smoothness.z<RandomUniform();
			color = (probability?
				closer_intersect.material.outside_color1:
				closer_intersect.material.outside_color2);
			is_refract = NewRay(color.a,
			probability?
			closer_intersect.material.outside_smoothness.x:
			closer_intersect.material.outside_smoothness.y);


			final_color += closer_intersect.material.emmision * ray_color;
			ray_color *= color.rgb;

			if(is_refract && closer_intersect.intersect_info.is_inside==0){
				scatter_stack[scatter_depth] = closer_intersect.intersect_id;
				scatter_depth+=1;
			}
			if(length(ray_color) <= SHIFT) break;
			UpdateCloserIntersect();
		}
		else{
				material = materials[procedurals[current_scatter_index].material_index];

				if(
					min(1.0,sqrt(closer_intersect.intersect_info.distance))
					//1.0-(closer_intersect.intersect_info.distance*10000)
					*material.scatter_depth.x
					>RandomUniform()
				){
					if(material.inside_transition_prob.x<RandomUniform()){
						probability = material.outside_smoothness.z<RandomUniform();
						color = (probability?
							material.outside_color1:
							material.outside_color2);
						direction = mix(
							RandomSphereDirection()-global_ray.rd*color.a,
							color.a>0.5?-global_ray.rd:global_ray.rd,
							max((probability?
							material.outside_smoothness.x:
							material.outside_smoothness.y)+current_ray_color.a,1.0)
						);
						dir_leng = length(direction);
					}
					else{
						probability = material.inside_smoothness.z<RandomUniform();
						color = (probability?
							material.inside_color1:
							material.inside_color2);
						direction = mix(
							RandomSphereDirection()-global_ray.rd*color.a,
							color.a>0.5?-global_ray.rd:global_ray.rd,
							max((probability?
							material.inside_smoothness.x:
							material.inside_smoothness.y)+current_ray_color.a,1.0)
						);
						dir_leng = length(direction);
					}
					final_color += material.emmision * ray_color;
					//final_color += vec3(2,0,0) * ray_color;
					ray_color *= color.rgb;
					if(length(ray_color) <= SHIFT) break;

					if(dir_leng>SHIFT) global_ray.rd = direction/dir_leng;
					UpdateCloserIntersect();
					global_ray.ro += global_ray.rd*closer_intersect.intersect_info.distance*RandomUniform();
					UpdateCloserIntersect();
				}
				else{
					// transition_probability = closer_intersect.material.inside_transition_prob.x<RandomUniform();
					// if(transition_probability){
					// 	probability = closer_intersect.material.outside_smoothness.z<RandomUniform();
					// 	color = (probability?
					// 		closer_intersect.material.outside_color1:
					// 		closer_intersect.material.outside_color2);
					// 	is_refract = NewRay(color.a,
					// 	probability?
					// 	closer_intersect.material.outside_smoothness.x:
					// 	closer_intersect.material.outside_smoothness.y);
					// }
					// else{
					// 	probability = closer_intersect.material.inside_smoothness.z<RandomUniform();
					// 	color = (probability?
					// 		closer_intersect.material.inside_color1:
					// 		closer_intersect.material.inside_color2);
					// 	is_refract = NewRay(color.a,
					// 	probability?
					// 	closer_intersect.material.inside_smoothness.x:
					// 	closer_intersect.material.inside_smoothness.y);
					// }
					probability = closer_intersect.material.outside_smoothness.z<RandomUniform();
					color = (probability?
						closer_intersect.material.outside_color1:
						closer_intersect.material.outside_color2);
					is_refract = NewRay(color.a,
					probability?
					closer_intersect.material.outside_smoothness.x:
					closer_intersect.material.outside_smoothness.y);


					final_color += closer_intersect.material.emmision * ray_color;
					ray_color *= color.rgb;

					if(is_refract){
						if(current_scatter_index == closer_intersect.intersect_id && closer_intersect.intersect_info.is_inside==1){
							scatter_depth-=1;
							scatter_stack[scatter_depth] = -1;
						}
						else{
							scatter_stack[scatter_depth] = closer_intersect.intersect_id;
							scatter_depth+=1;
						}
					}
					if(length(ray_color) <= SHIFT) break;
					UpdateCloserIntersect();
				}
			
		}




	}

	return final_color;
}




uniform int FRAME_ID;
uniform int CURRENT_CHUNK;
uniform int CHUNK_WIDTH;
uniform int CHUNK_HEIGHT;
layout (binding = 0, rgba32f) uniform image2D MainTexture;
ivec2 size_texture = imageSize(MainTexture);
vec4 main_color = imageLoad(MainTexture, ivec2(gl_FragCoord.xy));



uniform bool RENDERING_RUN;
void main() {
	if(!RENDERING_RUN && CURRENT_CHUNK>0) discard;
	if(RENDERING_RUN){
		ivec2 chunk_coord = ivec2(CHUNK_WIDTH*uvnorm.x,CHUNK_HEIGHT*(1.0-uvnorm.y));
		int curent_chunk = chunk_coord.y * CHUNK_WIDTH + chunk_coord.x;
		if(curent_chunk!=CURRENT_CHUNK) discard;
	}
	ivec2 pixelCoord = ivec2(size_texture.x*uv.x,size_texture.y*uv.y);
	pixelIndex = pixelCoord.y * size_texture.x + pixelCoord.x;
	rngState = pixelIndex + (FRAME_ID * 719393);


	global_ray = Ray(
		vec3(0),
		vec3(0)
	);

	vec3 final_color = vec3(0);
	vec3 render_color;


	vec4 ray_eye;
	vec4 ray_world;
	vec3 ro;
	vec3 rd;


	for(int i = 0; i < CAMERAS_COUNT; i++) {

		global_camera = cameras[i];
		global_transform_camera = transforms[global_camera.transform_index];

		ray_eye = vec4( ( inverse(global_camera.projection) * vec4(uv, 1.0, 1.0) ).xy , 1.0, 0.0); // Преобразуем в направление
		ray_world = global_transform_camera.trs_transform * ray_eye;

		ro = global_transform_camera.srt_transform[3].xyz;
		rd = normalize(ray_world.xyz);


		// rendering start
		render_color = vec3(0);
		
		if(RENDERING_RUN){
			for(int i = 0; i < global_camera.num_samples; i++) {

				SelectRayDispersion(FRAME_ID);

				// for(int d = 0; d < 10; d++) {
				// 	ior_stack[d] = 1.0;
				// 	// scatter_stack[d] = -1;
				// 	// scatter_distance[d] = 1.0;
				// }
				ior_depth = 5;
				ior_stack[5] = 1.0;
				// scatter_depth = 5;

				vec2 rand = Random2DCircle()*0.005;
				global_ray.ro = ro;
				global_ray.rd = rd;
				global_ray.ro += (
					rand.x * global_transform_camera.srt_transform[0].xyz + 
					rand.y * global_transform_camera.srt_transform[1].xyz
				);

				render_color += render() * global_camera.iso;
			}
			render_color /= float(global_camera.num_samples);
		}
		else{
			vec2 rand = Random2DCircle()*0.005;
			global_ray.ro = ro;
			global_ray.rd = rd;
			global_ray.ro += (
				rand.x * global_transform_camera.srt_transform[0].xyz + 
				rand.y * global_transform_camera.srt_transform[1].xyz
			);

			render_color += render() * global_camera.iso;
		}


		final_color += render_color;
	}
	final_color /= float(CAMERAS_COUNT);


	float weight = 1.0 / float(FRAME_ID+1);



	final_color = (main_color.rgb * (1.0-weight)) + (final_color * weight);
	OutColor = vec4(final_color, 1.0);
}