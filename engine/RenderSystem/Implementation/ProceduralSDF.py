from ...SceneObjectsSystem import Component
from ...WindowSystem import WindowContextSystem

from .ProceduralSDFController import ProceduralSDFController, allowed_types, AllowedTypes
from ...Log import LogColors, PrintLog

from ...GpuResourceSystem import Material

from ...Math import vec2, mat4

from typing import Optional, Literal
from numpy import ndarray



class ProceduralSDF(Component):

	__STATUS_ALLOCATED: bool
	__ALLOCATE_INDEX: int

	__MATERIAL: Optional[Material]
	__CURENT_TYPE_PROCEDURAL_OBJECT: AllowedTypes

	__MATERIAL_ID: int
	__PARAM: mat4

	__NUMPY_ARRAY: Optional[ndarray]


	def __init__(self,
			material: Material,
			type_procedural_object: AllowedTypes
		) -> None:
		self.__STATUS_ALLOCATED = False
		self.__ALLOCATE_INDEX = -1

		self.__MATERIAL = material
		self.__CURENT_TYPE_PROCEDURAL_OBJECT = type_procedural_object

		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()
		self.__PARAM = mat4()

		self.__NUMPY_ARRAY = None


	def SetMaterial(self, material: Optional[Material]) -> None:
		self.__MATERIAL = material
		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()
		if(self.__STATUS_ALLOCATED):
			self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["material_index"] = self.__MATERIAL_ID # type: ignore
			ProceduralSDFController.SetStatusChanged(self._WINDOW_ID)
	def GetMaterial(self) -> Optional[Material]: return self.__MATERIAL

	def SetTypeProcedural(self, type_procedural_object: AllowedTypes) -> None:
		self.__CURENT_TYPE_PROCEDURAL_OBJECT = type_procedural_object
		if(self.__STATUS_ALLOCATED):
			self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["object_type"] = allowed_types.get(type_procedural_object, -1) # type: ignore
			ProceduralSDFController.SetStatusChanged(self._WINDOW_ID)
	def GetTypeProcedural(self) -> AllowedTypes: return self.__CURENT_TYPE_PROCEDURAL_OBJECT


	def _OnStart(self) -> None:
		if(self.__STATUS_ALLOCATED): return
		self.__ALLOCATE_INDEX = ProceduralSDFController.AllocateIndex(self._WINDOW_ID)
		if(self.__ALLOCATE_INDEX < 0):
			PrintLog(f"[ERROR_{self.__class__.__name__}] it is impossible to allocate memory, the space of allocated areas greatly exceeds the allowable value of objects for allocation.", LogColors.RED)
			return

		IgameObject = self._IGAME_OBJECT
		IgameObject.allocateIndex()
		if(not IgameObject.getStatusAllocated()):
			ProceduralSDFController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
			self.__ALLOCATE_INDEX = -1
			return

		self.__NUMPY_ARRAY = ProceduralSDFController.GetAllocateNumpy(self._WINDOW_ID)
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["material_index"] = self.__MATERIAL_ID
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["transform_index"] = IgameObject.getAllocateIndex()
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["object_type"] = allowed_types.get(self.__CURENT_TYPE_PROCEDURAL_OBJECT, -1)
		self.__PARAM.LinkMemory(self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["param"],0)
		
		IgameObject.appendAllocatableComponent()

		self.__STATUS_ALLOCATED = True



	def _OnDestroy(self) -> None:
		if(not self.__STATUS_ALLOCATED): return

		self.__PARAM.UnlinkMemory()
		self.__NUMPY_ARRAY = None
		ProceduralSDFController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
		self.__ALLOCATE_INDEX = -1
		self.__STATUS_ALLOCATED = False

		IgameObject = self._IGAME_OBJECT
		IgameObject.removeAllocatableComponent()

		if(IgameObject.getAllocatableComponentCount() > 0): return
		IgameObject.deallocateIndex()



