#version 330 core

layout(location = 0) in vec3 vertice_data;
layout(location = 1) in vec2 texture_coord_data;
layout(location = 2) in vec3 normal_data;




out vec2 uv;
out vec2 uvnorm;

void main()
{
	vec4 vertices = vec4(vertice_data,1.0);

	gl_Position = vertices;

	uv = gl_Position.xy;
	uvnorm = gl_Position.xy*0.5+0.5;
}