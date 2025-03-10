#version 460 core
layout(location = 0) out vec4 OutColor;
in vec4 position_local_screen;


struct Material {
	vec4 main_color;
    int albedo_map;
    float roughness;
    bool metallic;
};

layout(std430, binding = 40) buffer Materials {
    Material materials[];
};


void main()
{
	//OutColor = vec4(position_local_screen.xy, 0, 1.0);
	OutColor = materials[0].main_color;
}