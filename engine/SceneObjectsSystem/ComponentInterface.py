from abc import ABC, abstractmethod

class ComponentInterface(ABC):

	@abstractmethod
	def Destroy(self) -> int: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...


	@abstractmethod
	def GetGameObjectId(self) -> int: ...

