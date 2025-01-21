from OpenGL.GL import *
from dataclasses import dataclass
from typing import Union, Literal, Dict, List, Tuple, Callable
from numpy import int32, uint32

nulluint32 = uint32(0)

allowed_types_shader = Union[
	Literal['bool'],
	Literal['int'],
	Literal['float'],
	Literal['vec2'],
	Literal['vec3'],
	Literal['vec4'],
	Literal['mat2'],
	Literal['mat3'],
	Literal['mat4'],
	Literal['Texture2D'],
	Literal['Texture3D'],
	None
]



@dataclass
class ShaderUniform:
	location: int
	size: int
	typed: allowed_types_shader
@dataclass
class ShaderAttributes:
	location: int
	size: int
	typed: allowed_types_shader

nullvec2 = (0.0,0.0)
nullvec3 = (0.0,0.0,0.0)
nullvec4 = (0.0,0.0,0.0,0.0)

nullmat2 = (
	1.0 , 0.0 , 
	0.0 , 1.0
)
nullmat3 = (
	1.0 , 0.0 , 0.0 ,
	0.0 , 1.0 , 0.0 ,
	0.0 , 0.0 , 1.0
)
nullmat4 = (
	1.0 , 0.0 , 0.0 , 0.0 , 
	0.0 , 1.0 , 0.0 , 0.0 , 
	0.0 , 0.0 , 1.0 , 0.0 , 
	0.0 , 0.0 , 0.0 , 1.0
)

nulltexid = int32(0)

