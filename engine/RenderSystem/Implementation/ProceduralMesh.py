from ...SceneObjectsSystem import Component
from ...WindowSystem import WindowContextSystem

from .ProceduralMeshController import ProceduralMeshController
from ...Log import LogColors, PrintLog

from ...GpuResourceSystem import Material

from ...Math import vec2

from typing import Optional, Literal
from numpy import ndarray



class ProceduralMesh(Component):

	__STATUS_ALLOCATED: bool
	__ALLOCATE_INDEX: int

	__MATERIAL: Optional[Material]

	__MATERIAL_ID: int

	__NUMPY_ARRAY: Optional[ndarray]


	def __init__(self,
			material: Material,
		) -> None:
		self.__STATUS_ALLOCATED = False
		self.__ALLOCATE_INDEX = -1

		self.__MATERIAL = material

		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()

		self.__NUMPY_ARRAY = None


	def SetMaterial(self, material: Optional[Material]) -> None:
		self.__MATERIAL = material
		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()
		if(self.__NUMPY_ARRAY is not None):
			self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["material_index"] = self.__MATERIAL_ID
	def GetMaterial(self) -> Optional[Material]: return self.__MATERIAL


	def _OnStart(self) -> None:
		if(self.__STATUS_ALLOCATED): return
		self.__ALLOCATE_INDEX = ProceduralMeshController.AllocateIndex(self._WINDOW_ID)
		if(self.__ALLOCATE_INDEX < 0):
			PrintLog(f"[ERROR_{self.__class__.__name__}] it is impossible to allocate memory, the space of allocated areas greatly exceeds the allowable value of objects for allocation.", LogColors.RED)
			return

		IgameObject = self._IGAME_OBJECT
		IgameObject.allocateIndex()
		if(not IgameObject.getStatusAllocated()):
			ProceduralMeshController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
			self.__ALLOCATE_INDEX = -1
			return

		self.__NUMPY_ARRAY = ProceduralMeshController.GetAllocateNumpy(self._WINDOW_ID)
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["material_index"] = self.__MATERIAL_ID
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["bvh_index"] = 0
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["alignment_triangle_index"] = 0
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["transform_index"] = IgameObject.getAllocateIndex()

		IgameObject.appendAllocatableComponent()

		self.__STATUS_ALLOCATED = True



	def _OnDestroy(self) -> None:
		if(not self.__STATUS_ALLOCATED): return

		self.__NUMPY_ARRAY = None
		ProceduralMeshController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
		self.__ALLOCATE_INDEX = -1
		self.__STATUS_ALLOCATED = False

		IgameObject = self._IGAME_OBJECT
		IgameObject.removeAllocatableComponent()

		if(IgameObject.getAllocatableComponentCount() > 0): return
		IgameObject.deallocateIndex()



