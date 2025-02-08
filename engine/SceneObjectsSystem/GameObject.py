from .GameObjectInterface import GameObjectInterface
from .SceneSystem import SceneManagerSystem, IGameObject

from .ComponentInterface import ComponentInterface
from .ComponentSystem import ComponentManagerSystem
from .ComponentType import ComponentType

from ..Math import Transform
from ..Log import LogColors, PrintLog
from ..WindowSystem import WindowContextSystem

from typing import Optional, List, Set, Type



class GameObject(GameObjectInterface):

	__ID: int
	__STATUS_EXIST: bool

	__NAME: str
	__TAG: str
	__TRANSFORM: Transform

	__PARENT: Optional[GameObjectInterface]
	__HAS_PARENT: bool

	__WINDOW_ID: int
	__IGAME_OBJECT: IGameObject


	def __init__(self, name: str, tag: str, transform: Transform, components: List[ComponentInterface]) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False

		self.__NAME = name
		self.__TAG = tag
		self.__TRANSFORM = transform
		self.__PARENT = None
		self.__HAS_PARENT = False

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog("GameObject cannot be created outside of the window context", color= LogColors.RED)
			return
		
		self.__IGAME_OBJECT = IGameObject(
			gameObject= self,
			id= self.__ID,
			getName= self.GetName,
			getTag= self.GetTag,
			destroy= self.Destroy
		)
		if(not SceneManagerSystem.AppendGameObject(self.__IGAME_OBJECT, self.__WINDOW_ID)):
			del self.__IGAME_OBJECT
			PrintLog("GameObject registration denied", color= LogColors.RED)
			return
		
		self.__STATUS_EXIST = True
		PrintLog("GameObject Initialization", color= LogColors.GREEN)

		for component in components:
			ComponentManagerSystem.InitializationComponent(component.GetId(), self.__IGAME_OBJECT, self.__WINDOW_ID)
	
	
	def __del__(self) -> None:
		PrintLog("GameObject deleted", color= LogColors.BLUE)


	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			ComponentManagerSystem.DestroyComponentInGameObject(self.__ID, self.__WINDOW_ID)
			SceneManagerSystem.RemoveGameObject(self.__IGAME_OBJECT, self.__WINDOW_ID)
			del self.__IGAME_OBJECT
			self.__WINDOW_ID = 0
			self.__TRANSFORM.SetParent(None)
			self.__PARENT = None
			self.__HAS_PARENT = False
			self.__STATUS_EXIST = False
			PrintLog("GameObject Terminate", color= LogColors.YELLOW)


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST
	
	def GetName(self) -> str:
		return self.__NAME
	def SetName(self, name: str) -> None:
		if(self.__STATUS_EXIST):
			SceneManagerSystem.UpdateGameObjectName(self.__NAME, name, self, self.__WINDOW_ID)
			self.__NAME = name

	def GetTag(self) -> str:
		return self.__TAG
	def SetTag(self, tag: str) -> None:
		if(self.__STATUS_EXIST):
			SceneManagerSystem.UpdateGameObjectTag(self.__TAG, tag, self, self.__WINDOW_ID)
			self.__TAG = tag

	def SetParent(self, parent: GameObjectInterface | None) -> None:
		if(self.__HAS_PARENT): self.__TRANSFORM.SetParent(None)
		self.__HAS_PARENT = (parent is not None)
		if(self.__HAS_PARENT): self.__TRANSFORM.SetParent(parent.transform) #type: ignore
		self.__PARENT = parent
	
	def GetParent(self) -> Optional[GameObjectInterface]:
		return self.__PARENT

	def HasParent(self) -> bool:
		return self.__HAS_PARENT

	def GetComponents(self, component_name: Type[ComponentType]) -> Set[ComponentType]:
		return ComponentManagerSystem.GetComponentsInGameObjectByName(self.__WINDOW_ID, self.__ID, component_name)

	@property
	def transform(self) -> Transform:
		return self.__TRANSFORM