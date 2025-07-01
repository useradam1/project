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
	__STATUS_ALLOCATED: bool
	__ALLOCATE_INDEX: int
	__ALLOCATABLE_COMPONENT_COUNT: int

	__PARENT: Optional[GameObjectInterface]
	__HAS_PARENT: bool

	__WINDOW_ID: int
	__IGAME_OBJECT: IGameObject



	def __init__(self, name: str, tag: str, transform: Transform, components: List[ComponentInterface], childrens: List[GameObjectInterface]) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False

		self.__NAME = name
		self.__TAG = tag
		self.__TRANSFORM = transform
		self.__STATUS_ALLOCATED = False
		self.__ALLOCATE_INDEX = -1
		self.__ALLOCATABLE_COMPONENT_COUNT = 0

		self.__PARENT = None
		self.__HAS_PARENT = False

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return
		
		self.__IGAME_OBJECT = IGameObject(
			gameObject= self,
			id= self.__ID,
			getAllocateIndex= self.__GetAllocateIndex,
			getStatusAllocated= self.__GetStatusAllocated,
			allocateIndex= self.__AllocateIndex,
			deallocateIndex= self.__DeallocateIndex,
			getAllocatableComponentCount= self.__GetAllocatableComponentCount,
			appendAllocatableComponent= self.__AppendAllocatableComponent,
			removeAllocatableComponent= self.__RemoveAllocatableComponent
		)
		if(not SceneManagerSystem.AppendGameObject(self, self.__NAME, self.__TAG, self.__WINDOW_ID)):
			del self.__IGAME_OBJECT
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return
		
		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

		for component in components:
			ComponentManagerSystem.InitializationComponent(component.GetId(), self.__IGAME_OBJECT, self.__WINDOW_ID)

		for children in childrens:
			children.SetParent(self)
	
	
	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)


	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			self.__DeallocateIndex()
			ComponentManagerSystem.DestroyComponentInGameObject(self.__ID, self.__WINDOW_ID)
			SceneManagerSystem.RemoveGameObject(self, self.__NAME, self.__TAG, self.__WINDOW_ID)
			del self.__IGAME_OBJECT
			self.__WINDOW_ID = 0
			self.__TRANSFORM.SetParent(None)
			self.__PARENT = None
			self.__HAS_PARENT = False
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST


	def __GetAllocateIndex(self) -> int:
		return self.__ALLOCATE_INDEX
	
	def __GetStatusAllocated(self) -> bool:
		return self.__STATUS_ALLOCATED
	
	def __AllocateIndex(self) -> None:
		if(self.__STATUS_ALLOCATED): return
		self.__ALLOCATE_INDEX = SceneManagerSystem.AllocateIndex(self.__WINDOW_ID)
		if(self.__ALLOCATE_INDEX == -1):
			PrintLog(f"[ERROR_{self.__class__.__name__}] it is impossible to allocate memory, the space of allocated areas greatly exceeds the allowable value of objects for allocation.")
			return
		numpy_array = SceneManagerSystem.GetAllocateNumpy(self.__WINDOW_ID)
		if(self.__HAS_PARENT):
			self.transform.LinkMemoryGlobalSRT(numpy_array[self.__ALLOCATE_INDEX][0],0)
			self.transform.LinkMemoryGlobalTRS(numpy_array[self.__ALLOCATE_INDEX][1],0)
		else:
			self.transform.LinkMemoryLocalSRT(numpy_array[self.__ALLOCATE_INDEX][0],0)
			self.transform.LinkMemoryLocalTRS(numpy_array[self.__ALLOCATE_INDEX][1],0)
		self.__STATUS_ALLOCATED = True
	
	def __DeallocateIndex(self) -> None:
		if(not self.__STATUS_ALLOCATED): return
		if(self.__HAS_PARENT):
			self.transform.UnlinkMemoryGlobalSRT()
			self.transform.UnlinkMemoryGlobalTRS()
		else:
			self.transform.UnlinkMemoryLocalSRT()
			self.transform.UnlinkMemoryLocalTRS()
		SceneManagerSystem.DeallocateIndex(self.__ALLOCATE_INDEX, self.__WINDOW_ID)
		self.__STATUS_ALLOCATED = False
	
	def __GetAllocatableComponentCount(self) -> int:
		return self.__ALLOCATABLE_COMPONENT_COUNT
	def __AppendAllocatableComponent(self) -> None:
		self.__ALLOCATABLE_COMPONENT_COUNT += 1
	def __RemoveAllocatableComponent(self) -> None:
		self.__ALLOCATABLE_COMPONENT_COUNT -= 1


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
		if(self.__HAS_PARENT):
			if(self.__STATUS_ALLOCATED):
				self.transform.UnlinkMemoryGlobalSRT()
				self.transform.UnlinkMemoryGlobalTRS()
			self.__TRANSFORM.SetParent(None)
			SceneManagerSystem.RemoveChildFromGameObject(self.__PARENT, self, self.__WINDOW_ID) # type: ignore
			SceneManagerSystem.SetParentToGameObject(self.__ID, 0, self.__WINDOW_ID)
		else:
			if(self.__STATUS_ALLOCATED):
				self.transform.UnlinkMemoryLocalSRT()
				self.transform.UnlinkMemoryLocalTRS()
		self.__HAS_PARENT = (parent is not None)
		if(self.__HAS_PARENT):
			self.__TRANSFORM.SetParent(parent.transform) #type: ignore
			if(self.__STATUS_ALLOCATED):
				numpy_array = SceneManagerSystem.GetAllocateNumpy(self.__WINDOW_ID)
				self.transform.LinkMemoryGlobalSRT(numpy_array[self.__ALLOCATE_INDEX][0],0)
				self.transform.LinkMemoryGlobalTRS(numpy_array[self.__ALLOCATE_INDEX][1],0)
			SceneManagerSystem.AppendChildToGameObject(parent, self, self.__WINDOW_ID) # type: ignore
			SceneManagerSystem.SetParentToGameObject(self.__ID, parent.GetId(), self.__WINDOW_ID) # type: ignore
		else:
			if(self.__STATUS_ALLOCATED):
				numpy_array = SceneManagerSystem.GetAllocateNumpy(self.__WINDOW_ID)
				self.transform.LinkMemoryLocalSRT(numpy_array[self.__ALLOCATE_INDEX][0],0)
				self.transform.LinkMemoryLocalTRS(numpy_array[self.__ALLOCATE_INDEX][1],0)
		self.__PARENT = parent
	
	def GetParent(self) -> Optional[GameObjectInterface]:
		return self.__PARENT

	def HasParent(self) -> bool:
		return self.__HAS_PARENT

	def GetComponents(self, component_name: Type[ComponentType]) -> Set[ComponentType]:
		return ComponentManagerSystem.GetComponentsInGameObjectByName(self.__WINDOW_ID, self.__ID, component_name)

	def GetComponent(self, component_name: Type[ComponentType]) -> Optional[ComponentType]:
		return next(iter(ComponentManagerSystem.GetComponentsInGameObjectByName(self.__WINDOW_ID, self.__ID, component_name)), None)

	@property
	def transform(self) -> Transform:
		return self.__TRANSFORM