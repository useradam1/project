from abc import ABC, abstractmethod
from typing import Optional, Callable
from ..ApiWindow import window_type
from ..Math import vec2
from dataclasses import dataclass


class WindowInterface(ABC):

	@abstractmethod
	def Destroy(self) -> None: ...



	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...

	@abstractmethod
	def GetWindowObject(self) -> Optional[window_type]: ...


	@abstractmethod
	def InFocus(self) -> bool: ...


	@abstractmethod
	def GetIsResizeable(self) -> bool: ...
	@abstractmethod
	def SetIsResizeable(self, value: bool) -> None: ...

	@abstractmethod
	def GetTitle(self) -> str: ...
	@abstractmethod
	def SetTitle(self, title: str) -> None: ...

	@abstractmethod
	def GetSize(self) -> vec2: ...
	@abstractmethod
	def SetSize(self, width: int, height: int) -> None: ...

	@abstractmethod
	def GetPosition(self) -> vec2: ...
	@abstractmethod
	def SetPosition(self, x: int, y: int) -> None: ...

	@abstractmethod	
	def GetFrameRate(self) -> int: ...
	@abstractmethod
	def SetFrameRate(self, frame_rate: int) -> None: ...

	@abstractmethod	
	def GetCurrentFrameRate(self) -> float: ...





@dataclass(frozen=True)
class IWindow:
	tick: Callable[[], None]
	destroy: Callable[[], None]