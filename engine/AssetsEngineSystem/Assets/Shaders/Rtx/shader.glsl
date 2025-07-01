#version 330 core

layout(triangles) in;
layout(triangle_strip, max_vertices = 6) out;

in vec2 uv[];
in vec2 uvnorm[];

out vec2 uv_frag;
out vec2 uvnorm_frag;

uniform float time; // Для анимации (если нужно)
uniform vec3 offset = vec3(0.5, 0.0, 0.0); // Смещение для копии

void main() {
    // Оригинальная геометрия
    for(int i = 0; i < 3; i++) {
        gl_Position = gl_in[i].gl_Position;
        uv_frag = uv[i];
        uvnorm_frag = uvnorm[i];
        EmitVertex();
    }
    EndPrimitive();

    // Модифицированная копия (смещение + масштаб)
    for(int i = 0; i < 3; i++) {
        vec4 new_pos = gl_in[i].gl_Position;
        
        // Применяем смещение
        new_pos.xyz += offset;
        
        // Добавляем простую анимацию синусом
        new_pos.y += sin(time) * 0.2;
        
        // Масштабируем
        new_pos.xyz *= 0.8;

        gl_Position = new_pos;
        uv_frag = uv[i];
        uvnorm_frag = uvnorm[i];
        EmitVertex();
    }
    EndPrimitive();
}