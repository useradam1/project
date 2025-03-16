#version 430 core
out vec4 OutColor;

layout (binding = 0, rgba8) uniform image2D MainTexture;

void main()
{
	OutColor = imageLoad(MainTexture, ivec2(gl_FragCoord.xy));
}