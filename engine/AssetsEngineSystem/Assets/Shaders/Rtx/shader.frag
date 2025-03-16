#version 460 core
layout(location = 0) out vec4 OutColor;
in vec2 uv; // -1.0 to 1.0
uint pixelIndex;

struct Material {
	vec4 color;
	vec3 emmision;
};
layout(std430, binding = 5) buffer Materials { Material materials[]; };

struct Transform {
	mat4 srt_transform;
	mat4 trs_transform;};
layout(std430, binding = 40) buffer Transforms {Transform transforms[];};
uniform int TRANSFORMS_COUNT;

struct Camera {
	mat4 projection;
	int transform_index;};
layout(std430, binding = 41) buffer Cameras {Camera cameras[];};
uniform int CAMERAS_COUNT;

struct Procedural {
	vec3 material_index_and_type_object;
	int transform_index;};
layout(std430, binding = 42) buffer Procedurals {Procedural procedurals[];};
uniform int PROCEDURALS_COUNT;


const float PHI = 1.61803398874989484820459; // Φ = Golden Ratio 
float Random(){
	pixelIndex *= (pixelIndex + 195439) * (pixelIndex + 124395) * (pixelIndex + 8445921);
	return pixelIndex / 4294967295.0;
}
float Random2(){
	pixelIndex = pixelIndex * 747796405 + 2891336453;
	uint result = ((pixelIndex >> ((pixelIndex >> 28) + 4)) ^ pixelIndex) * 277803737;
	result = (result >> 22) ^ result;
	return result / 4294967295.0;
}
float RandomNormalDistribution(){
	float theta = 2 * 3.1415926 * Random2();
	float rho = sqrt(-2.0 * log(Random2()));
	return rho * cos(theta);
}
vec3 RandomShpereDirection(){
	return normalize(vec3(RandomNormalDistribution(),RandomNormalDistribution(),RandomNormalDistribution()));
}
vec3 RandomHemisphereDirection(vec3 normal){
	vec3 dir = normalize(vec3(RandomNormalDistribution(),RandomNormalDistribution(),RandomNormalDistribution()));
	if(dot(normal, dir)<0) dir *= -1.0;
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
    float t_world = t / rd_len;
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
        world_normal
    );
}

IntersectInfo boxIntersection(in Ray ray, in mat4 srt_transform) {    
    return NONE_INTERSECT;
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















uniform int MAX_BOUNCE_COUNT;

vec3 render(in Ray ray) {
	vec3 final_color = vec3(0);
	vec3 ray_color = vec3(1);

	Intersect closer;
	for(int i = 0; i < MAX_BOUNCE_COUNT; i++) {
		closer = GetCloserProceduralIntersect(ray);
		if(closer.is_intersect){
			ray.ro = closer.intersect_info.position;
			ray.rd = RandomHemisphereDirection(closer.intersect_info.normal);

			final_color += closer.material.emmision * ray_color;
			ray_color *= closer.material.color.xyz;
			if(length(ray_color) <= 0) break;
		}
		else break;
	}

	return final_color;
}



void main() {
	ivec2 numPixels = ivec2(20000,20000);
	ivec2 pixelCoord = ivec2(numPixels.x*uv.x,numPixels.y*uv.y);
	pixelIndex = pixelCoord.y * numPixels.x + pixelCoord.x;

	vec3 final_color = vec3(0);
	for(int i = 0; i < CAMERAS_COUNT; i++) {
		Camera camera = cameras[i];
		Transform transform_camera = transforms[camera.transform_index];

		// Преобразуем NDC в координаты камеры
		vec4 ray_eye = vec4( ( inverse(camera.projection) * vec4(uv, 1.0, 1.0) ).xy , 1.0, 0.0); // Преобразуем в направление

		// Преобразуем координаты камеры в мировые координаты
		vec4 ray_world = transform_camera.trs_transform * ray_eye;
		vec3 rd = normalize(ray_world.xyz);

		Ray ray = Ray(
			transform_camera.srt_transform[3].xyz,
			rd
		);

		int iterations = 100;
		for(int i = 0; i < iterations; i++) {
			final_color += render(ray);
		}
		final_color /= float(iterations);
	}
	final_color /= CAMERAS_COUNT;
	OutColor = vec4(final_color * 10, 1.0);
}