from numpy import dtype, float32, ndarray, int32, array, uint32
from typing import Dict, List, Type, Union, Literal
import ctypes
from typing import Tuple
from OpenGL.GL import *
import os

glCheckError = None

def __compile_shader(source: str, shader_type) -> Tuple[str,int]:
	result: str = ""
	shader = glCreateShader(shader_type)
	glShaderSource(shader, source)
	glCompileShader(shader)

	success = glGetShaderiv(shader, GL_COMPILE_STATUS)
	if not success:
		info_log = glGetShaderInfoLog(shader)
		result += f"Shader compilation error:\n {info_log.decode()}"
		return (result,-1)

	if isinstance(shader, int): return (result,shader)
	result += f"Shader compilation error"
	return (result,-1)

def destroyShader(program:int) -> None:
	glDeleteProgram(GLuint(program))
	del program


def destroyTexture(textureId:int) -> None:
	glDeleteTextures(1, int(textureId))
	del textureId

def loadMesh(
	Vertices:ndarray[float32,dtype[float32]],
	Uvs:ndarray[float32,dtype[float32]],
	Normals:ndarray[float32,dtype[float32]],
	Faces:ndarray[int32,dtype[int32]],
) -> Tuple[str,Tuple[uint32,uint32,bool,uint32,uint32,uint32,int]]:
	__result: str = ""

	try:
		# VAO
		__VAO: uint32 = glGenVertexArrays(1)
		glBindVertexArray(__VAO)

		# vertexVBO
		__vertexVBO: uint32 = glGenBuffers(1)
		glBindBuffer(GL_ARRAY_BUFFER, __vertexVBO)
		glBufferData(GL_ARRAY_BUFFER, Vertices.nbytes, Vertices, GL_STATIC_DRAW)
		glVertexAttribPointer(0, 3, GL_FLOAT, False, 0, None)
		glEnableVertexAttribArray(0)

		__UVSbool : bool = len(Uvs)==len(Vertices)
		__uvsVBO: uint32 = uint32(0)
		# uvsVBO
		if(__UVSbool):
			__uvsVBO = glGenBuffers(1)
			glBindBuffer(GL_ARRAY_BUFFER, __uvsVBO)
			glBufferData(GL_ARRAY_BUFFER, Uvs.nbytes, Uvs, GL_STATIC_DRAW)
			glVertexAttribPointer(1, 2, GL_FLOAT, False, 0, None)
			glEnableVertexAttribArray(1)

		# normalVBO
		__normalVBO: uint32 = glGenBuffers(1)
		glBindBuffer(GL_ARRAY_BUFFER, __normalVBO)
		glBufferData(GL_ARRAY_BUFFER, Normals.nbytes, Normals, GL_STATIC_DRAW)
		glVertexAttribPointer(2, 3, GL_FLOAT, False, 0, None)
		glEnableVertexAttribArray(2)

		# EBO
		__indexEBO: uint32 = glGenBuffers(1)
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, __indexEBO)
		glBufferData(GL_ELEMENT_ARRAY_BUFFER, Faces.nbytes, Faces, GL_STATIC_DRAW)

		#end
		glBindVertexArray(0)
		glBindBuffer(GL_ARRAY_BUFFER, 0)
		glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)
		__lenT: int = len(Faces) * 3

		return __result, (__VAO, __vertexVBO, __UVSbool, __uvsVBO, __normalVBO, __indexEBO, __lenT)
	except Exception as err:
		__result = f"{err}"
		d = uint32(0)
		return __result, (d,d,False,d,d,d,0)

def destroyMesh(
		__VAO:uint32,
		__vertexVBO:uint32,
		__UVSbool:bool,
		__uvsVBO:uint32,
		__normalVBO:uint32,
		__indexEBO:uint32,
	) -> None:
	# Delete VAO
	glDeleteVertexArrays(1, array([__VAO], dtype=uint32))
	
	# Delete VBOs
	glDeleteBuffers(1, array([__vertexVBO], dtype=uint32))
	if __UVSbool:
		glDeleteBuffers(1, array([__uvsVBO], dtype=uint32))
	glDeleteBuffers(1, array([__normalVBO], dtype=uint32))
	
	# Delete EBO
	glDeleteBuffers(1, array([__indexEBO], dtype=uint32))

	#glDeleteBuffers(1, array([__vertexVBO], dtype=float32))
	#if(__UVSbool):
	#	glDeleteBuffers(1, array([__uvsVBO], dtype=float32))
	#glDeleteBuffers(1, array([__normalVBO], dtype=float32))
	#glDeleteBuffers(1, array([__indexEBO], dtype=int32))
	#glDeleteVertexArrays(1, array([__VAO], dtype=int32))


