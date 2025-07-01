#version 330 core

layout(location = 0) in vec3 vertice_data;
layout(location = 1) in vec2 texture_coord_data;
layout(location = 2) in vec3 normal_data;


out vec2 TexCoord;

void main()
{
	gl_Position = vec4(vertice_data,1.0);
    TexCoord = gl_Position.xy*0.5+0.5;
}