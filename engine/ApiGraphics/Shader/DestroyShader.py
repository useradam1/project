from OpenGL.GL import *
from numpy import uint32

def DestroyShader(shader_program: uint32) -> None:
	glDeleteProgram(GLuint(shader_program))