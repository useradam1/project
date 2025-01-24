from .WindowInterface import WindowInterface
from ..ApiWindow import SetCurrentContextWindow
from typing import Optional


class WindowContextSystem:

	__CURRENT_WINDOW: Optional[WindowInterface] = None

	@classmethod
	def GetCurrentWindow(cls) -> Optional[WindowInterface]:
		return cls.__CURRENT_WINDOW

	@classmethod
	def SetCurrentWindow(cls, window: Optional[WindowInterface]) -> None:
		if(cls.__CURRENT_WINDOW is window): return
		if(window is None): 
			SetCurrentContextWindow(None)
			cls.__CURRENT_WINDOW = None
		else: 
			SetCurrentContextWindow(window.GetWindowObject())
			cls.__CURRENT_WINDOW = window


class WindowContext:

	@classmethod
	def GetCurrentWindow(cls) -> Optional[WindowInterface]:
		return WindowContextSystem.GetCurrentWindow()