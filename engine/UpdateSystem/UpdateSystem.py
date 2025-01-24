from typing import Set, Dict
from .UpdateInterface import IUpdate
from ..WindowSystem import WindowContextSystem


zero_float = 0.0


class UpdateSystem:

	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__QUEUE_CHANGE: Dict[int, bool] = {}
	__QUEUE_TO_APPEND: Dict[int, Set[IUpdate]] = {}
	__QUEUE_TO_REMOVE: Dict[int, Set[IUpdate]] = {}
	__UPDATES: Dict[int, Dict[int, Set[IUpdate]]] = {}

	__TIME: Dict[int, float] = {}
	__DELTA_TIME: Dict[int, float] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__QUEUE_CHANGE[window_id] = False
		cls.__QUEUE_TO_APPEND[window_id] = set()
		cls.__QUEUE_TO_REMOVE[window_id] = set()
		cls.__UPDATES[window_id] = {}

		cls.__TIME[window_id] = 0.0
		cls.__DELTA_TIME[window_id] = 0.0

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__CheckQueueChange(window_id)
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False

		for queue in cls.__UPDATES[window_id]:
			for update in cls.__UPDATES[window_id][queue]:
				update.destroy()

		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)
		cls.__QUEUE_CHANGE.pop(window_id, None)
		cls.__QUEUE_TO_APPEND.pop(window_id, None)
		cls.__QUEUE_TO_REMOVE.pop(window_id, None)
		cls.__UPDATES.pop(window_id, None)

		cls.__TIME.pop(window_id, None)
		cls.__DELTA_TIME.pop(window_id, None)


	@classmethod
	def AppendUpdate(cls, update: IUpdate) -> bool:
		window = WindowContextSystem.GetCurrentWindow()
		if(window is None): return False

		window_id = window.GetId()

		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]):
			del window, window_id
			return False

		cls.__QUEUE_TO_APPEND[window_id].add(update)

		cls.__QUEUE_CHANGE[window_id] = True

		del window, window_id
		return True

	@classmethod
	def RemoveUpdate(cls, update: IUpdate) -> None:
		window = WindowContextSystem.GetCurrentWindow()
		if(window is None): return

		window_id = window.GetId()

		if(not cls.__ENABLE_QUEUE_UPDATES[window_id]):
			del window, window_id
			return

		cls.__QUEUE_TO_REMOVE[window_id].add(update)

		cls.__QUEUE_CHANGE[window_id] = True

		del window, window_id
		return


	@classmethod
	def __CheckQueueChange(cls, window_id: int) -> None:
		if(not cls.__QUEUE_CHANGE[window_id]): return
		cls.__QUEUE_CHANGE[window_id] = False

		for update in cls.__QUEUE_TO_APPEND[window_id]:
			if(update.queue not in cls.__UPDATES[window_id]): cls.__UPDATES[window_id][update.queue] = set()
			cls.__UPDATES[window_id][update.queue].add(update)
		cls.__QUEUE_TO_APPEND[window_id].clear()

		for update in cls.__QUEUE_TO_REMOVE[window_id]:
			cls.__UPDATES[window_id][update.queue].remove(update)
		cls.__QUEUE_TO_REMOVE[window_id].clear()


	@classmethod
	def Tick(cls, window_id: int, time: float) -> None:
		cls.__CheckQueueChange(window_id)

		cls.__TIME[window_id] = time
		cls.__DELTA_TIME[window_id] = time - cls.__TIME[window_id]

		for queue in cls.__UPDATES[window_id]:
			for update in cls.__UPDATES[window_id][queue]:
				update.tick(cls.__DELTA_TIME[window_id])


	@classmethod
	def GetTime(cls, window_id: int) -> float:
		return cls.__TIME.get(window_id, zero_float)

	@classmethod
	def GetDeltaTime(cls, window_id: int) -> float:
		return cls.__DELTA_TIME.get(window_id, zero_float)


class Time:

	@property
	def time(self) -> float:
		window = WindowContextSystem.GetCurrentWindow()
		if(window is None): return zero_float
		return UpdateSystem.GetTime(window.GetId())

	@property
	def delta_time(self) -> float:
		window = WindowContextSystem.GetCurrentWindow()
		if(window is None): return zero_float
		return UpdateSystem.GetDeltaTime(window.GetId())
