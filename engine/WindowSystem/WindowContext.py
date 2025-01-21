from .WindowInterface import WindowInterface
from ..ApiWindow import SetCurrentContextWindow
from typing import Optional

null_window = None

class WindowContext:

	__CURRENT_WINDOW: Optional[WindowInterface] = null_window

	@classmethod
	def GetCurrentWindow(cls) -> Optional[WindowInterface]:
		return cls.__CURRENT_WINDOW

	@classmethod
	def SetCurrentWindow(cls, window: Optional[WindowInterface]) -> None:
		if(cls.__CURRENT_WINDOW is window): return
		if(window is None): 
			SetCurrentContextWindow(null_window)
			cls.__CURRENT_WINDOW = null_window
		else: 
			SetCurrentContextWindow(window.GetWindowObject())
			cls.__CURRENT_WINDOW = window
