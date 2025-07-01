from .ComponentInterface import ComponentInterface
from .GameObjectInterface import GameObjectInterface
from .SceneSystem import IGameObject
from .ComponentSystem import ComponentManagerSystem, IComponent

from ..Log import LogColors, PrintLog
from ..CustomMetaclass import Protected
from ..Math import Transform
from ..WindowSystem import WindowContextSystem

from ..UpdateSystem import Update, FixedUpdate, LateUpdate

from typing import Optional


class ScriptBase(ComponentInterface):

	__ID: int
	__STATUS_EXIST: bool
	__AWAKE: bool

	__GAME_OBJECT_ID: int
	__GAME_OBJECT: GameObjectInterface
	__TRANSFORM: Transform

	_WINDOW_ID: int
	__ICOMPONENT: IComponent

	__UPDATE: Optional[Update]
	__FIXED_UPDATE: Optional[FixedUpdate]
	__LATE_UPDATE: Optional[LateUpdate]

	def __new__(cls, *args, **kwargs):
		instance = super().__new__(cls)
		instance.__Awake()
		return instance

	@Protected
	def __Awake(self) -> bool:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__AWAKE = False
		self.__GAME_OBJECT_ID = 0

		self.__UPDATE = None
		self.__FIXED_UPDATE = None
		self.__LATE_UPDATE = None

		self._WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self._WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return False

		self.__ICOMPONENT = IComponent(
			component= self,
			id= self.__ID,
			name= f"{self.__class__.__name__}",
			initialization= self.__Initialization,
			getGameObjectId= self.GetGameObjectId,
			destroy= self.Destroy
		)

		if(not ComponentManagerSystem.AppendComponent(self.__ICOMPONENT, self._WINDOW_ID)):
			del self.__ICOMPONENT
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return False

		self.__AWAKE = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)
		return True


	@Protected
	def SetFixedUpdateInterruptionTime(self, value: float) -> None:
		if(self.__FIXED_UPDATE is not None): self.__FIXED_UPDATE.SetInterruptionTime(value)


	@Protected
	def __Initialization(self, gameObject: IGameObject) -> None:
		#if(not self.__STATUS_EXIST):
		self.__GAME_OBJECT_ID = gameObject.id
		self.__GAME_OBJECT = gameObject.gameObject
		self.__TRANSFORM = gameObject.gameObject.transform
		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} new parent has been assigned", color= LogColors.GREEN)

		if '_OnUpdate' in type(self).__dict__.keys(): self.__UPDATE = Update(getattr(self, "_OnUpdate"))
		if '_OnFixedUpdate' in type(self).__dict__.keys(): self.__FIXED_UPDATE = FixedUpdate(getattr(self, "_OnFixedUpdate"), 0.0)
		if '_OnLateUpdate' in type(self).__dict__.keys(): self.__LATE_UPDATE = LateUpdate(getattr(self, "_OnLateUpdate"))
				
		self._OnStart()


	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)


	@Protected
	def Destroy(self) -> int:
		if(self.__AWAKE):
			self._OnDestroy()
			ComponentManagerSystem.RemoveComponent(self.__ICOMPONENT, self._WINDOW_ID)
			del self.__ICOMPONENT
			if(self.__STATUS_EXIST):
				del self.__TRANSFORM, self.__GAME_OBJECT
				self.__GAME_OBJECT_ID = 0
				self.__STATUS_EXIST = False
				PrintLog(f"{self.__class__.__name__} parents deleted", color= LogColors.YELLOW)
			self._WINDOW_ID = 0
			if(self.__UPDATE is not None):
				self.__UPDATE.Destroy()
				self.__UPDATE = None
			if(self.__FIXED_UPDATE is not None):
				self.__FIXED_UPDATE.Destroy()
				self.__FIXED_UPDATE = None
			if(self.__LATE_UPDATE is not None):
				self.__LATE_UPDATE.Destroy()
				self.__LATE_UPDATE = None
			self.__AWAKE = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)
		return self.__ID


	def _OnStart(self) -> None: ...

	def _OnDestroy(self) -> None: ...

	def _OnUpdate(self) -> None: ...
	def _OnFixedUpdate(self, dt: float) -> None: ...
	def _OnLateUpdate(self) -> None: ...


	@Protected
	def GetId(self) -> int:
		return self.__ID

	@Protected
	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	@Protected
	def GetGameObjectId(self) -> int:
		return self.__GAME_OBJECT_ID


	@property
	def gameObject(self) -> GameObjectInterface:
		return self.__GAME_OBJECT
	
	@property
	def transform(self) -> Transform:
		return self.__TRANSFORM
