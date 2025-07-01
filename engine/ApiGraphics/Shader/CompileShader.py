from OpenGL.GL import *
from typing import Tuple, Literal
from numpy import uint32

nulluint32 = uint32(0)

def CompileShader(source: str, shader_type: Literal['VERTEX_SHADER','GEOMETRY_SHADER','FRAGMENT_SHADER']) -> Tuple[uint32, str]:
	glValue = (
		GL_VERTEX_SHADER if(shader_type == "VERTEX_SHADER") else 
		GL_FRAGMENT_SHADER if(shader_type == "FRAGMENT_SHADER") else 
		GL_GEOMETRY_SHADER
	)

	result: str = ""
	shader = glCreateShader(glValue)
	glShaderSource(shader, source)
	glCompileShader(shader)

	success = glGetShaderiv(shader, GL_COMPILE_STATUS)
	if not success:
		info_log = glGetShaderInfoLog(shader)
		result += f"[ERROR] Shader compilation error:\n {info_log.decode()}"
		glDeleteShader(shader)
		return (nulluint32, result)

	if(shader): return (uint32(shader), result)
	glDeleteShader(shader)
	result += "[ERROR] Shader is null"
	return (nulluint32, result)