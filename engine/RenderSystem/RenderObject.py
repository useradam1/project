from ..SceneObjectsSystem import Component
from ..GpuResourceSystem import Mesh





class RenderObject(Component):


	def __init__(self) -> None:
		if(not self.__Awake()): return




	def __OnDestroy(self) -> None:
		pass

	def __OnStart(self) -> None:
		pass