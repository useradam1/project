from .GameObjectInterface import GameObjectInterface
from typing import Dict, Set, Optional, Callable, List


emptyset = set()



from dataclasses import dataclass

@dataclass(frozen=True)
class IGameObject:
	gameObject: GameObjectInterface
	id: int
	getName: Callable[[], str]
	getTag: Callable[[], str]
	destroy: Callable[[], None]

@dataclass(frozen=True)
class IScene:
	name: str
	load: Callable[[],None]
	start: Callable[[],None]
	unload: Callable[[],None]
	destroy: Callable[[],None]


class SceneManagerSystem:

	__ENABLE_QUEUE_UPDATES_SCENES: bool = True
	__SCENES: Dict[str, IScene] = {}
	__ACTIVE_SCENE: Dict[int, Optional[IScene]] = {}


	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__IGAME_OBJECTS: Dict[int, Set[IGameObject]] = {}
	__GAME_OBJECTS_BY_NAME: Dict[int, Dict[str, Set[GameObjectInterface]]] = {}
	__GAME_OBJECTS_BY_TAG: Dict[int, Dict[str, Set[GameObjectInterface]]] = {}

	@classmethod
	def DestroyAllScenes(cls) -> None:
		cls.__ENABLE_QUEUE_UPDATES_SCENES = False
		for scene in cls.__SCENES.items(): scene[1].destroy()
		cls.__SCENES.clear()
		cls.__ENABLE_QUEUE_UPDATES_SCENES = True

	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ACTIVE_SCENE[window_id] = None
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__IGAME_OBJECTS[window_id] = set()
		cls.__GAME_OBJECTS_BY_NAME[window_id] = {}
		cls.__GAME_OBJECTS_BY_TAG[window_id] = {}

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(scene is not None):
			scene.unload()
			cls.__ACTIVE_SCENE[window_id] = None

		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		go = cls.__IGAME_OBJECTS[window_id]
		for gameObject in go:
			gameObject.destroy()
		go.clear()
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(scene is not None):
			scene.unload()
			cls.__ACTIVE_SCENE[window_id] = None

		cls.__ENABLE_QUEUE_UPDATES[window_id] = False
		for gameObject in cls.__IGAME_OBJECTS[window_id]:
			gameObject.destroy()
		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)

		cls.__IGAME_OBJECTS.pop(window_id, None)
		cls.__GAME_OBJECTS_BY_NAME.pop(window_id, None)
		cls.__GAME_OBJECTS_BY_TAG.pop(window_id, None)
		cls.__ACTIVE_SCENE.pop(window_id, None)


	@classmethod
	def GetActiveScene(cls, window_id: int) -> str:
		scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(scene is None): return ""
		return scene.name


	@classmethod
	def GetScenes(cls) -> List[str]:
		return [scene for scene in cls.__SCENES]


	@classmethod
	def RunScene(cls, window_id: int, name_scene: str) -> None:
		scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(scene is not None):
			scene.unload()
			cls.__ACTIVE_SCENE[window_id] = None

		scene = cls.__SCENES.get(name_scene, None)
		if(scene is None): return

		scene.load()
		scene.start()
		cls.__ACTIVE_SCENE[window_id] = scene

	@classmethod
	def EndScene(cls, window_id: int) -> None:
		scene = cls.__ACTIVE_SCENE.get(window_id, None)
		if(scene is not None):
			scene.unload()
			cls.__ACTIVE_SCENE[window_id] = None



	@classmethod
	def AppendScene(cls, scene: IScene) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES_SCENES): return False
		cls.__SCENES[scene.name] = scene
		return True

	@classmethod
	def RemoveScene(cls, scene: IScene) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES_SCENES): return
		cls.__SCENES.pop(scene.name, None)


	@classmethod
	def AppendGameObject(cls, igameObject: IGameObject, window_id: int) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return False

		cls.__IGAME_OBJECTS[window_id].add(igameObject)

		name = igameObject.getName()
		in_window_by_name = cls.__GAME_OBJECTS_BY_NAME[window_id]
		if(name not in in_window_by_name): in_window_by_name[name] = set([igameObject.gameObject])
		else: in_window_by_name[name].add(igameObject.gameObject)

		tag = igameObject.getTag()
		in_window_by_tag = cls.__GAME_OBJECTS_BY_TAG[window_id]
		if(tag not in in_window_by_tag): in_window_by_tag[tag] = set([igameObject.gameObject])
		else: in_window_by_tag[tag].add(igameObject.gameObject)

		return True

	@classmethod
	def RemoveGameObject(cls, igameObject: IGameObject, window_id: int) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return

		cls.__IGAME_OBJECTS[window_id].remove(igameObject)

		name = igameObject.getName()
		in_window_by_name = cls.__GAME_OBJECTS_BY_NAME[window_id]
		by_name = in_window_by_name[name]
		by_name.remove(igameObject.gameObject)
		if(not by_name): in_window_by_name.pop(name, None)

		tag = igameObject.getTag()
		in_window_by_tag = cls.__GAME_OBJECTS_BY_TAG[window_id]
		by_tag = in_window_by_tag[tag]
		by_tag.remove(igameObject.gameObject)
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

