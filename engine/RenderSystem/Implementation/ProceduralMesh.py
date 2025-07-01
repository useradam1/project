from ...SceneObjectsSystem import Component

from .ProceduralMeshController import ProceduralMeshController
from ...Log import LogColors, PrintLog

from ...GpuResourceSystem import Material, Mesh


from typing import Optional
from numpy import ndarray



class ProceduralMesh(Component):

	__STATUS_ALLOCATED: bool
	__ALLOCATE_INDEX: int

	__MESH: Optional[Mesh]
	__MESH_ID: int

	__MATERIAL: Optional[Material]
	__MATERIAL_ID: int

	__NUMPY_ARRAY: Optional[ndarray]


	def __init__(self,
			mesh: Optional[Mesh],
			material: Optional[Material],
		) -> None:
		self.__STATUS_ALLOCATED = False
		self.__ALLOCATE_INDEX = -1

		self.__MESH = mesh
		self.__MESH_ID = -1 if(mesh is None) else mesh.GetAlocateIndex()

		self.__MATERIAL = material
		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()

		self.__NUMPY_ARRAY = None


	def SetMesh(self, mesh: Optional[Mesh]) -> None:
		self.__MESH = mesh
		self.__MESH_ID = -1 if(mesh is None) else mesh.GetAlocateIndex()
		if(self.__NUMPY_ARRAY is not None):
			self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["mesh_index"] = self.__MESH_ID
			ProceduralMeshController.SetStatusChanged(self._WINDOW_ID)
	def GetMesh(self) -> Optional[Mesh]: return self.__MESH


	def SetMaterial(self, material: Optional[Material]) -> None:
		self.__MATERIAL = material
		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()
		if(self.__NUMPY_ARRAY is not None):
			self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["material_index"] = self.__MATERIAL_ID
			ProceduralMeshController.SetStatusChanged(self._WINDOW_ID)
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
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["mesh_index"] = self.__MESH_ID
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["transform_index"] = IgameObject.getAllocateIndex()

		IgameObject.appendAllocatableComponent()

		self.__STATUS_ALLOCATED = True



	def _OnDestroy(self) -> None:
		if(not self.__STATUS_ALLOCATED): return

		self.__NUMPY_ARRAY = None
		ProceduralMeshController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
		self.__ALLOCATE_INDEX = -1
		self.__STATUS_ALLOCATED = False

		self.__MESH = None
		self.__MESH_ID = -1
		self.__MATERIAL = None
		self.__MATERIAL_ID = -1

		IgameObject = self._IGAME_OBJECT
		IgameObject.removeAllocatableComponent()

		if(IgameObject.getAllocatableComponentCount() > 0): return
		IgameObject.deallocateIndex()



