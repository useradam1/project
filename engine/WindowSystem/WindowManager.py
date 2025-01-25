from .WindowInterface import IWindow
from .WindowContext import WindowContextSystem
from ..ApiWindow import ApiWindowInitialization, ApiWindowTerminate, GetCurrentTime, WindowPollEvents
from typing import List, Set



class WindowManagerSystem:

	__API_WINDOW_INITIALIZATION: bool = False

	__ENABLE_QUEUE_UPDATES: bool = True
	__QUEUE_CHANGE: bool = False
	__QUEUE_TO_APPEND: Set[IWindow] = set()
	__QUEUE_TO_REMOVE: Set[IWindow] = set()
	__WINDOWS: List[IWindow] = []

	__CAN_UPDATE_WINDOWS: bool = False

	@classmethod
	def GetWindows(cls) -> List[IWindow]:
		return cls.__WINDOWS

	@classmethod
	def CanUpdateWindows(cls) -> bool:
		return cls.__CAN_UPDATE_WINDOWS

	@classmethod
	def AppendWindow(cls, window: IWindow) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES): return False
		if(not cls.__API_WINDOW_INITIALIZATION): cls.__API_WINDOW_INITIALIZATION = ApiWindowInitialization()
		if(cls.__API_WINDOW_INITIALIZATION):
			cls.__QUEUE_TO_APPEND.add(window)
			cls.__QUEUE_CHANGE = True
			cls.__CAN_UPDATE_WINDOWS = True
			return True
		return False

	@classmethod
	def RemoveWindow(cls, window: IWindow) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES): return
		cls.__QUEUE_TO_REMOVE.add(window)
		cls.__QUEUE_CHANGE = True

	@classmethod
	def __CheckQueueChange(cls) -> None:
		if(not cls.__QUEUE_CHANGE): return
		cls.__QUEUE_CHANGE = False
		for window in cls.__QUEUE_TO_APPEND:
			cls.__WINDOWS.append(window)
		for window in cls.__QUEUE_TO_REMOVE:
			cls.__WINDOWS.remove(window)
		cls.__QUEUE_TO_APPEND.clear()
		cls.__QUEUE_TO_REMOVE.clear()
		cls.__CAN_UPDATE_WINDOWS = len(cls.__WINDOWS) > 0


	@classmethod
	def Tick(cls) -> None:
		cls.__CheckQueueChange()
		WindowPollEvents()
		for window in cls.__WINDOWS:
			WindowContextSystem.SetCurrentWindow(window.window)
			window.tick()
		cls.__WINDOWS.reverse()




	@classmethod
	def CleaningResources(cls) -> None:
		cls.__CheckQueueChange()
		cls.__ENABLE_QUEUE_UPDATES = False

		for window in cls.__WINDOWS:
			WindowContextSystem.SetCurrentWindow(window.window)
			window.destroy()
		cls.__WINDOWS.clear()
		cls.__QUEUE_TO_APPEND.clear()
		cls.__QUEUE_TO_REMOVE.clear()
		cls.__QUEUE_CHANGE = False

		cls.__ENABLE_QUEUE_UPDATES = True


		ApiWindowTerminate()
		cls.__API_WINDOW_INITIALIZATION = False
		cls.__CAN_UPDATE_WINDOWS = False



class WindowManager:

	@classmethod
	def GetWindows(cls) -> List[IWindow]:
		return WindowManagerSystem.GetWindows()