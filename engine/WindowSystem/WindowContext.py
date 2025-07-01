from .WindowInterface import WindowInterface
from ..ApiWindow import SetCurrentContextWindow
from typing import Optional


class WindowContextSystem:

	__CURRENT_WINDOW: Optional[WindowInterface] = None
	__CURRENT_WINDOW_ID: int = 0

	@classmethod
	def GetCurrentWindow(cls) -> Optional[WindowInterface]:
		return cls.__CURRENT_WINDOW

	@classmethod
	def GetCurrentWindowId(cls) -> int:
		return cls.__CURRENT_WINDOW_ID

	@classmethod
	def SetCurrentWindow(cls, window: Optional[WindowInterface]) -> None:
		if(cls.__CURRENT_WINDOW is window): return
		if(window is None): 
			SetCurrentContextWindow(None)
			cls.__CURRENT_WINDOW = None
			cls.__CURRENT_WINDOW_ID = 0
		else: 
			SetCurrentContextWindow(window.GetWindowObject())
			cls.__CURRENT_WINDOW = window
			cls.__CURRENT_WINDOW_ID = window.GetId()




class WindowContext:

	@classmethod
	def GetCurrentWindow(cls) -> Optional[WindowInterface]:
		return WindowContextSystem.GetCurrentWindow()

	@classmethod
	def GetCurrentWindowId(cls) -> int:
		return WindowContextSystem.GetCurrentWindowId()