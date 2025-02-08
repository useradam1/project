from typing import Set, Dict, Callable
from ..WindowSystem import WindowContextSystem


zero_float = 0.0

class IUpdate:
	tick: Callable[[float], None]
	destroy: Callable[[], None]
	queue: int

class UpdateSystem:

	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__QUEUE_CHANGE: Dict[int, int] = {}
	__QUEUE_TO_APPEND: Dict[int, Set[IUpdate]] = {}
	__QUEUE_TO_REMOVE: Dict[int, Set[IUpdate]] = {}
	__UPDATES: Dict[int, Dict[int, Set[IUpdate]]] = {}

	__TIME: Dict[int, float] = {}
	__DELTA_TIME: Dict[int, float] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__QUEUE_CHANGE[window_id] = 0
		cls.__QUEUE_TO_APPEND[window_id] = set()
		cls.__QUEUE_TO_REMOVE[window_id] = set()
		cls.__UPDATES[window_id] = {}

		cls.__TIME[window_id] = 0.0
		cls.__DELTA_TIME[window_id] = 0.0

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False
		u = cls.__UPDATES[window_id]
		cls.__CheckQueueChange(window_id, u)

		for queue in u:
			for update in u[queue]: update.destroy()

		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)
		cls.__QUEUE_CHANGE.pop(window_id, None)
		cls.__QUEUE_TO_APPEND.pop(window_id, None)
		cls.__QUEUE_TO_REMOVE.pop(window_id, None)
		cls.__UPDATES.pop(window_id, None)

		cls.__TIME.pop(window_id, None)
		cls.__DELTA_TIME.pop(window_id, None)


	@classmethod
	def AppendUpdate(cls, update: IUpdate, window_id: int) -> bool:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return False

		cls.__QUEUE_TO_APPEND[window_id].add(update)

		cls.__QUEUE_CHANGE[window_id] = 1

		return True

	@classmethod
	def RemoveUpdate(cls, update: IUpdate, window_id: int) -> None:
		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]): return

		cls.__QUEUE_TO_REMOVE[window_id].add(update)

		cls.__QUEUE_CHANGE[window_id] = 1


	@classmethod
	def __CheckQueueChange(cls, window_id: int, u: Dict[int, Set[IUpdate]]) -> None:
		if(not cls.__QUEUE_CHANGE[window_id]): return
		cls.__QUEUE_CHANGE[window_id] = 0

		#u = cls.__UPDATES[window_id]

		ap = cls.__QUEUE_TO_APPEND[window_id]
		for update in ap:
			if(update.queue not in u): u[update.queue] = set()
			u[update.queue].add(update)
		ap.clear()

		re = cls.__QUEUE_TO_REMOVE[window_id]
		for update in re: u[update.queue].remove(update)
		re.clear()


	@classmethod
	def Tick(cls, window_id: int, time: float) -> None:
		dt = time - cls.__TIME[window_id]
		cls.__DELTA_TIME[window_id] = dt
		cls.__TIME[window_id] = time

		u = cls.__UPDATES[window_id]
		cls.__CheckQueueChange(window_id, u)

		for queue in u:
			for update in u[queue]: update.tick(dt)


	@classmethod
	def GetTime(cls, window_id: int) -> float:
		return cls.__TIME.get(window_id, zero_float)

	@classmethod
	def GetDeltaTime(cls, window_id: int) -> float:
		return cls.__DELTA_TIME.get(window_id, zero_float)


class Time:

	@classmethod
	def GetTime(cls) -> float:
		return UpdateSystem.GetTime(WindowContextSystem.GetCurrentWindowId())

	@classmethod
	def GetDeltaTime(cls) -> float:
		return UpdateSystem.GetDeltaTime(WindowContextSystem.GetCurrentWindowId())
