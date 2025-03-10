from abc import ABC, abstractmethod
from typing import Dict, Literal, Tuple
from numpy import uint32
from ...ApiGraphics import ShaderData, allowed_types_shader


class ShaderInterface(ABC):

	@abstractmethod
	def Destroy(self) -> None: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...

	@abstractmethod
	def GetObject(self) -> uint32: ...

	@abstractmethod
	def GetLoadStatusGpu(self) -> bool: ...

	@abstractmethod
	def GetShaderData(self) -> ShaderData: ...


	@abstractmethod
	def LoadToGpu(self, value: Dict[str, Literal['VERTEX_SHADER','GEOMETRY_SHADER','FRAGMENT_SHADER']]) -> 'ShaderInterface': ...

	@abstractmethod
	def UnloadGpu(self) -> 'ShaderInterface': ...


	@abstractmethod
	def StartUseProgram(self) -> 'ShaderInterface': ...

	@abstractmethod
	def StopUseProgram(self) -> 'ShaderInterface': ...


	@abstractmethod
	def GetMaterialDescriptor(self) -> Tuple[int, Dict[str, allowed_types_shader]]: ...