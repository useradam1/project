from .WindowContext import WindowContextSystem
from ..ApiWindow import ApiWindowInitialization, ApiWindowTerminate, GetCurrentTime, WindowPollEvents
from typing import List, Set, Callable


from dataclasses import dataclass
@dataclass(frozen=True)
class IWindow:
	tick: Callable[[], None]
	destroy: Callable[[], None]

class WindowManagerSystem:

	__API_WINDOW_INITIALIZATION: bool = False

	__ENABLE_QUEUE_UPDATES: bool = True
	__QUEUE_CHANGE: int = 0
	__QUEUE_TO_APPEND: Set[IWindow] = set()
	__QUEUE_TO_REMOVE: Set[IWindow] = set()
	__WINDOWS: List[IWindow] = []

	__CAN_UPDATE_WINDOWS: int = 1

	@classmethod
	def GetWindows(cls) -> List[IWindow]:
		return cls.__WINDOWS

	@classmethod
	def CanUpdateWindows(cls) -> bool:
		return not cls.__CAN_UPDATE_WINDOWS

	@classmethod
	def AppendWindow(cls, window: IWindow) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES): return False
		if(not cls.__API_WINDOW_INITIALIZATION): cls.__API_WINDOW_INITIALIZATION = ApiWindowInitialization()
		if(cls.__API_WINDOW_INITIALIZATION):
			cls.__QUEUE_TO_APPEND.add(window)
			cls.__QUEUE_CHANGE = 1
			cls.__CAN_UPDATE_WINDOWS = 0
			return True
		return False

	@classmethod
	def RemoveWindow(cls, window: IWindow) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES): return
		cls.__QUEUE_TO_REMOVE.add(window)
		cls.__QUEUE_CHANGE = 1

	@classmethod
	def __CheckQueueChange(cls) -> None:
		if(not cls.__QUEUE_CHANGE): return
		cls.__QUEUE_CHANGE = 0
		for window in cls.__QUEUE_TO_APPEND:
			cls.__WINDOWS.append(window)
		cls.__QUEUE_TO_APPEND.clear()
		for window in cls.__QUEUE_TO_REMOVE:
			cls.__WINDOWS.remove(window)
		cls.__QUEUE_TO_REMOVE.clear()
		cls.__CAN_UPDATE_WINDOWS = int(not len(cls.__WINDOWS) > 0)


	@classmethod
	def Tick(cls) -> None:
		cls.__CheckQueueChange()
		WindowPollEvents()
		for window in cls.__WINDOWS: window.tick()
		cls.__WINDOWS.reverse()




	@classmethod
	def CleaningResources(cls) -> None:
		cls.__CheckQueueChange()
		cls.__ENABLE_QUEUE_UPDATES = False

		for window in cls.__WINDOWS: window.destroy()
		cls.__WINDOWS.clear()
		cls.__QUEUE_TO_APPEND.clear()
		cls.__QUEUE_TO_REMOVE.clear()
		cls.__QUEUE_CHANGE = 0

		cls.__ENABLE_QUEUE_UPDATES = True


		WindowContextSystem.SetCurrentWindow(None)
		ApiWindowTerminate()
		cls.__API_WINDOW_INITIALIZATION = False
		cls.__CAN_UPDATE_WINDOWS = 1


