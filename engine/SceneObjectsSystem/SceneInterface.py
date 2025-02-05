from abc import ABC, abstractmethod
from typing import Callable
from dataclasses import dataclass

class SceneInterface(ABC):

	@abstractmethod
	def Destroy(self) -> None: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...

	@abstractmethod
	def Load(self) -> None: ...
	@abstractmethod
	def Start(self) -> None: ...
	@abstractmethod
	def Unload(self) -> None: ...


@dataclass(frozen=True)
class IScene:
	name: str
	load: Callable[[],None]
	start: Callable[[],None]
	unload: Callable[[],None]
	destroy: Callable[[],None]