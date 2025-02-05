from .SceneInterface import SceneInterface, IScene
from .SceneSystem import SceneManagerSystem
from ..Log import LogColors, PrintLog

class Scene(SceneInterface):

	__ID: int
	__STATUS_EXIST: bool

	__ISCENE: IScene

	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__ISCENE = IScene(
			name=f"{self.__class__.__name__}",
			load=self.Load,
			start=self.Start,
			unload=self.Unload,
			destroy=self.Destroy
		)
		if(not SceneManagerSystem.AppendScene(self.__ISCENE)):
			del self.__ISCENE
			return
		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			SceneManagerSystem.RemoveScene(self.__ISCENE)
			del self.__ISCENE
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)

	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST