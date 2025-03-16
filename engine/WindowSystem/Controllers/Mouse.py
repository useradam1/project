from ...Math import vec2, vec2_ptr_static
from ...ApiWindow import window_type, SetCallbackMousePosition, GetMousePosition, SetMousePosition
from ..WindowContext import WindowContextSystem
from typing import Dict, Optional


nullvec2 = vec2_ptr_static()


class data:

	__WINDOW: window_type
	__POSITION: vec2

	def __init__(self) -> None:
		self.__POSITION = vec2()
		self.__WINDOW = WindowContextSystem.GetCurrentWindow().GetWindowObject() # type: ignore
		SetCallbackMousePosition(self.__WINDOW, self.__CallbackPosition)
		self.__POSITION.x, self.__POSITION.y = GetMousePosition(self.__WINDOW)
		from ...Log import LogColors, PrintLog
		PrintLog("Mouse Initialization", color= LogColors.GREEN)

	def __del__(self) -> None:
		from ...Log import LogColors, PrintLog
		PrintLog("Mouse deleted", color= LogColors.BLUE)


	def Destroy(self) -> None:
		SetCallbackMousePosition(self.__WINDOW, None)
		from ...Log import LogColors, PrintLog
		PrintLog("Mouse Terminate", color= LogColors.YELLOW)

	def __CallbackPosition(self, window: window_type, x: int, y: int) -> None:
		self.__POSITION.x = x
		self.__POSITION.y = y
	
	def GetPosition(self) -> vec2:
		return self.__POSITION

	def SetPosition(self, x: int, y: int) -> None:
		SetMousePosition(self.__WINDOW, x, y)
		self.__POSITION.x = x
		self.__POSITION.y = y

	def SetPositionVector(self, postiton: vec2) -> None:
		x, y = int(postiton.x), int(postiton.y)
		SetMousePosition(self.__WINDOW, x, y)
		self.__POSITION.x = x
		self.__POSITION.y = y



class MouseSystem:

	__MOUSES: Dict[int, data] = {}
	__POSITION: Dict[int, vec2_ptr_static] = {}
	__CURRENT_MOUSES: Optional[data] = None
	__CURRENT_POSITION: Optional[vec2_ptr_static] = None

	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__MOUSES[window_id] = data()
		cls.__POSITION[window_id] = vec2_ptr_static()
		cls.__POSITION[window_id].LinkVector(cls.__MOUSES[window_id].GetPosition())
		cls.__CURRENT_MOUSES = cls.__MOUSES[window_id]
		cls.__CURRENT_POSITION = cls.__POSITION[window_id]

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__POSITION[window_id].UnlinkVector()
		cls.__POSITION.pop(window_id, None)
		cls.__MOUSES[window_id].Destroy()
		cls.__MOUSES.pop(window_id, None)
		cls.__CURRENT_MOUSES = None
		cls.__CURRENT_POSITION = None

	@classmethod
	def WindowUpdate(cls, window_id: int) -> None:
		cls.__CURRENT_MOUSES = cls.__MOUSES[window_id]
		cls.__CURRENT_POSITION = cls.__POSITION[window_id]
	
	@classmethod
	def GetPosition(cls) -> vec2:
		if(cls.__CURRENT_POSITION is None): return nullvec2
		return cls.__CURRENT_POSITION
	
	@classmethod
	def SetPosition(cls, x: int, y: int) -> None:
		if(cls.__CURRENT_MOUSES is None): return
		cls.__CURRENT_MOUSES.SetPosition(x,y)
	
	@classmethod
	def SetPositionVector(cls, postiton: vec2) -> None:
		if(cls.__CURRENT_MOUSES is None): return
		cls.__CURRENT_MOUSES.SetPositionVector(postiton)


class Mouse:

	@classmethod
	def GetPosition(cls) -> vec2:
		return MouseSystem.GetPosition()
	
	@classmethod
	def SetPosition(cls, x: int, y: int) -> None:
		MouseSystem.SetPosition(x,y)
	
	@classmethod
	def SetPositionVector(cls, position: vec2) -> None:
		MouseSystem.SetPositionVector(position)