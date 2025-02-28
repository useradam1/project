from multiprocessing import Process, Value, JoinableQueue
from multiprocessing.sharedctypes import Synchronized
from threading import Thread
from queue import Queue
from typing import Callable, TypedDict

#from ..Log import LogColors, PrintLog


class Task(TypedDict):
	func: Callable[[dict], None]
	arg: dict

def FinalMethod(x: dict) -> None: ...
	#print('ProcessTask fin')

class ProcessTask:

	__IS_RUN: Synchronized
	__PROCESS_TASK_QUEUE: JoinableQueue
	__PROCESS_DONE_QUEUE: JoinableQueue
	__THREAD_SYNC_QUEUE: Queue
	__PROCESS: Process
	__THREAD: Thread

	def __init__(self) -> None:
		self.__IS_RUN = Value('b', False)
		self.__PROCESS_TASK_QUEUE = JoinableQueue()
		self.__PROCESS_DONE_QUEUE = JoinableQueue()
		#PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	#def __del__(self) -> None:
	#	PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def loopThread(self) -> None:
		while self.__IS_RUN.value:
			dict_py: dict = self.__THREAD_SYNC_QUEUE.get()
			dict_process: dict = self.__PROCESS_DONE_QUEUE.get()
			for a,b in dict_process.items():
				dict_py[a] = b
			self.__THREAD_SYNC_QUEUE.task_done()
			self.__PROCESS_DONE_QUEUE.task_done()

	def loopProcess(self) -> None:
		while self.__IS_RUN.value:
			queue = self.__PROCESS_TASK_QUEUE.get()
			func, arg = queue['func'], queue['arg']
			func(arg)
			self.__PROCESS_TASK_QUEUE.task_done()
			self.__PROCESS_DONE_QUEUE.put_nowait(arg)
		#PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)

	def Run(self) -> None:
		if(not self.__IS_RUN.value):
			self.__IS_RUN.value = True
			self.__PROCESS = Process(target= self.loopProcess, daemon= True)
			self.__PROCESS.start()
			self.__THREAD_SYNC_QUEUE = Queue()
			self.__THREAD = Thread(target= self.loopThread, daemon= True)
			self.__THREAD.start()
			#PrintLog(f"{self.__class__.__name__} Run", color= LogColors.GREEN)
	
	def Destroy(self) -> None:
		if(self.__IS_RUN.value):
			self.__IS_RUN.value = False
			self.__PROCESS_TASK_QUEUE.put_nowait(Task(
				func= FinalMethod,
				arg= {}
			))
			self.__PROCESS_DONE_QUEUE.put_nowait({})
			self.__THREAD_SYNC_QUEUE.put_nowait({})
			self.__PROCESS.join()
			self.__THREAD.join()
			self.__PROCESS_TASK_QUEUE = JoinableQueue()
			self.__PROCESS_DONE_QUEUE = JoinableQueue()

	def Put(self, task: Callable[[dict], None], arg: dict) -> None:
		#if(self.__IS_RUN):
		self.__THREAD_SYNC_QUEUE.put_nowait(arg)
		self.__PROCESS_TASK_QUEUE.put_nowait(Task(
			func= task,
			arg= arg
		))