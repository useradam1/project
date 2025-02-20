from typing import Dict, Set, Callable


class RenderObject:
	destroy: Callable[[], None]


class RenderSystem:


	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__RENDER_OBJECTS: Dict[int, Set[RenderObject]] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__RENDER_OBJECTS[window_id] = set()

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False

		render_objects = cls.__RENDER_OBJECTS[window_id]
		for render_object in render_objects:
			render_object.destroy()
		render_objects.clear()

		cls.__ENABLE_QUEUE_UPDATES[window_id] = True

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False

		for render_object in cls.__RENDER_OBJECTS[window_id]:
			render_object.destroy()
		
		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)
		cls.__RENDER_OBJECTS.pop(window_id, None)
	

	@classmethod
	def AppendRenderObject(cls, render_object: RenderObject, window_id: int) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return False
		cls.__RENDER_OBJECTS[window_id].add(render_object)
		return True
	
	@classmethod
	def RemoveRenderObject(cls, render_object: RenderObject, window_id: int) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return
		cls.__RENDER_OBJECTS[window_id].remove(render_object)