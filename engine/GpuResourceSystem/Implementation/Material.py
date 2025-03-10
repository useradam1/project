from .MaterialInterface import MaterialInterface
from .MaterialController import MaterialControllerSystem
from ...WindowSystem import WindowContextSystem

from .Texture2D import Texture2D
from .Shader import Shader
from ...Math import *

from typing import Dict, Union, Optional
from ...Log import LogColors, PrintLog



allowed_type_uniform = Union[int, float, bool, vec2, vec3, vec4, mat2, mat3, mat4, Texture2D]



class Material(MaterialInterface):

	__ID: int
	__STATUS_EXIST: bool

	__SHADER: Optional[Shader]
	__UNIFORMS: Dict[str, allowed_type_uniform]

	__WINDOW_ID: int


	def __init__(self, shader: Optional[Shader], uniform: Dict[str, allowed_type_uniform]) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__SHADER = shader
		self.__UNIFORMS = uniform

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		if(not MaterialControllerSystem.AppendMaterial(self, self.__WINDOW_ID)):
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return

		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

		if(self.__SHADER is None): return
		MaterialControllerSystem.AppendMaterialDescriptor(self, self.__SHADER.GetMaterialDescriptor(), self.__WINDOW_ID)

	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			if(self.__SHADER is not None):
				MaterialControllerSystem.RemoveMaterialDescriptor(self, self.__SHADER.GetMaterialDescriptor()[0], self.__WINDOW_ID)
			MaterialControllerSystem.RemoveMaterial(self, self.__WINDOW_ID)
			self.__SHADER = None
			self.__UNIFORMS.clear()
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST


	def GetShader(self) -> Optional[Shader]:
		return self.__SHADER

	def SetShader(self, shader: Optional[Shader]) -> 'Material':
		if(self.__SHADER is not None):
			MaterialControllerSystem.RemoveMaterialDescriptor(self, self.__SHADER.GetMaterialDescriptor()[0], self.__WINDOW_ID)
		self.__SHADER = shader
		if(self.__SHADER is None): return self
		MaterialControllerSystem.AppendMaterialDescriptor(self, self.__SHADER.GetMaterialDescriptor(), self.__WINDOW_ID)
		return self


	def GetRegisteredIndex(self) -> int:
		if(self.__SHADER is None): return -1
		return MaterialControllerSystem.GetRegisteredIndexOfMaterial(self.__SHADER.GetMaterialDescriptor()[0], self.__ID, self.__WINDOW_ID)


	def GetUniforms(self) -> Dict[str, allowed_type_uniform]:
		return self.__UNIFORMS

	def GetUniform(self, name_variable: str) -> Optional[allowed_type_uniform]:
		return self.__UNIFORMS.get(name_variable)

	def SetUniform(self, name_variable: str, data: allowed_type_uniform) -> 'Material':
		self.__UNIFORMS[name_variable] = data
		if(self.__SHADER is None): return self
		MaterialControllerSystem.UpdateMaterialDescriptor(self, self.__SHADER.GetMaterialDescriptor()[0], self.__WINDOW_ID)
		return self

	def DeleteUniform(self, name_variable: str) -> 'Material':
		self.__UNIFORMS.pop(name_variable, None)
		return self