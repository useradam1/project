from ..UpdateInterface import UpdateInterface, IUpdate
from ..UpdateSystem import UpdateSystem
from typing import Callable, Optional




class Update(UpdateInterface):

	__ID: int
	__STATUS_EXIST: bool

	__ENABLED: bool
	__ACTION: Optional[Callable[[], None]]
	__HAS_ACTION: bool

	__IUPDATE: IUpdate

	def __init__(self, action: Optional[Callable[[], None]]) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False

		self.__ENABLED = True
		self.__ACTION = None
		self.__HAS_ACTION = False

		self.__IUPDATE = IUpdate( self, self.__Tick, self.Destroy, 0 )


		if(not UpdateSystem.AppendUpdate(self.__IUPDATE)):
			del self.__IUPDATE
			return


		self.__ACTION = action
		self.__HAS_ACTION = action is not None

		self.__STATUS_EXIST = True

	def __del__(self) -> None:
		print("Update deleted")


	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			UpdateSystem.RemoveUpdate(self.__IUPDATE)
			del self.__IUPDATE
			self.__ACTION = None
			self.__STATUS_EXIST = False


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
