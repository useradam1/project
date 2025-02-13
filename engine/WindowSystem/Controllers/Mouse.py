from ...Math import vec2, vec2_ptr_static
from ...ApiWindow import SetCallbackMousePosition, GetMousePosition, window_type
from ..WindowContext import WindowContextSystem
from typing import Dict




class data:

	__POSITION: vec2

	def __init__(self) -> None:
		self.__POSITION = vec2()
		window = WindowContextSystem.GetCurrentWindow().GetWindowObject() # type: ignore
		SetCallbackMousePosition(window, self.__CallbackPosition) # type: ignore
		self.__POSITION.x, self.__POSITION.y = GetMousePosition(window) # type: ignore
		from ...Log import LogColors, PrintLog
		PrintLog("Mouse Initialization", color= LogColors.GREEN)

	def __del__(self) -> None:
		from ...Log import LogColors, PrintLog
		PrintLog("Mouse deleted", color= LogColors.BLUE)


	def Destroy(self) -> None:
		SetCallbackMousePosition(WindowContextSystem.GetCurrentWindow().GetWindowObject(), None) # type: ignore
		from ...Log import LogColors, PrintLog
		PrintLog("Mouse Terminate", color= LogColors.YELLOW)

	def __CallbackPosition(self, window: window_type, x: int, y: int) -> None:
		self.__POSITION.x = x
		self.__POSITION.y = y
	
	def GetPosition(self) -> vec2:
		return self.__POSITION



class MouseSystem:

	__DATA: Dict[int, data] = {}
	__POSITION: Dict[int, vec2_ptr_static] = {}

	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__DATA[window_id] = data()
		cls.__POSITION[window_id] = vec2_ptr_static()
		cls.__POSITION[window_id].LinkVector(cls.__DATA[window_id].GetPosition())

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__POSITION[window_id].Unlink()
		cls.__POSITION.pop(window_id, None)
		cls.__DATA[window_id].Destroy()
		cls.__DATA.pop(window_id, None)
	
	@classmethod
	def GetPosition(cls, window_id: int) -> vec2:
		return cls.__POSITION.get(window_id, vec2())


class Mouse:

	@classmethod
	def GetPosition(cls) -> vec2:
		return MouseSystem.GetPosition(WindowContextSystem.GetCurrentWindowId())