#version 330 core

layout(location = 0) in vec3 vertice_data;
layout(location = 1) in vec2 texture_coord_data;
layout(location = 2) in vec3 normal_data;




out vec4 position_local_screen;

void main()
{
	vec4 vertices = vec4(vertice_data * vec3(-1.0,1.0,1.0),1.0) * vec4(-1,-1,-1,1) * vec4(-1,-1,1,1);

	gl_Position = vertices;

	position_local_screen = gl_Position;
}