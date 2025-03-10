from .CompileShader import CompileShader
from .UploadShaderData import allowed_types_shader
from OpenGL.GL import *
from typing import Dict, List, Tuple, Literal, Optional
from numpy import uint32
import os
import re

nulluint32 = uint32(0)

import os


convert_shader_type = {
	'bool': 'bool',
	'int': 'int',
	'float': 'float',
	'vec2': 'vec2',
	'vec3': 'vec3',
	'vec4': 'vec4',
	'mat2': 'mat2',
	'mat3': 'mat3',
	'mat4': 'mat4',
	'sampler2D': 'Texture2D',
	'sampler3D': 'Texture3D'
}

def extract_material_attributes(shader_code: str) -> dict:
	# Паттерн для поиска структуры Material
	struct_pattern = re.compile(
		r'struct Material\s*\{([^}]*)\}\s*;',  # Ищем содержимое внутри {}
		re.DOTALL  # Учитываем переносы строк
	)
	
	match = struct_pattern.search(shader_code)
	if not match:
		return {}
	
	content = match.group(1).strip()
	attributes = {}
	
	# Разделяем поля по точкам с запятой
	for field in re.split(r';\s*', content):
		field = field.strip()
		if not field:
			continue
		
		# Разделяем тип и имя атрибута
		parts = field.split()
		if len(parts) >= 2:
			# Объединяем все части типа (на случай составных типов)
			attr_type = convert_shader_type.get(' '.join(parts[:-1]))
			if(attr_type is None): break
			attr_name = parts[-1]
			attributes[attr_name] = attr_type
	
	return attributes

def parse_shader_materials(shader_code: str) -> Tuple[int, Dict[str, allowed_types_shader]]:
	# Ищем блок буфера материалов с указанием binding
	buffer_regex = r"layout\s*\(.*?binding\s*=\s*(\d+).*?\)\s*buffer\s+Materials\s*{([^}]*)};"
	buffer_match = re.search(buffer_regex, shader_code, re.DOTALL)
	
	if not buffer_match: return -1, {}

	return int(buffer_match.group(1)), extract_material_attributes(shader_code)



def PreprocessShader(file_path: str, included_files=None) -> Tuple[str, str]:
	if included_files is None:
		included_files = set()
	try:
		with open(file_path, 'r') as f:
			content = f.read()
	except FileNotFoundError:
		return "", f"File not found: {file_path}"
	
	directory = os.path.dirname(file_path)
	lines = content.split('\n')
	processed = []
	error = ""
	
	for line in lines:
		line_stripped = line.strip()
		if line_stripped.startswith('#include'):
			parts = line_stripped.split('"')
			if len(parts) < 2:
				return "", f"Invalid include directive in {file_path}"
			include_file = parts[1]
			include_path = os.path.join(directory, include_file)
			
			if include_path in included_files:
				continue  # предотвращаем циклические включения
			included_files.add(include_path)
			
			included_source, include_error = PreprocessShader(include_path, included_files)
			if include_error:
				return "", include_error
			processed.append(included_source)
		else:
			processed.append(line)
	
	return '\n'.join(processed), ""



def CreateShader(paths: Dict[str, Literal['VERTEX_SHADER','GEOMETRY_SHADER','FRAGMENT_SHADER']]) -> Tuple[uint32, Tuple[int, Dict[str, allowed_types_shader]], str]:
	material = (-1, {})
	# Проверка существования основных файлов
	for path in paths.keys():
		if not os.path.exists(path):
			return (nulluint32, material, f"Shader file '{path}' not found.")

	shaders: List[Tuple[uint32, str]] = []
	preprocessing_errors = []
	
	# Препроцессинг и компиляция
	for path, typeShader in paths.items():
		source, error = PreprocessShader(path)
		if error:
			preprocessing_errors.append(error)
			continue
		
		compiled_shader = CompileShader(source, typeShader)
		shaders.append(compiled_shader)

	# Обработка ошибок препроцессинга
	if preprocessing_errors:
		for shader in shaders:
			if shader[0] != nulluint32:
				glDeleteShader(shader[0])
		return (nulluint32, material, "\n".join(preprocessing_errors))
	
	# Проверка ошибок компиляции
	log_error = ""
	for shader in shaders:
		if shader[0] == nulluint32:
			log_error += shader[1] + "\n"
		if log_error and shader[0] != nulluint32:
			glDeleteShader(shader[0])
	
	if log_error:
		return (nulluint32, material, log_error)
	
	# Создание шейдерной программы
	shader_program = glCreateProgram()
	for shader in shaders:
		glAttachShader(shader_program, shader[0])
	glLinkProgram(shader_program)
	
	# Удаление шейдеров
	for shader in shaders:
		glDeleteShader(shader[0])
	
	# Проверка линковки
	if not glGetProgramiv(shader_program, GL_LINK_STATUS):
		info_log = glGetProgramInfoLog(shader_program)
		glDeleteProgram(shader_program)
		return (nulluint32, material, info_log)
	
	for file_path in paths:
		with open(file_path, 'r') as f:
			m = parse_shader_materials(f.read())
			if(m[0] != -1): material = m

	return (uint32(shader_program), material, "")