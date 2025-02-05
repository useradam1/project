from abc import ABC, abstractmethod
from typing import Callable, Optional
from ..Math import Transform


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


	@property
	@abstractmethod
	def transform(self) -> Transform: ...




from dataclasses import dataclass
@dataclass(frozen=True)
class IGameObject:
	gameObject: GameObjectInterface
	id: int
	getName: Callable[[], str]
	getTag: Callable[[], str]
	destroy: Callable[[], None]