class ShaderData:

	ATTRIBUTES: Dict[str,ShaderAttributes]
	UNIFORMS: Dict[str,ShaderUniform]
	TEXTURE_ID: int
	__SHADER_DATA_CLEAR: Dict[allowed_types_shader,Callable[[str],bool]]



	def __init__(self) -> None:
		self.ATTRIBUTES = {}
		self.UNIFORMS = {}
		self.TEXTURE_ID = 0

		self.__SHADER_DATA_CLEAR={
			'Texture3D':self.SetUniformTexture3D_zeros,
			'Texture2D':self.SetUniformTexture2D_zeros,
			'int':self.SetUniformInt_zeros,
			'bool':self.SetUniformBool_zeros,
			'float':self.SetUniformFloat_zeros,
			'vec2':self.SetUniformVec2f_zeros,
			'vec3':self.SetUniformVec3f_zeros,
			'vec4':self.SetUniformVec4f_zeros,
			'mat2':self.SetUniformMat2f_zeros,
			'mat3':self.SetUniformMat3f_zeros,
			'mat4':self.SetUniformMat4f_zeros,
		}
	
	def UploadShader(self, shader_target_id: uint32):
		if(shader_target_id==nulluint32): return
		self.ATTRIBUTES.clear()
		attrib_count = glGetProgramiv(shader_target_id, GL_ACTIVE_ATTRIBUTES)
		for i in range(attrib_count):
			name, size, type_data = glGetActiveAttrib(shader_target_id, i)
			location = glGetAttribLocation(shader_target_id, name)
			if location != -1:
				self.ATTRIBUTES[name.decode("utf-8").replace("[0]","")] = ShaderAttributes(location, size, get_type_name(type_data))
			del name, size, type_data, location
		del attrib_count

		self.UNIFORMS.clear()
		uniform_count = glGetProgramiv(shader_target_id, GL_ACTIVE_UNIFORMS)
		for i in range(uniform_count):
			name, size, type_data = glGetActiveUniform(shader_target_id, i)
			location = glGetUniformLocation(shader_target_id, name)
			if location != -1:
				self.UNIFORMS[name.decode("utf-8").replace("[0]","")] = ShaderUniform(location,size,get_type_name(type_data))
			del name, size, type_data, location
		del uniform_count

	def Clear(self):
		self.ATTRIBUTES.clear()
		self.UNIFORMS.clear()
		self.TEXTURE_ID = 0
	
	def ClearTextureId(self):
		self.TEXTURE_ID = 0

	def ClearUniform(self, nameValue:str):
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed): self.__SHADER_DATA_CLEAR[uniform.typed](nameValue)


	def SetUniformTexture3D_one(self, nameValue: str, value: uint32) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if (uniform.typed != 'Texture3D'): return False
		glActiveTexture(GL_TEXTURE0 + self.TEXTURE_ID)
		glBindTexture(GL_TEXTURE_3D, value)
		glUniform1i(uniform.location, self.TEXTURE_ID)
		self.TEXTURE_ID += 1
		del uniform
		return True
	def SetUniformTexture3D_many(self, nameValue: str, value: List[uint32]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if (uniform.typed != 'Texture3D'): return False
		lenv = len(value)
		textures: List[int] = []
		lastsTexId = self.TEXTURE_ID
		flattened: List[uint32]
		if (lenv == uniform.size): 
			flattened = value
		else: 
			flattened = [(value[sublist] if (lenv > sublist) else nulluint32) for sublist in range(uniform.size)]
		for tex in flattened:
			glActiveTexture(GL_TEXTURE0 + self.TEXTURE_ID)
			glBindTexture(GL_TEXTURE_3D, tex)
			textures.append(self.TEXTURE_ID)
			self.TEXTURE_ID += 1
		glUniform1iv(uniform.location, uniform.size, textures)
		del uniform, lastsTexId, textures, flattened
		return True
	def SetUniformTexture3D_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if (uniform.typed != 'Texture3D'): return False
		lastsTexId = self.TEXTURE_ID
		for _ in range(uniform.size):
			glActiveTexture(GL_TEXTURE0 + self.TEXTURE_ID)
			glBindTexture(GL_TEXTURE_3D, nulluint32)
			self.TEXTURE_ID += 1
		textures = [i + lastsTexId for i in range(uniform.size)]
		glUniform1iv(uniform.location, uniform.size, textures)
		del uniform, lastsTexId, textures
		return True


	def SetUniformTexture2D_one(self, nameValue: str, value: uint32) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'Texture2D'): return False
		glActiveTexture(GL_TEXTURE0 + self.TEXTURE_ID)
		glBindTexture(GL_TEXTURE_2D, value)
		glUniform1i(uniform.location, self.TEXTURE_ID)
		self.TEXTURE_ID+=1
		del uniform
		return True
	def SetUniformTexture2D_many(self, nameValue: str, value: List[uint32]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'Texture2D'): return False
		lenv = len(value)
		textures: List[int] = []
		lastsTexId = self.TEXTURE_ID
		flattened: List[uint32]
		if(lenv == uniform.size): flattened = value
		else: flattened = [(value[sublist] if(lenv>sublist) else nulluint32) for sublist in range(uniform.size)]
		for tex in flattened:
			glActiveTexture(GL_TEXTURE0 + self.TEXTURE_ID)
			glBindTexture(GL_TEXTURE_2D, value[tex])
			textures.append(self.TEXTURE_ID)
			self.TEXTURE_ID+=1
		glUniform1iv(uniform.location, uniform.size, textures)
		del uniform, lastsTexId, textures, flattened
		return True
	def SetUniformTexture2D_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'Texture2D'): return False
		lastsTexId = self.TEXTURE_ID
		for _ in range(uniform.size):
			glActiveTexture(GL_TEXTURE0 + self.TEXTURE_ID)
			glBindTexture(GL_TEXTURE_2D, nulluint32)
			self.TEXTURE_ID+=1
		textures = [i+lastsTexId for i in range(uniform.size)]
		glUniform1iv(uniform.location, uniform.size, textures)
		del uniform, lastsTexId, textures
		return True


	def SetUniformInt_one(self, nameValue: str, value: int) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'int'): return False
		glUniform1i(uniform.location, value)
		del uniform
		return True
	def SetUniformInt_many(self, nameValue: str, value: List[int]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'int'): return False
		lenv = len(value)
		flattened: List[int]
		if(lenv == uniform.size): flattened = value
		else: flattened: List[int] = [(value[sublist] if(lenv>sublist) else 0) for sublist in range(uniform.size)]
		glUniform1iv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformInt_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'int'): return False
		glUniform1iv(uniform.location, uniform.size, [0]*uniform.size)
		del uniform
		return True


	def SetUniformBool_one(self, nameValue: str, value: bool) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'bool'): return False
		glUniform1i(uniform.location, value)
		del uniform
		return True
	def SetUniformBool_many(self, nameValue: str, value: List[bool]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'bool'): return False
		lenv = len(value)
		flattened: List[bool]
		if(lenv == uniform.size): flattened = value
		else: flattened = [(value[sublist] if(lenv>sublist) else False) for sublist in range(uniform.size)]
		glUniform1iv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformBool_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'bool'): return False
		glUniform1iv(uniform.location, uniform.size, [0]*uniform.size)
		del uniform
		return True


	def SetUniformFloat_one(self, nameValue: str, value: float) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'float'): return False
		glUniform1f(uniform.location, value)
		del uniform
		return True
	def SetUniformFloat_many(self, nameValue: str, value: List[float]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'float'): return False
		lenv = len(value)
		flattened: List[float]
		if(lenv == uniform.size): flattened = value
		else: flattened = [(value[sublist] if(lenv>sublist) else 0.0) for sublist in range(uniform.size)]
		glUniform1fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformFloat_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'float'): return False
		glUniform1fv(uniform.location, uniform.size, [0.0]*uniform.size)
		del uniform
		return True


	def SetUniformVec2f_one(self, nameValue: str, value: Tuple[float,float]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec2'): return False
		glUniform2fv(uniform.location, uniform.size, value)
		del uniform
		return True
	def SetUniformVec2f_many(self, nameValue: str, value: List[Tuple[float,float]]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec2'): return False
		lenv = len(value)
		flattened: List[float]
		if(lenv == uniform.size): flattened = [i for item in value for i in item]
		else: flattened = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else nullvec2)]
		glUniform2fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformVec2f_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec2'): return False
		glUniform2fv(uniform.location, uniform.size, nullvec2*uniform.size)
		del uniform
		return True


	def SetUniformVec3f_one(self, nameValue: str, value: Tuple[float,float,float]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec3'): return False
		glUniform3fv(uniform.location, uniform.size, value)
		del uniform
		return True
	def SetUniformVec3f_many(self, nameValue: str, value: List[Tuple[float,float,float]]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec3'): return False
		lenv = len(value)
		flattened: List[float]
		if(lenv == uniform.size): flattened = [i for item in value for i in item]
		else: flattened = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else nullvec3)]
		glUniform3fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformVec3f_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec3'): return False
		glUniform3fv(uniform.location, uniform.size, nullvec3*uniform.size)
		del uniform
		return True


	def SetUniformVec4f_one(self, nameValue: str, value: Tuple[float,float,float,float]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec4'): return False
		glUniform4fv(uniform.location, uniform.size, value)
		del uniform
		return True
	def SetUniformVec4f_many(self, nameValue: str, value: List[Tuple[float,float,float,float]]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec4'): return False
		lenv = len(value)
		flattened: List[float]
		if(lenv == uniform.size): flattened = [i for item in value for i in item]
		else: flattened = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else nullvec4)]
		glUniform4fv(uniform.location, uniform.size, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformVec4f_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'vec4'): return False
		glUniform4fv(uniform.location, uniform.size, nullvec4*uniform.size)
		del uniform
		return True


	def SetUniformMat2f_one(self, nameValue: str, value: Tuple[float,float,float,float]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat2'): return False
		glUniformMatrix2fv(uniform.location, uniform.size, GL_FALSE, value)
		del uniform
		return True
	def SetUniformMat2f_many(self, nameValue: str, value: List[Tuple[float,float,float,float]]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat2'): return False
		lenv = len(value)
		flattened: List[float]
		if(lenv == uniform.size): flattened = [i for item in value for i in item]
		else: flattened = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else nullmat2)]
		glUniformMatrix2fv(uniform.location, uniform.size, GL_FALSE, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformMat2f_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat2'): return False
		glUniformMatrix2fv(uniform.location, uniform.size, GL_FALSE, nullmat2*uniform.size)
		del uniform
		return True


	def SetUniformMat3f_one(self, nameValue: str, value: Tuple[float,float,float,float,float,float,float,float,float]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat3'): return False
		glUniformMatrix3fv(uniform.location, uniform.size, GL_FALSE, value)
		del uniform
		return True
	def SetUniformMat3f_many(self, nameValue: str, value: List[Tuple[float,float,float,float,float,float,float,float,float]]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat3'): return False
		lenv = len(value)
		flattened: List[float]
		if(lenv == uniform.size): flattened = [i for item in value for i in item]
		else: flattened = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else nullmat3)]
		glUniformMatrix3fv(uniform.location, uniform.size, GL_FALSE, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformMat3f_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat3'): return False
		glUniformMatrix3fv(uniform.location, uniform.size, GL_FALSE, nullmat3*uniform.size)
		del uniform
		return True


	def SetUniformMat4f_one(self, nameValue: str, value: Tuple[float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat4'): return False
		glUniformMatrix4fv(uniform.location, uniform.size, GL_FALSE, value)
		del uniform
		return True
	def SetUniformMat4f_many(self, nameValue: str, value: List[Tuple[float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float]]) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat4'): return False
		lenv = len(value)
		flattened: List[float]
		if(lenv == uniform.size): flattened = [i for item in value for i in item]
		else: flattened = [item for sublist in range(uniform.size) for item in (value[sublist] if(lenv>sublist) else nullmat4)]
		glUniformMatrix4fv(uniform.location, uniform.size, GL_FALSE, flattened)
		del uniform, flattened, lenv
		return True
	def SetUniformMat4f_zeros(self, nameValue: str) -> bool:
		uniform = self.UNIFORMS[nameValue]
		if(uniform.typed != 'mat4'): return False
		glUniformMatrix4fv(uniform.location, uniform.size, GL_FALSE, nullmat4*uniform.size)
		del uniform
		return True






def get_type_name(type_enum) -> allowed_types_shader:
	if type_enum == GL_BOOL:
		return 'bool'
	elif type_enum == GL_INT:
		return 'int'
	elif type_enum == GL_FLOAT:
		return 'float'
	elif type_enum == GL_FLOAT_VEC2:
		return 'vec2'
	elif type_enum == GL_FLOAT_VEC3:
		return 'vec3'
	elif type_enum == GL_FLOAT_VEC4:
		return 'vec4'
	elif type_enum == GL_FLOAT_MAT2:
		return 'mat2'
	elif type_enum == GL_FLOAT_MAT3:
		return 'mat3'
	elif type_enum == GL_FLOAT_MAT4:
		return 'mat4'
	elif type_enum == GL_SAMPLER_2D:
		return 'Texture2D'
	elif type_enum == GL_SAMPLER_3D:
		return 'Texture3D'
	else:
		return None