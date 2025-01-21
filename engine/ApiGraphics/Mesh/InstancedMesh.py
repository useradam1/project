import glfw
import OpenGL.GL as gl
import numpy as np
import pyrr

vertex_shader = """
#version 330
layout (location = 0) in vec3 position;
layout (location = 1) in vec3 translation;
layout (location = 2) in vec3 color;
uniform mat4 projection;
uniform mat4 view;
out vec3 frag_color;
void main()
{
    gl_Position = projection * view * vec4(position + translation, 1.0);
    frag_color = color;
}
"""

fragment_shader = """
#version 330
in vec3 frag_color;
out vec4 fragColor;
void main()
{
    fragColor = vec4(frag_color, 1.0);
}
"""

def create_shader(shader_type, source):
    shader = gl.glCreateShader(shader_type)
    gl.glShaderSource(shader, source)
    gl.glCompileShader(shader)
    return shader

class InstancedObject:
    def __init__(self, vertices, indices, num_instances):
        self.num_instances = num_instances
        self.num_indices = len(indices)

        self.vao = gl.glGenVertexArrays(1)
        gl.glBindVertexArray(self.vao)

        # Вершины
        self.vbo = gl.glGenBuffers(1)
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.vbo)
        gl.glBufferData(gl.GL_ARRAY_BUFFER, vertices.nbytes, vertices, gl.GL_STATIC_DRAW)

        gl.glEnableVertexAttribArray(0)
        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 12, None)

        # Индексы
        self.ebo = gl.glGenBuffers(1)
        gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self.ebo)
        gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, indices.nbytes, indices, gl.GL_STATIC_DRAW)

        # Инстансы - позиции
        self.translations = np.random.uniform(-1, 1, (num_instances, 3)).astype(np.float32)
        self.instance_vbo = gl.glGenBuffers(1)
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.instance_vbo)
        gl.glBufferData(gl.GL_ARRAY_BUFFER, self.translations.nbytes, self.translations, gl.GL_DYNAMIC_DRAW)

        gl.glEnableVertexAttribArray(1)
        gl.glVertexAttribPointer(1, 3, gl.GL_FLOAT, gl.GL_FALSE, 12, None)
        gl.glVertexAttribDivisor(1, 1)

        # Инстансы - цвета
        self.colors = np.random.uniform(0, 1, (num_instances, 3)).astype(np.float32)
        self.color_vbo = gl.glGenBuffers(1)
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.color_vbo)
        gl.glBufferData(gl.GL_ARRAY_BUFFER, self.colors.nbytes, self.colors, gl.GL_STATIC_DRAW)

        gl.glEnableVertexAttribArray(2)
        gl.glVertexAttribPointer(2, 3, gl.GL_FLOAT, gl.GL_FALSE, 12, None)
        gl.glVertexAttribDivisor(2, 1)

    def update(self):
        self.translations += np.random.uniform(-0.01, 0.01, (self.num_instances, 3)).astype(np.float32)
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.instance_vbo)
        gl.glBufferSubData(gl.GL_ARRAY_BUFFER, 0, self.translations.nbytes, self.translations)

    def draw(self):
        gl.glBindVertexArray(self.vao)
        gl.glDrawElementsInstanced(gl.GL_TRIANGLES, self.num_indices, gl.GL_UNSIGNED_INT, None, self.num_instances)

def main():
    if not glfw.init():
        return

    window = glfw.create_window(800, 600, "Multiple Instanced Objects", None, None)
    if not window:
        glfw.terminate()
        return

    glfw.make_context_current(window)

    gl.glEnable(gl.GL_DEPTH_TEST)

    program = gl.glCreateProgram()
    gl.glAttachShader(program, create_shader(gl.GL_VERTEX_SHADER, vertex_shader))
    gl.glAttachShader(program, create_shader(gl.GL_FRAGMENT_SHADER, fragment_shader))
    gl.glLinkProgram(program)
    gl.glUseProgram(program)

    # Куб
    cube_vertices = np.array([
        -0.1, -0.1, -0.1,  0.1, -0.1, -0.1,  0.1,  0.1, -0.1, -0.1,  0.1, -0.1,
        -0.1, -0.1,  0.1,  0.1, -0.1,  0.1,  0.1,  0.1,  0.1, -0.1,  0.1,  0.1
    ], dtype=np.float32)

    cube_indices = np.array([
        0, 1, 2, 2, 3, 0,  1, 5, 6, 6, 2, 1,  7, 6, 5, 5, 4, 7,
        4, 0, 3, 3, 7, 4,  3, 2, 6, 6, 7, 3,  4, 5, 1, 1, 0, 4
    ], dtype=np.uint32)

    # Треугольник
    triangle_vertices = np.array([
        -0.1, -0.1, 0.0,
         0.1, -0.1, 0.0,
         0.0,  0.1, 0.0
    ], dtype=np.float32)

    triangle_indices = np.array([0, 1, 2], dtype=np.uint32)

    cubes = InstancedObject(cube_vertices, cube_indices, 50)
    triangles = InstancedObject(triangle_vertices, triangle_indices, 50)

    projection = pyrr.matrix44.create_perspective_projection_matrix(45, 800/600, 0.1, 100)
    view = pyrr.matrix44.create_look_at(
        pyrr.Vector3([0, 0, 3]),
        pyrr.Vector3([0, 0, 0]),
        pyrr.Vector3([0, 1, 0])
    )

    gl.glUniformMatrix4fv(gl.glGetUniformLocation(program, "projection"), 1, gl.GL_FALSE, projection)
    gl.glUniformMatrix4fv(gl.glGetUniformLocation(program, "view"), 1, gl.GL_FALSE, view)

    while not glfw.window_should_close(window):
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT)

        cubes.update()
        triangles.update()

        cubes.draw()
        triangles.draw()

        glfw.swap_buffers(window)
        glfw.poll_events()

    glfw.terminate()

if __name__ == "__main__":
    main()