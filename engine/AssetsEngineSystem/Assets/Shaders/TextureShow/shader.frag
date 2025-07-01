#version 430 core
out vec4 OutColor;
in vec2 TexCoord;

layout (binding = 0, rgba32f) uniform image2D MainTexture;

vec3 PostProcessColor(vec3 color)
{
    return color;
}

void main()
{
    ivec2 texSize = imageSize(MainTexture);  // Получаем размер текстуры
    ivec2 texelCoord = ivec2(TexCoord * texSize);  // Преобразуем координаты
    OutColor = vec4(sqrt(imageLoad(MainTexture, texelCoord).rgb), 1.0); // Загружаем пиксель
}
