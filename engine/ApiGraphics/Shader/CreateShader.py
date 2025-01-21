from .CompileShader import CompileShader
from OpenGL.GL import *
from typing import Dict, List, Tuple, Literal
from numpy import uint32
import os

nulluint32 = uint32(0)

def CreateShader(paths: Dict[str,Literal['VERTEX_SHADER','GEOMETRY_SHADER','FRAGMENT_SHADER']]) -> Tuple[uint32,str]:
	# Проверяем существование всех файлов шейдеров
	for path in paths.keys():
		if not os.path.exists(path):
			return (nulluint32, f"[ERROR] Path to shader '{path}' does not exist.")

	shaders: List[Tuple[uint32, str]] = []

	for path, typeShader in paths.items():
		with open(path, 'r') as f:
			shaders.append(CompileShader(f.read(), typeShader))


	log_error = ""
	for shader in shaders:
		if(shader[0] == nulluint32):
			log_error += shader[1] + "\n"
		if(log_error and shader[0] != nulluint32):
			glDeleteShader(shader[0])
	if(log_error):
		del shaders
		return (nulluint32, log_error)
	del log_error
	

	# Создаем шейдерную программу
	shader_program = glCreateProgram()
	for shader in shaders:
		glAttachShader(shader_program, shader[0])
	glLinkProgram(shader_program)

	# Удаляем шейдеры, т.к. они уже не нужны
	for i in shaders:
		glDeleteShader(i[0])
	del shaders

	# Проверяем, слинковалась ли шейдерная программа
	ok = glGetProgramiv(shader_program, GL_LINK_STATUS)
	if not ok:
		info_log = glGetProgramInfoLog(shader_program)
		glDeleteProgram(shader_program)
		return (nulluint32, info_log)
	
	if(shader_program): return (uint32(shader_program), "")
	glDeleteProgram(shader_program)
	return (nulluint32, "[ERROR] Something has happened!")