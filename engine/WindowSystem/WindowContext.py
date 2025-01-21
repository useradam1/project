from .WindowInterface import WindowInterface
from ..ApiWindow import SetCurrentContextWindow
from typing import Optional


class WindowContext:

	__CURRENT_WINDOW: Optional[WindowInterface] = None

	@classmethod
	def GetCurrentWindow(cls) -> Optional[WindowInterface]:
		return cls.__CURRENT_WINDOW

	@classmethod
	def SetCurrentWindow(cls, window: Optional[WindowInterface]) -> None:
		if(cls.__CURRENT_WINDOW is window): return
		cls.__CURRENT_WINDOW = window
		if(window is None): SetCurrentContextWindow(None)
		else: SetCurrentContextWindow(window.GetWindowObject())
