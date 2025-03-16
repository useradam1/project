#version 330 core

layout(location = 0) in vec3 vertice_data;
layout(location = 1) in vec2 texture_coord_data;
layout(location = 2) in vec3 normal_data;
layout(location = 4) in vec4 matrix_model_col0;
layout(location = 5) in vec4 matrix_model_col1;
layout(location = 6) in vec4 matrix_model_col2;
layout(location = 7) in vec4 matrix_model_col3;

uniform bool Single_Render;
uniform mat4 Matrix_Projection;
uniform mat4 Matrix_View_Normal;
uniform mat4 Matrix_View;
uniform mat4 Matrix_Model;

out mat4 projection;
out mat4 view;
out mat4 view_normal;
out mat4 model;
out mat3 model_rotation;

out vec4 polygone_vertice;
out vec3 polygone_normal;
out vec2 polygone_texCoord;
out vec4 position_local_screen;

void main()
{
	vec4 vertices = vec4(vertice_data * vec3(-1.0,1.0,1.0),1.0);

	mat4 matrix_model;
	if(Single_Render){
		matrix_model = Matrix_Model;
		model_rotation = mat3(
			normalize(Matrix_Model[0].xyz),
			normalize(Matrix_Model[1].xyz),
			normalize(Matrix_Model[2].xyz)
		);
	}
	else{
		matrix_model = mat4(
		matrix_model_col0,
		matrix_model_col1,
		matrix_model_col2,
		matrix_model_col3);
		model_rotation = mat3(
			normalize(matrix_model_col0.xyz),
			normalize(matrix_model_col1.xyz),
			normalize(matrix_model_col2.xyz)
		);
	}
	vec4 pos = matrix_model * vertices;


	pos *= vec4(-1,-1,-1,1);

	gl_Position = (Matrix_Projection * Matrix_View * pos) * vec4(-1,-1,1,1);

	projection = Matrix_Projection;
	view = Matrix_View;
	view_normal = Matrix_View_Normal;
	model = matrix_model;
	polygone_vertice = vertices;
	polygone_normal = normal_data * vec3(-1.0,1.0,1.0);
	polygone_texCoord = texture_coord_data;
	position_local_screen = gl_Position;
}