from threading import Thread
from queue import Queue
from typing import Callable, TypedDict

#from ..Log import LogColors, PrintLog


class Task(TypedDict):
	func: Callable[[dict], None]
	arg: dict

def FinalMethod(x: dict) -> None: ...
	#print('ThreadTask fin')

class ThreadTask:

	__IS_RUN: bool
	__QUEUE: Queue[Task]
	__THREAD: Thread

	def __init__(self) -> None:
		self.__IS_RUN = False
		self.__QUEUE = Queue()
		#PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	#def __del__(self) -> None:
	#	PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def loop(self) -> None:
		while self.__IS_RUN:
			try:
				queue = self.__QUEUE.get()
				func, arg = queue['func'], queue['arg']
				self.__QUEUE.task_done()
				func(arg)
			except Exception as e:
				continue
		#PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)

	def Run(self) -> None:
		if(not self.__IS_RUN):
			self.__IS_RUN = True
			self.__THREAD = Thread(target= self.loop, daemon= True)
			self.__THREAD.start()
			#PrintLog(f"{self.__class__.__name__} Run", color= LogColors.GREEN)
	
	def Destroy(self) -> None:
		if(self.__IS_RUN):
			self.__IS_RUN = False
			try:
				self.__QUEUE.put_nowait(Task(
					func= FinalMethod,
					arg= {}
				))
				self.__THREAD.join()
			except Exception as e:
				pass
			self.__QUEUE = Queue()

	def Put(self, task: Callable[[dict], None], arg: dict) -> None:
		if(not self.__IS_RUN): return
		self.__QUEUE.put_nowait(Task(
			func= task,
			arg= arg
		))