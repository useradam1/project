from .ComponentInterface import ComponentInterface, IComponent
from .GameObjectInterface import GameObjectInterface, IGameObject
from .ComponentSystem import ComponentManagerSystem
from ..Log import LogColors, PrintLog
from ..CustomMetaclass import Protected
from ..Math import Transform
from ..WindowSystem import WindowContextSystem


class Component(ComponentInterface):

	__ID: int
	__STATUS_EXIST: bool
	__AWAKE: bool

	__WINDOW_ID: int
	__ICOMPONENT: IComponent

	__GAME_OBJECT_ID: int
	__GAME_OBJECT: GameObjectInterface
	__TRANSFORM: Transform

	@Protected
	def __Awake(self) -> bool:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__AWAKE = False
		self.__GAME_OBJECT_ID = 0

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog("Component cannot be created outside of the window context", color= LogColors.RED)
			return False

		self.__ICOMPONENT = IComponent(
			component= self,
			id= self.__ID,
			name= f"{self.__class__.__name__}",
			initialization= self.__Initialization,
			getGameObjectId= self.GetGameObjectId,
			destroy= self.Destroy
		)

		if(not ComponentManagerSystem.AppendComponent(self.__ICOMPONENT, self.__WINDOW_ID)):
			del self.__ICOMPONENT
			PrintLog("Component registration denied", color= LogColors.RED)
			return False

		self.__AWAKE = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)
		return True

	def __init__(self) -> None:
		if(not self.__Awake()): return


	@Protected
	def __Initialization(self, gameObject: IGameObject) -> None:
		#if(not self.__STATUS_EXIST):
		self.__GAME_OBJECT_ID = gameObject.id
		self.__GAME_OBJECT = gameObject.gameObject
		self.__TRANSFORM = gameObject.gameObject.transform
		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} new parent has been assigned", color= LogColors.GREEN)


	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)


	def Destroy(self) -> int:
		if(self.__AWAKE):
			self.__OnDestroy()
			ComponentManagerSystem.RemoveComponent(self.__ICOMPONENT, self.__WINDOW_ID)
			del self.__ICOMPONENT
			if(self.__STATUS_EXIST):
				del self.__TRANSFORM, self.__GAME_OBJECT
				self.__GAME_OBJECT_ID = 0
				self.__STATUS_EXIST = False
				PrintLog(f"{self.__class__.__name__} parents deleted", color= LogColors.YELLOW)
			self.__WINDOW_ID = 0
			self.__AWAKE = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)
		return self.__ID
	

	def __OnDestroy(self) -> None: ...


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	def GetGameObjectId(self) -> int:
		return self.__GAME_OBJECT_ID


	@property
	def gameObject(self) -> GameObjectInterface:
		return self.__GAME_OBJECT
	
	@property
	def transform(self) -> Transform:
		return self.__TRANSFORM