from ..UpdateSystem import FixedUpdate
from typing import Dict, Set, Callable
from numpy import uint32


class IGpuResource:
	destroy: Callable[[], None]
	def __init__(self,
			destroy: Callable[[], None],
	) -> None:
		self.destroy = destroy



class GpuResourceManagerSystem:


	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__GPU_RESOURCES: Dict[int, Set[IGpuResource]] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__GPU_RESOURCES[window_id] = set()

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False

		render_objects = cls.__GPU_RESOURCES[window_id]
		for render_object in render_objects:
			render_object.destroy()
		render_objects.clear()

		cls.__ENABLE_QUEUE_UPDATES[window_id] = True

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False

		for render_object in cls.__GPU_RESOURCES[window_id]:
			render_object.destroy()
		
		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)
		cls.__GPU_RESOURCES.pop(window_id, None)
	

	@classmethod
	def AppendGpuResource(cls, render_object: IGpuResource, window_id: int) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return False
		cls.__GPU_RESOURCES[window_id].add(render_object)
		return True
	
	@classmethod
	def RemoveGpuResource(cls, render_object: IGpuResource, window_id: int) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return
		cls.__GPU_RESOURCES[window_id].remove(render_object)