def setUpGraphicsApi():
	glFrontFace(GL_CW)




class DepthTestMode:
	def __enter__(self):
		# Включить тест глубины
		glEnable(GL_DEPTH_TEST)
		glDepthMask(GL_TRUE)
		return self

	def __exit__(self, exc_type, exc_val, exc_tb):
		# Отключить тест глубины
		glDepthMask(GL_TRUE)
		glDisable(GL_DEPTH_TEST)
		if exc_type:
			print(f"Exception type: {exc_type}")
			print(f"Exception value: {exc_val}")
			print(f"Traceback: {exc_tb}")
			# Вернуть True, чтобы подавить исключение, иначе False
			return True

	def depthFunctionLess(self):
		'''<'''
		glDepthFunc(GL_LESS)

	def depthFunctionLEqual(self):
		'''<='''
		glDepthFunc(GL_LEQUAL)

	def depthFunctionGreater(self):
		'''>'''
		glDepthFunc(GL_GREATER)

	def depthFunctionGEqual(self):
		'''>='''
		glDepthFunc(GL_GEQUAL)

	def depthMaskEnabled(self):
		'''Включить запись в буфер глубины'''
		glDepthMask(GL_TRUE)

	def depthMaskDisabled(self):
		'''Отключить запись в буфер глубины'''
		glDepthMask(GL_FALSE)

	def clearDepthBuffer(self, value: float):
		'''Очистить буфер глубины заданным значением value от 0.0 (ближе к камере), до 1.0 (дальше от камеры)'''
		glClearDepth(value)
		glClear(GL_DEPTH_BUFFER_BIT)



class CullFaceMode:
	def __enter__(self):
		glEnable(GL_CULL_FACE)
		return self

	def __exit__(self, exc_type, exc_val, exc_tb):
		glDisable(GL_CULL_FACE)
		if exc_type:
			print(f"Exception type: {exc_type}")
			print(f"Exception value: {exc_val}")
			print(f"Traceback: {exc_tb}")
        # Верните True, если хотите подавить исключение, иначе верните False
		return True  # Если вернуть False, исключение будет дальше передаваться

	def frontAndBackModeDraw(self):
		glDisable(GL_CULL_FACE)
	def frontModeDraw(self):
		glCullFace(GL_FRONT)
	def backModeDraw(self):
		glCullFace(GL_BACK)



def drawMesh(
		__VAO:uint32,
		__lenT:int
	) -> None:
	glBindVertexArray(__VAO)
	glDrawElements(GL_TRIANGLES, __lenT, GL_UNSIGNED_INT, None)
	glBindVertexArray(0)

def rectangleRender() -> None:
	glBegin(GL_QUADS)
	glVertex2f(-0.5, -0.5)
	glVertex2f(0.5, -0.5)
	glVertex2f(0.5, 0.5)
	glVertex2f(-0.5, 0.5)
	glEnd()
	glFlush()

def clearColorSurface() -> None:
	glClear(GL_COLOR_BUFFER_BIT)

def clearDepthSurface() -> None:
	glClear(GL_DEPTH_BUFFER_BIT)

def SetViewport(width:int,height:int) -> None:
	glViewport(0,0,width,height)



