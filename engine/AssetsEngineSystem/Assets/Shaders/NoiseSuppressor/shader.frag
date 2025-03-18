#version 430 core
layout(location = 0) out vec4 OutColor;
in vec2 uv;
uint pixelIndex;


float RandomNormal(){
	pixelIndex = pixelIndex * 747796405 + 2891336453;
	uint result = ((pixelIndex >> ((pixelIndex >> 28) + 4)) ^ pixelIndex) * 277803737;
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

uniform sampler2D COLOR_TEXTURE;
uniform sampler2D DEPTH_TEXTURE; // -1 to float32 limit
uniform sampler2D NORMAL_TEXTURE; // -1 to float32 limit
uniform sampler2D DIRECTION_TEXTURE; // -1 to float32 limit from camera to objects framecoord
uniform int WIDTH;
uniform int HEIGHT;

void main() {
	ivec2 numPixels = ivec2(WIDTH,HEIGHT);
	ivec2 pixelCoord = ivec2(numPixels.x*uv.x,numPixels.y*uv.y);
	pixelIndex = (pixelCoord.y * numPixels.x + pixelCoord.x);
	
    vec4 final_color = texture(COLOR_TEXTURE, uv);
    float weightSum = 1.0;

	int iterations = 15;
    float radius = 0.5;
    vec2 texelSize = radius / vec2(HEIGHT,WIDTH);

	float depth_offset = 1;

    float curent_depth = texture(DEPTH_TEXTURE, uv).x;
    vec3 curent_normal = texture(NORMAL_TEXTURE, uv).xyz;
    vec3 curent_direction = texture(DIRECTION_TEXTURE, uv).xyz;
	vec3 curent_pos = curent_direction * curent_depth;

	vec2 offset = vec2(0);

    for(int i = -iterations; i <= iterations; i++) {
		for(int j = -iterations; j <= iterations; j++) {
			//vec2 offset = uv + (Random2DCircle() * texelSize);
			offset = uv + (vec2(i,j) + Random2DCircle()) * texelSize;
			if(offset.x>1.0 || offset.x<0.0 || offset.y>1.0 || offset.y<0.0) continue;

			float depth = texture(DEPTH_TEXTURE, offset).x;
			vec3 direction = texture(DIRECTION_TEXTURE, offset).xyz;
			float normal_coeficent = max(0.0,dot(
				texture(NORMAL_TEXTURE, offset).xyz,
				curent_normal));

			vec3 pos = direction*depth;

			if(
				length(curent_pos-pos) > depth_offset * normal_coeficent
			) continue;

			final_color += texture(COLOR_TEXTURE, offset);
			weightSum += 1;
		}
    }


	
    OutColor = vec4(final_color.xyz / weightSum, 1.0);
}