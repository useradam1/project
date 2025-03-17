from abc import ABC, abstractmethod
from typing import Optional, Set, Type
from ..Math import Transform
from .ComponentType import ComponentType



class GameObjectInterface(ABC):

	@abstractmethod
	def Destroy(self) -> None: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...


	@abstractmethod
	def GetName(self) -> str: ...
	@abstractmethod
	def SetName(self, name: str) -> None: ...

	@abstractmethod
	def GetTag(self) -> str: ...
	@abstractmethod
	def SetTag(self, tag: str) -> None: ...


	@abstractmethod
	def SetParent(self, parent: Optional['GameObjectInterface']) -> None: ...

	@abstractmethod
	def GetParent(self) -> Optional['GameObjectInterface']: ...

	@abstractmethod
	def HasParent(self) -> bool: ...

	@abstractmethod
	def GetComponents(self, component_name: Type[ComponentType]) -> Set[ComponentType]: ...


	@property
	@abstractmethod
	def transform(self) -> Transform: ...



