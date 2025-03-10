from ..UpdateSystem import UpdateManagerSystem, IUpdate
from ...WindowSystem import WindowContextSystem
from typing import Callable, Optional

from ...Log import LogColors, PrintLog



class LateUpdate:

	__ID: int
	__STATUS_EXIST: bool

	__ENABLED: bool
	__ACTION: Optional[Callable[[], None]]
	__HAS_ACTION: bool

	__WINDOW_ID: int
	__IUPDATE: IUpdate


	def __init__(self, action: Optional[Callable[[], None]]) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False

		self.__ENABLED = True
		self.__ACTION = None
		self.__HAS_ACTION = False

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		self.__IUPDATE = IUpdate(self.__Tick, self.Destroy, 1)

		if(not UpdateManagerSystem.AppendUpdate(self.__IUPDATE, self.__WINDOW_ID)):
			del self.__IUPDATE
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return


		self.__ACTION = action
		self.__HAS_ACTION = action is not None

		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)


	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			UpdateManagerSystem.RemoveUpdate(self.__IUPDATE, self.__WINDOW_ID)
			del self.__IUPDATE
			self.__WINDOW_ID = 0
			self.__ACTION = None
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	def GetAction(self) -> Optional[Callable[[], None]]:
		return self.__ACTION

	def SetAction(self, action: Optional[Callable[[], None]]) -> None:
		self.__ACTION = action
		self.__HAS_ACTION = action is not None
	
	def HasAction(self) -> bool:
		return self.__HAS_ACTION


	@property
	def enabled(self) -> bool:
		return self.__ENABLED
	@enabled.setter
	def enabled(self, value: bool) -> None:
		self.__ENABLED = value


	def __Tick(self, delta_time: float) -> None:
		if(self.__ENABLED and self.__HAS_ACTION):
			self.__ACTION()	# type: ignore
