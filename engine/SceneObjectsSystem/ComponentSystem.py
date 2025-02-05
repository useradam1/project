from .ComponentInterface import ComponentInterface, IComponent
from ..WindowSystem import WindowContextSystem
from .GameObjectInterface import IGameObject
from typing import Dict, Set


emptyset = set()


class ComponentManagerSystem:

	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__ICOMPONENT: Dict[int, Dict[int, IComponent]] = {}

	__COMPONENTS_IN_GAME_OBJECT: Dict[int, Dict[int, Set[ComponentInterface]]] = {}
	__COMPONENTS_BY_NAME: Dict[int, Dict[str, Set[ComponentInterface]]] = {}
	__COMPONENTS_IN_GAME_OBJECT_BY_NAME: Dict[int, Dict[int, Dict[str, Set[ComponentInterface]]]] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__ICOMPONENT[window_id] = {}
		cls.__COMPONENTS_IN_GAME_OBJECT[window_id] = {}
		cls.__COMPONENTS_BY_NAME[window_id] = {}
		cls.__COMPONENTS_IN_GAME_OBJECT_BY_NAME[window_id] = {}

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False
		for component in cls.__ICOMPONENT[window_id].values():
			component.destroy()
		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)

		cls.__ICOMPONENT.pop(window_id, None)
		cls.__COMPONENTS_IN_GAME_OBJECT.pop(window_id, None)
		cls.__COMPONENTS_BY_NAME.pop(window_id, None)
		cls.__COMPONENTS_IN_GAME_OBJECT_BY_NAME.pop(window_id, None)


	@classmethod
	def AppendComponent(cls, icomponent: IComponent, window_id: int) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return False

		cls.__ICOMPONENT[window_id][icomponent.id] = icomponent

		return True

	@classmethod
	def RemoveComponent(cls, icomponent: IComponent, window_id: int) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return

		cls.__ICOMPONENT[window_id].pop(icomponent.id, None)

		gameObject_id = icomponent.getGameObjectId()
		if(not gameObject_id): return

		components_in_window_in_gameObject = cls.__COMPONENTS_IN_GAME_OBJECT[window_id]
		components_by_name = components_in_window_in_gameObject[gameObject_id]
		components_by_name.remove(icomponent.component)
		if(not components_by_name): components_in_window_in_gameObject.pop(gameObject_id, None)

		components_in_window_by_name = cls.__COMPONENTS_BY_NAME[window_id]
		components_by_name = components_in_window_by_name[icomponent.name]
		components_by_name.remove(icomponent.component)
		if(not components_by_name): components_in_window_by_name.pop(icomponent.name, None)

		components_in_window_in_gameObject_by_name = cls.__COMPONENTS_IN_GAME_OBJECT_BY_NAME[window_id]
		components_in_gameObject_by_name = components_in_window_in_gameObject_by_name[gameObject_id]
		components_by_name = components_in_gameObject_by_name[icomponent.name]
		components_by_name.remove(icomponent.component)
		if(not components_by_name): components_in_gameObject_by_name.pop(icomponent.name, None)
		if(not components_in_gameObject_by_name): components_in_window_in_gameObject_by_name.pop(gameObject_id, None)


	@classmethod
	def InitializationComponent(cls, component_id: int, gameObject: IGameObject, window_id: int) -> None:
		icomponent = cls.__ICOMPONENT[window_id][component_id]
		icomponent.initialization(gameObject)

		components_in_window_in_gameObject = cls.__COMPONENTS_IN_GAME_OBJECT[window_id]
		if(gameObject.id not in components_in_window_in_gameObject): components_in_window_in_gameObject[gameObject.id] = set([icomponent.component])
		else: components_in_window_in_gameObject[gameObject.id].add(icomponent.component)

		components_in_window_by_name = cls.__COMPONENTS_BY_NAME[window_id]
		if(icomponent.name not in components_in_window_by_name): components_in_window_by_name[icomponent.name] = set([icomponent.component])
		else: components_in_window_by_name[icomponent.name].add(icomponent.component)

		components_in_window_in_gameObject_by_name = cls.__COMPONENTS_IN_GAME_OBJECT_BY_NAME[window_id]
		if(gameObject.id not in components_in_window_in_gameObject_by_name): components_in_window_in_gameObject_by_name[gameObject.id] = {icomponent.name: set([icomponent.component])}
		else:
			components_in_gameObject_by_name = components_in_window_in_gameObject_by_name[gameObject.id]
			if(icomponent.name not in components_in_gameObject_by_name): components_in_gameObject_by_name[icomponent.name] = set([icomponent.component])
			else: components_in_gameObject_by_name[icomponent.name].add(icomponent.component)


	@classmethod
	def DestroyComponentInGameObject(cls, gameObject_id: int, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False


		components_in_window_in_gameObject = cls.__COMPONENTS_IN_GAME_OBJECT[window_id]
		components_in_gameObject = components_in_window_in_gameObject.get(gameObject_id, emptyset)

		if(components_in_gameObject):

			icomponent_in_window = cls.__ICOMPONENT[window_id]
			components_in_window_by_name = cls.__COMPONENTS_BY_NAME[window_id]
			components_in_gameObject_by_name = cls.__COMPONENTS_IN_GAME_OBJECT_BY_NAME[window_id][gameObject_id]


			for component in components_in_gameObject:
				component_id = component.Destroy()
				icomponent = icomponent_in_window[component_id]
				icomponent_in_window.pop(component_id, None)

				components_by_name = components_in_window_by_name[icomponent.name]
				components_by_name.remove(component)
				if(not components_by_name): components_in_window_by_name.pop(icomponent.name, None)

				components_by_name = components_in_gameObject_by_name[icomponent.name]
				components_by_name.remove(component)
				if(not components_by_name): components_in_gameObject_by_name.pop(icomponent.name, None)

			components_in_window_in_gameObject.pop(gameObject_id, None)

		cls.__ENABLE_QUEUE_UPDATES[window_id] = True





class ComponentManager:

	pass