def createFramebuffer(width:int, height:int) -> Tuple[str,int,int,int]:
	__result: str = ""

	# Создание фреймбуфера
	fbo:int = glGenFramebuffers(1)
	glBindFramebuffer(GL_FRAMEBUFFER, fbo)



	# Создание текстуры для фреймбуфера
	texture:int = glGenTextures(1)
	glBindTexture(GL_TEXTURE_2D, texture)
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, None)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_LOD, 0)  # Установить минимальный уровень детализации
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LOD, 0)  # Установить максимальный уровень детализации
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, 0)  # Установить смещение уровня детализации
	glBindTexture(GL_TEXTURE_2D, 0)
	glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, texture, 0)



	# Создание рендербуфера для глубины и трафарета
	rbo:int = glGenRenderbuffers(1)
	glBindRenderbuffer(GL_RENDERBUFFER, rbo)
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height)
	glBindRenderbuffer(GL_RENDERBUFFER, 0)
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo)


	# Проверка статуса framebuffer
	if glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE:
		__result += "Framebuffer is not complete!"
		destroyFramebuffer(fbo, texture, rbo)
		return __result,-1,-1,-1

	clearColorSurface()
	clearDepthSurface()
	glBindFramebuffer(GL_FRAMEBUFFER, 0)

	return __result, fbo, texture, rbo

def destroyFramebuffer(fbo:int, texture:int, rbo:int):
	glDeleteFramebuffers(1, [fbo])
	glDeleteTextures(1, [texture])
	glDeleteRenderbuffers(1, [rbo])

def bindFramebuffer(fbo: int) -> None:
	glBindFramebuffer(GL_FRAMEBUFFER, fbo)




allowed_types_shader = Union[Literal['bool'],Literal['int'],Literal['float'],Literal['vec2f'],Literal['vec3f'],Literal['vec4f'],Literal['mat2f'],Literal['mat3f'],Literal['mat4f'],Literal['Texture'],None]



class ShaderUniform:
	def __init__(self, location:int, size:int, typed:allowed_types_shader) -> None:
		self.location: int = location
		self.size: int = size
		self.typed: allowed_types_shader = typed
class ShaderAttributes:
	def __init__(self, location:int, size:int, typed:allowed_types_shader) -> None:
		self.location: int = location
		self.size: int = size
		self.typed: allowed_types_shader = typed
