#version 460 core
const float SHIFT = 0.001;
layout(location = 0) out vec4 OutColor;
in vec2 uv; // -1.0 to 1.0
uint pixelIndex;
uint rngState;

struct Material {
	vec4 color;
	vec3 emmision;
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
	float exposure;};
layout(std430, binding = 41) buffer Cameras {Camera cameras[];};
uniform int CAMERAS_COUNT;

struct Procedural {
	vec3 material_index_and_type_object;
	int transform_index;};
layout(std430, binding = 42) buffer Procedurals {Procedural procedurals[];};
uniform int PROCEDURALS_COUNT;


uint hash3D(vec3 pos) {
    uint h = floatBitsToUint(pos.x);
    h = h * 0x1f3d5u ^ floatBitsToUint(pos.y);
    h = h * 0x8b29u ^ floatBitsToUint(pos.z);
    h ^= h >> 16;
    h *= 0x85ebca6bu;
    h ^= h >> 13;
    return h;
}
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



IntersectInfo elipsIntersection(in Ray ray, in mat4 srt_transform) {
    mat4 invTransform = inverse(srt_transform);
    
    // Локальные координаты луча
    vec3 ro_local = (invTransform * vec4(ray.ro, 1.0)).xyz;
    vec3 rd_local = (invTransform * vec4(ray.rd, 0.0)).xyz;
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
    float t_world = (t / rd_len) - SHIFT;
    vec3 world_hit = ray.ro + ray.rd * t_world;
    
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


IntersectInfo boxIntersection(in Ray ray, in mat4 srt_transform) {

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

	vec3 ro = (ModelRot*(ray.ro-boxPos));
	vec3 rd = (ModelRot*ray.rd);


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
		dist = tN - SHIFT;
		hitpos = ray.ro+ray.rd*dist;
	} // ro ouside the box
    else{
		hitnor = step(t2,vec3(tF));
		dist = tF - SHIFT;
		hitpos = ray.ro+ray.rd*dist;
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


Intersect GetCloserProceduralIntersect(in Ray ray) {

	Intersect output_intersect = Intersect(
		false,
		ray,
		NONE_INTERSECT,
		materials[0]
	);

	Procedural procedural;
	Transform transform_procedural;
	Material material_procedural;
	IntersectInfo intersect_info;

	for(int i = 0; i < PROCEDURALS_COUNT; i++) {
		procedural = procedurals[i];
		transform_procedural = transforms[procedural.transform_index];
		material_procedural = materials[int(procedural.material_index_and_type_object.x)];

		if(procedural.material_index_and_type_object.y == 0.0)
			intersect_info = elipsIntersection(ray, transform_procedural.srt_transform);
		else if(procedural.material_index_and_type_object.y == 1.0)
			intersect_info = boxIntersection(ray, transform_procedural.srt_transform);
		
		if(!intersect_info.is_intersect) continue;

		if(!output_intersect.is_intersect || intersect_info.distance < output_intersect.intersect_info.distance){
			output_intersect.is_intersect = true;
			output_intersect.intersect_info = intersect_info;
			output_intersect.material = material_procedural;
		}
	};

	return output_intersect;
};
















vec3 render(in Ray ray, in int max_bounce_count) {
	vec3 final_color = vec3(0);
	vec3 ray_color = vec3(1);

	Intersect closer = GetCloserProceduralIntersect(ray);
	//pixelIndex += hash3D(closer.intersect_info.position);
	//final_color = closer.intersect_info.normal;
	//return final_color;

	for(int i = 0; i < max_bounce_count; i++) {
		if(closer.is_intersect){
			ray.ro = closer.intersect_info.position;
			ray.rd = RandomHemisphereDirection(closer.intersect_info.normal);

			final_color += closer.material.emmision * ray_color;
			ray_color *= closer.material.color.xyz;
			if(length(ray_color) <= 0) break;
		}
		else break;
		closer = GetCloserProceduralIntersect(ray);
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
			rd
		);


		vec3 render_color = vec3(0);
		for(int i = 0; i < camera.num_samples; i++) {
			render_color += render(ray, camera.max_bounce_count);
		}
		render_color /= float(camera.num_samples);
		//render_color = 1.0 - exp(-render_color * camera.exposure);


		final_color += render_color * camera.exposure;
	}
	final_color /= CAMERAS_COUNT;
	float weight = 1.0 / float(FRAME_ID+1);

	final_color = imageLoad(MainTexture, ivec2(gl_FragCoord.xy)).xyz * (1.0-weight) + final_color * weight;
	OutColor = vec4(final_color, 1.0);
}