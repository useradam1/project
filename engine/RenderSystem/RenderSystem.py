from typing import Callable


class RenderObject:
	destroy: Callable[[],None]
	def __init__(self, destroy: Callable[[],None]) -> None:
		self.destroy = destroy


class RenderManagerSystem:
	pass