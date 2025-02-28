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
uniform mat4 Matrix_View;
uniform mat4 Matrix_View_Normal;
uniform mat4 Matrix_Model;


out vec4 geom_vertice_data;
out vec2 geom_texture_coord_data;
out vec3 geom_normal_data;

out mat4 geom_Matrix_Projection;
out mat4 geom_Matrix_View;
out mat4 geom_Matrix_View_Normal;
out mat4 geom_Matrix_Model;
out mat3 geom_model_rotation;

void main()
{
	vec4 vertices = vec4(vertice_data * vec3(-1.0,1.0,1.0),1.0);

	mat4 matrix_model;
	if(Single_Render){
		matrix_model = Matrix_Model;
		geom_model_rotation = mat3(
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
		geom_model_rotation = mat3(
			normalize(matrix_model_col0.xyz),
			normalize(matrix_model_col1.xyz),
			normalize(matrix_model_col2.xyz)
		);
	}

	geom_vertice_data = vertices;
	geom_texture_coord_data = texture_coord_data;
	geom_normal_data = normal_data * vec3(-1.0,1.0,1.0);

	geom_Matrix_Projection = Matrix_Projection;
	geom_Matrix_View = Matrix_View;
	geom_Matrix_View_Normal = Matrix_View_Normal;
	geom_Matrix_Model = matrix_model;
}