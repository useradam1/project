from .Texture2D import Texture2D
from .Shader import Shader
from ...Math import *
from abc import ABC, abstractmethod
from typing import Union, Optional, Dict



allowed_type_uniform = Union[int, float, bool, vec2, vec3, vec4, mat2, mat3, mat4, Texture2D]



class MaterialInterface(ABC):


	@abstractmethod
	def Destroy(self) -> None: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...


	@abstractmethod
	def GetShader(self) -> Optional[Shader]: ...

	@abstractmethod
	def SetShader(self, shader: Optional[Shader]) -> 'MaterialInterface': ...


	@abstractmethod
	def GetRegisteredIndex(self) -> int: ...


	@abstractmethod
	def GetUniforms(self) -> Dict[str, allowed_type_uniform]: ...

	@abstractmethod
	def GetUniform(self, name_variable: str) -> Optional[allowed_type_uniform]: ...

	@abstractmethod
	def SetUniform(self, name_variable: str, data: allowed_type_uniform) -> 'MaterialInterface': ...

	@abstractmethod
	def DeleteUniform(self, name_variable: str) -> 'MaterialInterface': ...