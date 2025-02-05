from abc import ABC, abstractmethod
from typing import Callable, Optional
from dataclasses import dataclass



class UpdateInterface(ABC):

	@abstractmethod
	def Destroy(self) -> None: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...


	@abstractmethod
	def GetAction(self) -> Optional[Callable[[], None]]: ...

	@abstractmethod
	def SetAction(self, action: Optional[Callable[[], None]]) -> None: ...

	@abstractmethod
	def HasAction(self) -> bool: ...

	@property
	def enabled(self) -> bool: ...
	@enabled.setter
	def enabled(self, value: bool) -> None: ...



@dataclass(frozen=True)
class IUpdate:
	tick: Callable[[float], None]
	destroy: Callable[[], None]
	queue: int