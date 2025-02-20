from multiprocessing import Process, Value, JoinableQueue
from multiprocessing.sharedctypes import Synchronized
from typing import Callable, Any, TypedDict, Tuple

#from ..Log import LogColors, PrintLog


class Task(TypedDict):
	func: Callable[[Any], None]
	args: Tuple[Any, ...]

def FinalMethod(x: str) -> None: ...
	#print('ProcessTask fin')

class ProcessTask:

	__IS_RUN: Synchronized
	__QUEUE: JoinableQueue
	__PROCESS: Process

	def __init__(self) -> None:
		self.__IS_RUN = Value('b', False)
		self.__QUEUE = JoinableQueue()
		#PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	#def __del__(self) -> None:
	#	PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def loop(self) -> None:
		while self.__IS_RUN.value:
			task = self.__QUEUE.get()
			func, args = task['func'], task['args']
			func(*args)
			self.__QUEUE.task_done()
		#PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)

	def Run(self) -> None:
		if(not self.__IS_RUN.value):
			self.__IS_RUN.value = True
			self.__PROCESS = Process(target= self.loop, daemon= True)
			self.__PROCESS.start()
			#PrintLog(f"{self.__class__.__name__} Run", color= LogColors.GREEN)
	
	def Destroy(self) -> None:
		if(self.__IS_RUN.value):
			self.__IS_RUN.value = False
			self.__QUEUE.put_nowait(Task(
				func= FinalMethod,
				args= tuple("1")
			))
			self.__PROCESS.join()
			self.__QUEUE = JoinableQueue()

	def Put(self, task: Callable[[Any], None], *args) -> None:
		#if(self.__IS_RUN):
		self.__QUEUE.put_nowait(Task(
			func= task,
			args= args
		))