
class FinalMeta(type):
	def __new__(cls, name, bases, dct):
		for base in bases:
			for attr in dct:
				if attr in base.__dict__:
					if isinstance(base.__dict__[attr], Protected):
						raise TypeError(f"Cannot override final method '{attr}' in class '{base.__name__}'")
		return super().__new__(cls, name, bases, dct)

class Protected:
	def __init__(self, func):
		self.func = func

	def __get__(self, instance, owner):
		return self.func.__get__(instance, owner)



from collections import deque
from typing import Callable, Any, Deque, Tuple, Dict

class TaskQueue:

	__QUEUE: Deque[Tuple[Callable[[Any], Any], tuple[Any, ...], Dict[str, Any]]]
	__IS_EMPTY: bool

	def __init__(self) -> None:
		self.__QUEUE = deque()
		self.__IS_EMPTY = True

	def add_task(self, func: Callable, *args, **kwargs) -> None:
		self.__QUEUE.append((func, args, kwargs))
		self.__IS_EMPTY = False

	def execute_next(self) -> Any:
		if self.__IS_EMPTY: return None
		func, args, kwargs = self.__QUEUE.popleft()
		if not self.__QUEUE: self.__IS_EMPTY = True
		return func(*args, **kwargs)

	def is_empty(self) -> bool:
		return self.__IS_EMPTY