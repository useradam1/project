from abc import ABC, abstractmethod
from typing import Optional, Callable
from ..ApiWindow import window_type
from ..Math import vec2_ptr_static

class WindowInterface(ABC):

	@abstractmethod
	def Destroy(self) -> None: ...

	@abstractmethod
	def ImmediateDestroy(self) -> None: ...


	@abstractmethod
	def GetId(self) -> int: ...

	@abstractmethod
	def GetStatusExist(self) -> bool: ...

	@abstractmethod
	def GetWindowObject(self) -> Optional[window_type]: ...


	@abstractmethod
	def GetTitle(self) -> str: ...
	@abstractmethod
	def SetTitle(self, title: str) -> None: ...

	@abstractmethod
	def GetSize(self) -> vec2_ptr_static: ...
	@abstractmethod
	def SetSize(self, width: int, height: int) -> None: ...

	@abstractmethod	
	def GetFrameRate(self) -> int: ...
	@abstractmethod
	def SetFrameRate(self, frame_rate: int) -> None: ...


	@abstractmethod
	def Tick(self, time: float) -> None: ...
