import glfw
from OpenGL.GL import *
import numpy as np

# Инициализация GLFW
if not glfw.init():
    raise Exception("GLFW initialization failed")

# Создание окна
window = glfw.create_window(800, 600, "SSBO Example", None, None)
if not window:
    glfw.terminate()
    raise Exception("Window creation failed")

glfw.make_context_current(window)

# Вершинный шейдер
vertex_shader_source = """
#version 430 core
layout(location = 0) in vec2 aPos;
out vec4 position_local_screen;

void main() {
    gl_Position = vec4(aPos, 0.0, 1.0);
    position_local_screen = gl_Position;
}
"""

# Фрагментный шейдер (ваш исходный код)
fragment_shader_source = """
#version 430 core
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

void main() {
    OutColor = materials[1].main_color;
}
"""

# Компиляция шейдеров
def compile_shader(source, shader_type):
    shader = glCreateShader(shader_type)
    glShaderSource(shader, source)
    glCompileShader(shader)
    if not glGetShaderiv(shader, GL_COMPILE_STATUS):
        error = glGetShaderInfoLog(shader).decode()
        raise Exception(f"Shader compilation error: {error}")
    return shader

vertex_shader = compile_shader(vertex_shader_source, GL_VERTEX_SHADER)
fragment_shader = compile_shader(fragment_shader_source, GL_FRAGMENT_SHADER)

# Линковка программы
program = glCreateProgram()
glAttachShader(program, vertex_shader)
glAttachShader(program, fragment_shader)
glLinkProgram(program)
if not glGetProgramiv(program, GL_LINK_STATUS):
    error = glGetProgramInfoLog(program).decode()
    raise Exception(f"Program linking error: {error}")

glDeleteShader(vertex_shader)
glDeleteShader(fragment_shader)

# Создание геометрии (квад)
vertices = np.array([
    -1.0, -1.0,
     1.0, -1.0,
     1.0,  1.0,
    -1.0,  1.0
], dtype=np.float32)

indices = np.array([0, 1, 2, 2, 3, 0], dtype=np.uint32)

# VAO, VBO и EBO
VAO = glGenVertexArrays(1)
glBindVertexArray(VAO)

VBO = glGenBuffers(1)
glBindBuffer(GL_ARRAY_BUFFER, VBO)
glBufferData(GL_ARRAY_BUFFER, vertices.nbytes, vertices, GL_STATIC_DRAW)

EBO = glGenBuffers(1)
glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO)
glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.nbytes, indices, GL_STATIC_DRAW)

glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 8, ctypes.c_void_p(0))
glEnableVertexAttribArray(0)

# Структура материала с выравниванием std430
material_dtype = np.dtype([
    ('main_color', np.float32, 4),  # vec4 (16 bytes)
    ('albedo_map', np.int32),       # int (4 bytes)
    ('roughness', np.float32),      # float (4 bytes)
    ('metallic', np.uint32),        # bool (4 bytes)
    # Итого 28 байт + padding до 32 для выравнивания
    ('padding', np.uint8, 4)        # 4 байта padding
])

# Создаем 3 материала
num_materials = 3
materials_data = np.zeros(num_materials, dtype=material_dtype)

# Материал 0 (красный металлический)
materials_data[0]['main_color'] = (1.0, 0.0, 0.0, 1.0)
materials_data[0]['albedo_map'] = 0
materials_data[0]['roughness'] = 0.1
materials_data[0]['metallic'] = 1  # True

# Материал 1 (зеленый неметаллический)
materials_data[1]['main_color'] = (0.0, 1.0, 0.0, 1.0)
materials_data[1]['albedo_map'] = 1
materials_data[1]['roughness'] = 0.9
materials_data[1]['metallic'] = 0  # False

# Материал 2 (синий металлический)
materials_data[2]['main_color'] = (0.0, 0.0, 1.0, 1.0)
materials_data[2]['albedo_map'] = 2
materials_data[2]['roughness'] = 0.3
materials_data[2]['metallic'] = 1  # True

# Создание и настройка SSBO
ssbo = glGenBuffers(1)
glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo)
glBufferData(GL_SHADER_STORAGE_BUFFER, materials_data.nbytes, materials_data, GL_DYNAMIC_DRAW)
glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 40, ssbo)

# Основной цикл рендеринга
glUseProgram(program)
glBindVertexArray(VAO)

while not glfw.window_should_close(window):
    glClear(GL_COLOR_BUFFER_BIT)
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, None)
    glfw.swap_buffers(window)
    glfw.poll_events()

# Очистка ресурсов
glDeleteBuffers(1, [ssbo])  # Освобождаем SSBO
glDeleteBuffers(1, [VBO])
glDeleteBuffers(1, [EBO])
glDeleteVertexArrays(1, [VAO])
glDeleteProgram(program)
glfw.terminate()