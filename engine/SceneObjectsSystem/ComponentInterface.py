from abc import ABC, abstractmethod
from ..CustomMetaclass import Protected

class ComponentInterface(ABC):

	@Protected
	@abstractmethod
	def Destroy(self) -> int: ...


	@Protected
	@abstractmethod
	def GetId(self) -> int: ...

	@Protected
	@abstractmethod
	def GetStatusExist(self) -> bool: ...


	@Protected
	@abstractmethod
	def GetGameObjectId(self) -> int: ...

