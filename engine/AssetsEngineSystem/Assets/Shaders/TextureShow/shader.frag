#version 430 core
out vec4 OutColor;
in vec4 position_local_screen;

uniform sampler2D MainTexture;

void main()
{
	OutColor = texture(MainTexture, (position_local_screen.xy + 1.0) * 0.5);
}