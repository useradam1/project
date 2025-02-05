from abc import ABC, abstractmethod
from typing import Callable
from ..Math import Transform
from .GameObjectInterface import GameObjectInterface, IGameObject
from ..CustomMetaclass import Protected

class ComponentInterface(ABC):

	@abstractmethod
	def Destroy(self) -> int: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...

	@abstractmethod
	def GetGameObjectId(self) -> int: ...


	@property
	@abstractmethod
	def transform(self) -> Transform: ...

	@property
	@abstractmethod
	def gameObject(self) -> GameObjectInterface: ...



from dataclasses import dataclass
@dataclass(frozen=True)
class IComponent:
	component: ComponentInterface
	id: int
	name: str
	initialization: Callable[[IGameObject], None]
	getGameObjectId: Callable[[], int]
	destroy: Callable[[], int]