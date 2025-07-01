#version 430 core

uniform float Near_Plane_Distance; //just near plane distance
uniform float Far_Plane_Scale; // is 1.0/Far_Plane_Distance
float farPlane = 1.0 / Far_Plane_Scale;

uniform int Count_Of_Depth_Layers_Transperency;
uniform bool Only_Transperent;
flat in int mood_render;

in mat4 projection;
in mat4 view;
in mat4 view_normal;
in mat4 model;
in mat3 model_rotation;

in vec4 polygone_vertice;
in vec3 polygone_normal;
in vec2 polygone_texCoord;
in vec4 position_local_screen;

uniform sampler2D MainTex;




float linearToLogDepth(float linearDepth) {
    float logDepth = log(linearDepth * (farPlane - Near_Plane_Distance));
    float logNear = log(Near_Plane_Distance);
    float logFar = log(farPlane);
    return (logDepth - logNear) / (logFar - logNear);
}






// выходные цвета для разных вложений
layout(location = 0) out vec4 COLOR;                               						// TEXTURE GL_UNSIGNED_BYTE
layout(location = 1) out vec4 COLOR_NORMAL;                        						// TEXTURE GL_FLOAT
layout(location = 2) out vec4 COLOR_POSITION;											// TEXTURE GL_FLOAT
layout(location = 3) out vec4 COLOR_DIRECTION_DISTANCE;            						// TEXTURE GL_FLOAT

layout(binding=4, rgba8) uniform image3D TRANSPERENT;                              		// TEXTURE GL_UNSIGNED_BYTE
layout(binding=5, rgba32f) uniform image3D TRANSPERENT_DIRECTION_DISTANCE;				// TEXTURE GL_FLOAT

void main()
{
    vec4 tex = texture(MainTex, polygone_texCoord);

    vec3 frag_pos = (model * polygone_vertice).xyz;
    vec3 normal = model_rotation * polygone_normal;

    vec3 direction_distance_to_view = frag_pos - view_normal[3].xyz;
    float linearDistance = position_local_screen.w * Far_Plane_Scale;

	if(mood_render==0){
		gl_FragDepth = position_local_screen.w * Far_Plane_Scale;

		if(tex.w < 1.0) discard;
		
		COLOR = tex;
		COLOR_NORMAL = vec4(normal, 1.0);
		COLOR_POSITION = vec4(frag_pos, 1.0);
		COLOR_DIRECTION_DISTANCE = vec4(direction_distance_to_view, 1.0);
	}
	else{
		gl_FragDepth = 0;

		if(tex.w < 1.0) {
			// Преобразование линейной глубины в логарифмическую и масштабирование до диапазона слоев
			float logDepth = linearToLogDepth(linearDistance);
			int d = int(logDepth * float(Count_Of_Depth_Layers_Transperency));
			
			imageStore(TRANSPERENT, ivec3(gl_FragCoord.xy, d), tex);
			imageStore(TRANSPERENT_DIRECTION_DISTANCE, ivec3(gl_FragCoord.xy, d), 
					vec4(direction_distance_to_view, 1.0));
		}
		
		discard;
	}	
}