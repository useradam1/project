from .GameObjectInterface import GameObjectInterface
from .SceneInterface import SceneInterface
from ..ApiGraphics import CreateSSBOBuffer, UpdateSSBOBuffer, DestroySSBOBuffer

from typing import Dict, Set, Optional, Callable, List, Type
from numpy import zeros, dtype, float32, ndarray, uint32

from ..Log import PrintLog, LogColors

emptyset = set()

SSBO_INDEX = 40
SSBO_LIMIT = 1000



class IGameObject:
	gameObject: GameObjectInterface
	id: int
	getAllocateIndex: Callable[[], int]
	getStatusAllocated: Callable[[], bool]
	allocateIndex: Callable[[], None]
	deallocateIndex: Callable[[], None]
	def __init__(self,
		gameObject: GameObjectInterface, 
		id: int, getAllocateIndex: Callable[[], int], 
		getStatusAllocated: Callable[[], bool], 
		allocateIndex: Callable[[], None],
		deallocateIndex: Callable[[], None]
	) -> None:
		self.gameObject = gameObject
		self.id = id
		self.getAllocateIndex = getAllocateIndex
		self.getStatusAllocated = getStatusAllocated
		self.allocateIndex = allocateIndex
		self.deallocateIndex = deallocateIndex


class SceneManagerSystem:

	__REGISTRY_SCENES: Dict[str, Type[SceneInterface]] = {}
	__ACTIVE_SCENE: Dict[int, Optional[SceneInterface]] = {}


	__NUMPY_ARRAY_TRANSFORMS_LINK_FREE_CELLS: Dict[int, Set[int]] = {}
	__NUMPY_ARRAY_TRANSFORMS_LINK: Dict[int, ndarray[tuple[int, int, int],dtype[float32]]] = {}
	__LIST_OF_REGISTERED_TRANSFORMS: Dict[int, List[int]] = {}
	__SSBO: Dict[int, uint32] = {}


	__ENABLE_QUEUE_GAME_OBJECTS: Dict[int, bool] = {}
	__IGAME_OBJECTS: Dict[int, Set[GameObjectInterface]] = {}
	__GAME_OBJECTS_BY_NAME: Dict[int, Dict[str, Set[GameObjectInterface]]] = {}
	__GAME_OBJECTS_BY_TAG: Dict[int, Dict[str, Set[GameObjectInterface]]] = {}



	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ACTIVE_SCENE[window_id] = None

		cls.__NUMPY_ARRAY_TRANSFORMS_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))
		cls.__NUMPY_ARRAY_TRANSFORMS_LINK[window_id] = zeros((SSBO_LIMIT, 2, 16), dtype=float32)
		cls.__LIST_OF_REGISTERED_TRANSFORMS[window_id] = []
		cls.__SSBO[window_id] = CreateSSBOBuffer(SSBO_INDEX, zeros((SSBO_LIMIT,2,16), dtype= float32))

		cls.__ENABLE_QUEUE_GAME_OBJECTS[window_id] = True
		cls.__IGAME_OBJECTS[window_id] = set()
		cls.__GAME_OBJECTS_BY_NAME[window_id] = {}
		cls.__GAME_OBJECTS_BY_TAG[window_id] = {}

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		active_scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(active_scene is not None): active_scene.Destroy()
		cls.__ACTIVE_SCENE[window_id] = None

		cls.__ENABLE_QUEUE_GAME_OBJECTS[window_id] = True
		go = cls.__IGAME_OBJECTS[window_id]
		for gameObject in go:
			gameObject.Destroy()
		go.clear()
		cls.__ENABLE_QUEUE_GAME_OBJECTS[window_id] = False

		cls.__NUMPY_ARRAY_TRANSFORMS_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))
		cls.__LIST_OF_REGISTERED_TRANSFORMS[window_id].clear()

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		active_scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(active_scene is not None):
			active_scene.Destroy()
			cls.__ACTIVE_SCENE[window_id] = None

		cls.__ENABLE_QUEUE_GAME_OBJECTS[window_id] = False
		for gameObject in cls.__IGAME_OBJECTS[window_id]:
			gameObject.Destroy()
		cls.__ENABLE_QUEUE_GAME_OBJECTS.pop(window_id, None)

		cls.__NUMPY_ARRAY_TRANSFORMS_LINK_FREE_CELLS.pop(window_id, None)
		cls.__NUMPY_ARRAY_TRANSFORMS_LINK.pop(window_id, None)
		cls.__LIST_OF_REGISTERED_TRANSFORMS.pop(window_id, None)
		ssbo = cls.__SSBO.pop(window_id)
		DestroySSBOBuffer(ssbo)

		cls.__IGAME_OBJECTS.pop(window_id, None)
		cls.__GAME_OBJECTS_BY_NAME.pop(window_id, None)
		cls.__GAME_OBJECTS_BY_TAG.pop(window_id, None)
		cls.__ACTIVE_SCENE.pop(window_id, None)

	@classmethod
	def UpdateBuffer(cls, window_id: int) -> int:
		transforms = cls.__LIST_OF_REGISTERED_TRANSFORMS[window_id]
		UpdateSSBOBuffer(cls.__SSBO[window_id], cls.__NUMPY_ARRAY_TRANSFORMS_LINK[window_id][transforms])
		return len(transforms)



	@classmethod
	def GetActiveScene(cls, window_id: int) -> Optional[SceneInterface]:
		active_scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(active_scene is None): return None
		return active_scene

	@classmethod
	def GetRegistryScenes(cls) -> List[str]:
		return [scene for scene in cls.__REGISTRY_SCENES]

	@classmethod
	def RunScene(cls, window_id: int, name_scene: str) -> None:
		scene_type = cls.__REGISTRY_SCENES.get(name_scene, None)
		if(scene_type is None):
			PrintLog(f"can not find scene named {name_scene}", LogColors.RED)
			return

		active_scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(active_scene is not None): active_scene.Destroy()

		scene_type()

	@classmethod
	def DestroyScene(cls, window_id: int) -> None:
		active_scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(active_scene is not None): active_scene.Destroy()
		cls.__ACTIVE_SCENE[window_id] = None

	@classmethod
	def RemoveScene(cls, scene: SceneInterface, window_id: int) -> None:
		active_scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(scene is active_scene): cls.__ACTIVE_SCENE[window_id] = None

	@classmethod
	def AppendScene(cls, scene: SceneInterface, window_id: int) -> None:
		active_scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(active_scene is not None): active_scene.Destroy()
		cls.__ACTIVE_SCENE[window_id] = scene

	@classmethod
	def RegisterScene(cls, scene: Type[SceneInterface]) -> bool:
		if(scene.__class__.__name__ in cls.__REGISTRY_SCENES): return False
		cls.__REGISTRY_SCENES[scene.__name__] = scene
		return True


	@classmethod
	def GetAllocateNumpy(cls, window_id: int) -> ndarray[tuple[int, int, int], dtype[float32]]:
		return cls.__NUMPY_ARRAY_TRANSFORMS_LINK[window_id]

	@classmethod
	def AllocateIndex(cls, window_id: int) -> int:
		s = cls.__NUMPY_ARRAY_TRANSFORMS_LINK_FREE_CELLS[window_id]
		if(s):
			index = s.pop()
			cls.__LIST_OF_REGISTERED_TRANSFORMS[window_id].append(index)
			return index
		return -1

	@classmethod
	def DeallocateIndex(cls, index: int, window_id: int) -> None:
		cls.__LIST_OF_REGISTERED_TRANSFORMS[window_id].remove(index)
		cls.__NUMPY_ARRAY_TRANSFORMS_LINK_FREE_CELLS[window_id].add(index)


	@classmethod
	def AppendGameObject(cls, gameObject: GameObjectInterface, name: str, tag: str, window_id: int) -> bool:
		if(not cls.__ENABLE_QUEUE_GAME_OBJECTS[window_id]): return False

		cls.__IGAME_OBJECTS[window_id].add(gameObject)

		in_window_by_name = cls.__GAME_OBJECTS_BY_NAME[window_id]
		if(name not in in_window_by_name): in_window_by_name[name] = set([gameObject])
		else: in_window_by_name[name].add(gameObject)

		in_window_by_tag = cls.__GAME_OBJECTS_BY_TAG[window_id]
		if(tag not in in_window_by_tag): in_window_by_tag[tag] = set([gameObject])
		else: in_window_by_tag[tag].add(gameObject)

		return True

	@classmethod
	def RemoveGameObject(cls, gameObject: GameObjectInterface, name: str, tag: str, window_id: int) -> None:
		if(not cls.__ENABLE_QUEUE_GAME_OBJECTS[window_id]): return

		cls.__IGAME_OBJECTS[window_id].remove(gameObject)

		in_window_by_name = cls.__GAME_OBJECTS_BY_NAME[window_id]
		by_name = in_window_by_name[name]
		by_name.remove(gameObject)
		if(not by_name): in_window_by_name.pop(name, None)

		in_window_by_tag = cls.__GAME_OBJECTS_BY_TAG[window_id]
		by_tag = in_window_by_tag[tag]
		by_tag.remove(gameObject)
		if(not by_tag): in_window_by_tag.pop(tag, None)


	@classmethod
	def UpdateGameObjectName(cls, old_name: str, new_name: str, gameObject: GameObjectInterface, window_id: int) -> None:
		in_window_by_name = cls.__GAME_OBJECTS_BY_NAME[window_id]
		by_name = in_window_by_name[old_name]
		by_name.remove(gameObject)
		if(not by_name): in_window_by_name.pop(old_name, None)

		in_window_by_name = cls.__GAME_OBJECTS_BY_NAME[window_id]
		if(new_name not in in_window_by_name): in_window_by_name[new_name] = set([gameObject])
		else: in_window_by_name[new_name].add(gameObject)

	@classmethod
	def UpdateGameObjectTag(cls, old_tag: str, new_tag: str, gameObject: GameObjectInterface, window_id: int) -> None:
		in_window_by_tag = cls.__GAME_OBJECTS_BY_TAG[window_id]
		by_tag = in_window_by_tag[old_tag]
		by_tag.remove(gameObject)
		if(not by_tag): in_window_by_tag.pop(old_tag, None)

		in_window_by_tag = cls.__GAME_OBJECTS_BY_TAG[window_id]
		if(new_tag not in in_window_by_tag): in_window_by_tag[new_tag] = set([gameObject])
		else: in_window_by_tag[new_tag].add(gameObject)

	@classmethod
	def GetGameObjectsByName(cls, name: str, window_id: int) -> set:
		if(window_id not in cls.__GAME_OBJECTS_BY_NAME): return emptyset
		return cls.__GAME_OBJECTS_BY_NAME[window_id].get(name, emptyset)

	@classmethod
	def GetGameObjectsByTag(cls, tag: str, window_id: int) -> set:
		if(window_id not in cls.__GAME_OBJECTS_BY_TAG): return emptyset
		return cls.__GAME_OBJECTS_BY_TAG[window_id].get(tag, emptyset)

