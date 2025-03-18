#version 330 core

layout(location = 0) in vec3 vertice_data;
layout(location = 1) in vec2 texture_coord_data;
layout(location = 2) in vec3 normal_data;



out vec2 uv;

void main()
{
	gl_Position = vec4(vertice_data,1.0);

	uv = texture_coord_data;
}