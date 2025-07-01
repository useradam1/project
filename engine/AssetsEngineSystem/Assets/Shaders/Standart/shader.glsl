#version 330 core
layout (triangles) in;
layout (triangle_strip, max_vertices = int(6)) out;

in vec4 geom_vertice_data[];
in vec2 geom_texture_coord_data[];
in vec3 geom_normal_data[];

in mat4 geom_Matrix_Projection[];
in mat4 geom_Matrix_View[];
in mat4 geom_Matrix_View_Normal[];
in mat4 geom_Matrix_Model[];
in mat3 geom_model_rotation[];


flat out int mood_render;

out mat4 projection;
out mat4 view;
out mat4 view_normal;
out mat4 model;
out mat3 model_rotation;

out vec4 polygone_vertice;
out vec2 polygone_texCoord;
out vec3 polygone_normal;
out vec4 position_local_screen;

void drawModel(int iter){
	mood_render = iter;

	for (int i = 0; i < 3; i++) {
		vec4 pos = (geom_Matrix_Model[i] * (geom_vertice_data[i])) * vec4(-1,-1,-1,1);
		gl_Position = (geom_Matrix_Projection[i] * geom_Matrix_View[i] * pos) * vec4(-1,-1,1,1);


		polygone_vertice = geom_vertice_data[i];
		polygone_texCoord = geom_texture_coord_data[i];
		polygone_normal = geom_normal_data[i];
		position_local_screen = gl_Position;

		projection = geom_Matrix_Projection[i];
		view = geom_Matrix_View[i];
		view_normal = geom_Matrix_View_Normal[i];
		model = geom_Matrix_Model[i];
		model_rotation = geom_model_rotation[i];

		EmitVertex();
	}


	EndPrimitive();
}

void main() {
	mat4 m = mat4(1);

	drawModel(0);
	drawModel(1);
}
