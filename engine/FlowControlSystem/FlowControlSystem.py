from .ProcessTask import ProcessTask
from .ThreadTask import ThreadTask

from typing import List, Callable


class FlowControlSystem:

	__MAX_THREADS: int = 16
	__MAX_PROCESSES: int = 8
	__COUNTER_THREADS: int = 0
	__COUNTER_PROCESSES: int = 0
	__THREADS_IN_FRAME: List[ThreadTask] = []
	__PROCESSES_IN_FRAME: List[ProcessTask] = []

	@classmethod
	def Initialization(cls) -> None:
		for _ in range(cls.__MAX_THREADS):
			thread = ThreadTask()
			thread.Run()
			cls.__THREADS_IN_FRAME.append(thread)
		for _ in range(cls.__MAX_PROCESSES):
			process = ProcessTask()
			process.Run()
			cls.__PROCESSES_IN_FRAME.append(process)

	@classmethod
	def Terminate(cls) -> None:
		for thread in cls.__THREADS_IN_FRAME:
			thread.Destroy()
		cls.__THREADS_IN_FRAME.clear()
		for process in cls.__PROCESSES_IN_FRAME:
			process.Destroy()
		cls.__PROCESSES_IN_FRAME.clear()


	@classmethod
	def CreateFrameThreadTask(cls, task: Callable[[dict], None], arg: dict) -> None:
		cls.__THREADS_IN_FRAME[cls.__COUNTER_THREADS].Put(task,arg)
		cls.__COUNTER_THREADS = (cls.__COUNTER_THREADS+1)%cls.__MAX_THREADS


	@classmethod
	def CreateFrameProcessTask(cls, task: Callable[[dict], None], arg: dict) -> None:
		cls.__PROCESSES_IN_FRAME[cls.__COUNTER_PROCESSES].Put(task,arg)
		cls.__COUNTER_PROCESSES = (cls.__COUNTER_PROCESSES+1)%cls.__MAX_PROCESSES


class FlowControl:

	@classmethod
	def CreateFrameThreadTask(cls, task: Callable[[dict], None], arg: dict) -> None:
		FlowControlSystem.CreateFrameThreadTask(task, arg)

	@classmethod
	def CreateFrameProcessTask(cls, task: Callable[[dict], None], arg: dict) -> None:
		FlowControlSystem.CreateFrameProcessTask(task, arg)