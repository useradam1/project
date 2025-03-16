from ...Math import vec2, vec2_ptr_static
from ...ApiWindow import window_type
from ...ApiWindow import SetCallbackKeyBoardButton, GetKeyButtonName, funcyionalKeyBoardKeys
from ..WindowContext import WindowContextSystem
from typing import Dict, Optional

from ...Log import LogColors, PrintLog



class data:

	__PRESSED_KEYS: Dict[str,bool] = {}

	def __init__(self) -> None:
		window = WindowContextSystem.GetCurrentWindow().GetWindowObject() # type: ignore
		SetCallbackKeyBoardButton(window, self.__callback) # type: ignore
		PrintLog("Mouse Initialization", color= LogColors.GREEN)

	def __callback(self, window: window_type, x: int, y: int, z: int, w: int) -> None:
		self.__PRESSED_KEYS[GetKeyButtonName(x)] = bool(z)

	def __del__(self) -> None:
		PrintLog("Mouse deleted", color= LogColors.BLUE)

	def Destroy(self) -> None:
		SetCallbackKeyBoardButton(WindowContextSystem.GetCurrentWindow().GetWindowObject(), None) # type: ignore
		PrintLog("Mouse Terminate", color= LogColors.YELLOW)

	def GetKey(self, key: str) -> bool:
		return self.__PRESSED_KEYS.get(key, False)




class KeyboardSystem:

	__KEYBOARDS: Dict[int, data] = {}

	__CURRENT_KEYBOARD: Optional[data] = None

	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__KEYBOARDS[window_id] = data()
		cls.__CURRENT_KEYBOARD = cls.__KEYBOARDS[window_id]

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__KEYBOARDS[window_id].Destroy()
		cls.__KEYBOARDS.pop(window_id, None)
		cls.__CURRENT_KEYBOARD = None

	@classmethod
	def WindowUpdate(cls, window_id: int) -> None:
		cls.__CURRENT_KEYBOARD = cls.__KEYBOARDS[window_id]

	@classmethod
	def GetKey(cls, key: str) -> bool:
		if(cls.__CURRENT_KEYBOARD is None): return False
		return cls.__CURRENT_KEYBOARD.GetKey(key)

	@classmethod
	def GetFunctionalKey(cls, key: funcyionalKeyBoardKeys) -> bool:
		if(cls.__CURRENT_KEYBOARD is None): return False
		return cls.__CURRENT_KEYBOARD.GetKey(key)


class KeyBoard:


	@classmethod
	def GetKey(cls, key: str) -> bool:
		return KeyboardSystem.GetKey(key)

	@classmethod
	def GetFunctionalKey(cls, key: funcyionalKeyBoardKeys) -> bool:
		return KeyboardSystem.GetFunctionalKey(key)