class ShaderData:
	def __init__(self) -> None:
		self.attributes: Dict[str,ShaderAttributes] = {}
		self.uniforms: Dict[str,ShaderUniform] = {}
		self.texId: int32 = int32(0)

		self.__voidVec2 = (0.0,0.0)
		self.__voidVec3 = (0.0,0.0,0.0)
		self.__voidVec4 = (0.0,0.0,0.0,0.0)

		self.__voidMat2 = (1.0,0.0 , 0.0,1.0)
		self.__voidMat3 = (1.0,0.0,0.0  ,0.0,1.0,0.0 , 0.0,0.0,1.0)
		self.__voidMat4 = (1.0,0.0,0.0,0.0 , 0.0,1.0,0.0,0.0 , 0.0,0.0,1.0,0.0 , 0.0,0.0,0.0,1.0)

		self.__shaderDataClear={
			'Texture':self.setUniformTexture_zeros,
			'int':self.setUniformInt_zeros,
			'bool':self.setUniformBool_zeros,
			'float':self.setUniformFloat_zeros,
			'vec2f':self.setUniformVec2f_zeros,
			'vec3f':self.setUniformVec3f_zeros,
			'vec4f':self.setUniformVec4f_zeros,
			'mat2f':self.setUniformMat2f_zeros,
			'mat3f':self.setUniformMat3f_zeros,
			'mat4f':self.setUniformMat4f_zeros,
		}


	def clearUniform(self, nameValue:str):
		uniform = self.uniforms[nameValue]
		if(uniform.typed): self.__shaderDataClear[uniform.typed](nameValue)


	def setUniformTexture_one(self, nameValue: str, value: int) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'Texture'): return False
		glActiveTexture(GL_TEXTURE0 + self.texId)
		glBindTexture(GL_TEXTURE_2D, value)
		glUniform1i(uniform.location, self.texId)
		self.texId+=1
		del uniform
		return True
	def setUniformTexture_many(self, nameValue: str, value: List[int]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'Texture'): return False
		lenv = len(value)
		textures: List[int32] = []
		lastsTexId : int32 = self.texId
		flattened: List[int] = [(value[sublist] if(lenv>sublist) else 0) for sublist in range(uniform.size)]
		for tex in flattened:
			glActiveTexture(GL_TEXTURE0+self.texId)
			glBindTexture(GL_TEXTURE_2D, value[tex])
			textures.append(self.texId)
			self.texId+=1
		glUniform1iv(uniform.location, uniform.size, textures)
		del uniform, lastsTexId, textures, flattened
		return True
	def setUniformTexture_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'Texture'): return False
		lastsTexId : int32 = self.texId
		for _ in range(uniform.size):
			glActiveTexture(GL_TEXTURE0+self.texId)
			glBindTexture(GL_TEXTURE_2D, 0)
			self.texId+=1
		textures = [i+lastsTexId for i in range(uniform.size)]
		glUniform1iv(uniform.location, uniform.size, textures)
		del uniform, lastsTexId, textures
		return True


	def setUniformInt_one(self, nameValue: str, value: int) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'int'): return False
		glUniform1i(uniform.location, value)
		del uniform
		return True
	def setUniformInt_many(self, nameValue: str, value: List[int]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'int'): return False
		lenv = len(value)
		flattened: List[int] = [(value[sublist] if(lenv>sublist) else 0) for sublist in range(uniform.size)]
		glUniform1iv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformInt_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'int'): return False
		glUniform1iv(uniform.location, uniform.size, [0]*uniform.size)
		del uniform
		return True


	def setUniformBool_one(self, nameValue: str, value: bool) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'bool'): return False
		glUniform1i(uniform.location, value)
		del uniform
		return True
	def setUniformBool_many(self, nameValue: str, value: List[bool]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'bool'): return False
		lenv = len(value)
		flattened: List[bool] = [(value[sublist] if(lenv>sublist) else False) for sublist in range(uniform.size)]
		glUniform1iv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformBool_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'bool'): return False
		glUniform1iv(uniform.location, uniform.size, [0]*uniform.size)
		del uniform
		return True


	def setUniformFloat_one(self, nameValue: str, value: float) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'float'): return False
		glUniform1f(uniform.location, value)
		del uniform
		return True
	def setUniformFloat_many(self, nameValue: str, value: List[float]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'float'): return False
		lenv = len(value)
		flattened: List[float] = [(value[sublist] if(lenv>sublist) else 0.0) for sublist in range(uniform.size)]
		glUniform1fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformFloat_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'float'): return False
		glUniform1fv(uniform.location, uniform.size, [0.0]*uniform.size)
		del uniform
		return True


	def setUniformVec2f_one(self, nameValue: str, value: Tuple[float,float]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec2f'): return False
		glUniform2fv(uniform.location, uniform.size, value)
		del uniform
		return True
	def setUniformVec2f_many(self, nameValue: str, value: List[Tuple[float,float]]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec2f'): return False
		lenv = len(value)
		flattened: List[float] = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else self.__voidVec2)]
		glUniform2fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformVec2f_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec2f'): return False
		glUniform2fv(uniform.location, uniform.size, self.__voidVec2*uniform.size)
		del uniform
		return True


	def setUniformVec3f_one(self, nameValue: str, value: Tuple[float,float,float]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec3f'): return False
		glUniform3fv(uniform.location, uniform.size, value)
		del uniform
		return True
	def setUniformVec3f_many(self, nameValue: str, value: List[Tuple[float,float,float]]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec3f'): return False
		lenv = len(value)
		flattened: List[float] = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else self.__voidVec3)]
		glUniform3fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformVec3f_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec3f'): return False
		glUniform3fv(uniform.location, uniform.size, self.__voidVec3*uniform.size)
		del uniform
		return True


	def setUniformVec4f_one(self, nameValue: str, value: Tuple[float,float,float,float]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec4f'): return False
		glUniform4fv(uniform.location, uniform.size, value)
		del uniform
		return True
	def setUniformVec4f_many(self, nameValue: str, value: List[Tuple[float,float,float,float]]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec4f'): return False
		lenv = len(value)
		flattened: List[float] = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else self.__voidVec4)]
		glUniform4fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformVec4f_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'vec4f'): return False
		glUniform4fv(uniform.location, uniform.size, self.__voidVec4*uniform.size)
		del uniform
		return True


	def setUniformMat2f_one(self, nameValue: str, value: Tuple[float,float,float,float]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat2f'): return False
		glUniformMatrix2fv(uniform.location, uniform.size, GL_FALSE, value)
		del uniform
		return True
	def setUniformMat2f_many(self, nameValue: str, value: List[Tuple[float,float,float,float]]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat2f'): return False
		lenv = len(value)
		flattened: List[float] = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else self.__voidMat2)]
		glUniformMatrix2fv(uniform.location, uniform.size, GL_FALSE, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformMat2f_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat2f'): return False
		glUniformMatrix2fv(uniform.location, uniform.size, GL_FALSE, self.__voidMat2*uniform.size)
		del uniform
		return True


	def setUniformMat3f_one(self, nameValue: str, value: Tuple[float,float,float,float,float,float,float,float,float]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat3f'): return False
		glUniformMatrix3fv(uniform.location, uniform.size, GL_FALSE, value)
		del uniform
		return True
	def setUniformMat3f_many(self, nameValue: str, value: List[Tuple[float,float,float,float,float,float,float,float,float]]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat3f'): return False
		lenv = len(value)
		flattened: List[float] = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else self.__voidMat3)]
		glUniformMatrix3fv(uniform.location, uniform.size, GL_FALSE, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformMat3f_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat3f'): return False
		glUniformMatrix3fv(uniform.location, uniform.size, GL_FALSE, self.__voidMat3*uniform.size)
		del uniform
		return True


	def setUniformMat4f_one(self, nameValue: str, value: Tuple[float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat4f'): return False
		glUniformMatrix4fv(uniform.location, uniform.size, GL_FALSE, value)
		del uniform
		return True
	def setUniformMat4f_many(self, nameValue: str, value: List[Tuple[float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float]]) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat4f'): return False
		lenv = len(value)
		flattened: List[float] = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else self.__voidMat4)]
		glUniformMatrix4fv(uniform.location, uniform.size, GL_FALSE, flattened)
		del uniform, flattened, lenv
		return True
	def setUniformMat4f_zeros(self, nameValue: str) -> bool:
		uniform = self.uniforms[nameValue]
		if(uniform.typed != 'mat4f'): return False
		glUniformMatrix4fv(uniform.location, uniform.size, GL_FALSE, self.__voidMat4*uniform.size)
		del uniform
		return True


def UseShaderProgram(targetId:int) -> None:
	glUseProgram(targetId)
	if(targetId == 0): glColor3f(1.0, 0.0, 1.0)


def GetShaderData(targetIdShader : int) -> ShaderData:
	output = ShaderData()

	if(targetIdShader == -1): return output

	attrib_count = glGetProgramiv(targetIdShader, GL_ACTIVE_ATTRIBUTES)
	uniform_count = glGetProgramiv(targetIdShader, GL_ACTIVE_UNIFORMS)

	for i in range(attrib_count):
		__name, __size, __type = glGetActiveAttrib(targetIdShader, i)
		location = glGetAttribLocation(targetIdShader, __name)
		if location != -1:
			output.attributes[__name.decode("utf-8")] = ShaderAttributes(location,__size,get_type_name(__type))

	for i in range(uniform_count):
		__name, __size, __type = glGetActiveUniform(targetIdShader, i)
		location = glGetUniformLocation(targetIdShader, __name)
		if location != -1:
			output.uniforms[__name.decode("utf-8")] = ShaderUniform(location,__size,get_type_name(__type))

	return output


def get_type_name(type_enum) -> allowed_types_shader:
	if type_enum == GL_BOOL:
		return 'bool'
	elif type_enum == GL_INT:
		return 'int'
	elif type_enum == GL_FLOAT:
		return 'float'
	elif type_enum == GL_FLOAT_VEC2:
		return 'vec2f'
	elif type_enum == GL_FLOAT_VEC3:
		return 'vec3f'
	elif type_enum == GL_FLOAT_VEC4:
		return 'vec4f'
	elif type_enum == GL_FLOAT_MAT2:
		return 'mat2f'
	elif type_enum == GL_FLOAT_MAT3:
		return 'mat3f'
	elif type_enum == GL_FLOAT_MAT4:
		return 'mat4f'
	elif type_enum == GL_SAMPLER_2D:
		return 'Texture'
	else:
		return None