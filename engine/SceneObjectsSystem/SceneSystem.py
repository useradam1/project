from ..WindowSystem import WindowContextSystem
from .SceneInterface import IScene
from .GameObjectInterface import GameObjectInterface, IGameObject
from typing import Dict, Set


emptyset = set()


class SceneManagerSystem:

	__SCENES: Dict[str, IScene] = {}


	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__IGAME_OBJECTS: Dict[int, Set[IGameObject]] = {}
	__GAME_OBJECTS_BY_NAME: Dict[int, Dict[str, Set[GameObjectInterface]]] = {}
	__GAME_OBJECTS_BY_TAG: Dict[int, Dict[str, Set[GameObjectInterface]]] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__IGAME_OBJECTS[window_id] = set()
		cls.__GAME_OBJECTS_BY_NAME[window_id] = {}
		cls.__GAME_OBJECTS_BY_TAG[window_id] = {}

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False
		for gameObject in cls.__IGAME_OBJECTS[window_id]:
			gameObject.destroy()
		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)

		cls.__IGAME_OBJECTS.pop(window_id, None)
		cls.__GAME_OBJECTS_BY_NAME.pop(window_id, None)
		cls.__GAME_OBJECTS_BY_TAG.pop(window_id, None)


	@classmethod
	def AppendScene(cls, scene: IScene) -> bool:
		cls.__SCENES[scene.name] = scene
		return True

	@classmethod
	def RemoveScene(cls, scene: IScene) -> None:
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



class SceneManager:

	@classmethod
	def GetGameObjectsByName(cls, name: str) -> set:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return emptyset
		return SceneManagerSystem.GetGameObjectsByName(name, window_id)
	@classmethod
	def GetGameObjectsByTag(cls, tag: str) -> set:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return emptyset
		return SceneManagerSystem.GetGameObjectsByTag(tag, window_id)