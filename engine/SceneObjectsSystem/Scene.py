from .SceneInterface import SceneInterface
from .SceneSystem import SceneManagerSystem
from ..WindowSystem import WindowContextSystem
from ..Log import LogColors, PrintLog

class Scene(SceneInterface):

	__STATUS_REGITERED: bool = False

	__ID: int
	__STATUS_EXIST: bool
	__NAME: str

	__WINDOW_ID: int

	def __init_subclass__(cls, **kwargs):
		super().__init_subclass__(**kwargs)
		cls.__STATUS_REGITERED = SceneManagerSystem.RegisterScene(cls)

	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__NAME = f"{self.__class__.__name__}"

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		if(not self.__STATUS_REGITERED):
			PrintLog(f"can't create unregistred scene named {self.__NAME}", color= LogColors.RED)
			return

		self.__STATUS_EXIST = True
		PrintLog(f"{self.__NAME} Initialization", color= LogColors.GREEN)

		SceneManagerSystem.AppendScene(self, self.__WINDOW_ID)

		self.Load()
		self.Start()

	def __del__(self) -> None:
		PrintLog(f"{self.__NAME} deleted", color= LogColors.BLUE)

	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			self.Unload()
			SceneManagerSystem.RemoveScene(self, self.__WINDOW_ID)
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__NAME} Terminate", color= LogColors.YELLOW)

	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST
	
	def GetName(self) -> str:
		return self.__NAME