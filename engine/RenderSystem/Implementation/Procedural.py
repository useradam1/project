from ...SceneObjectsSystem import Component
from ...WindowSystem import WindowContextSystem

from .ProceduralController import ProceduralController, allowed_types, AllowedTypes
from ...Log import LogColors, PrintLog

from ...GpuResourceSystem import Material

from ...Math import vec2

from typing import Optional, Literal



class Procedural(Component):

	__STATUS_ALLOCATED: bool
	__ALLOCATE_INDEX: int

	__MATERIAL: Optional[Material]
	__CURENT_TYPE_PROCEDURAL_OBJECT: AllowedTypes

	__ATTRIBUTE: vec2


	def __init__(self,
			material: Material,
			type_procedural_object: AllowedTypes
		) -> None:
		self.__STATUS_ALLOCATED = False
		self.__ALLOCATE_INDEX = -1

		self.__MATERIAL = material
		self.__CURENT_TYPE_PROCEDURAL_OBJECT = type_procedural_object

		self.__ATTRIBUTE = vec2(material.GetRegisteredIndex(), allowed_types.get(type_procedural_object, -1))


	def SetMaterial(self, material: Optional[Material]) -> None:
		self.__ATTRIBUTE.x = -1
		self.__MATERIAL = material
		if(material is not None): self.__ATTRIBUTE.x = material.GetRegisteredIndex()
	def GetMaterial(self) -> Optional[Material]: return self.__MATERIAL

	def SetTypeProcedural(self, type_procedural_object: AllowedTypes) -> None:
		self.__CURENT_TYPE_PROCEDURAL_OBJECT = type_procedural_object
		self.__ATTRIBUTE.y = allowed_types.get(type_procedural_object, -1)
	def GetTypeProcedural(self) -> AllowedTypes: return self.__CURENT_TYPE_PROCEDURAL_OBJECT


	def _OnStart(self) -> None:
		if(self.__STATUS_ALLOCATED): return
		self.__ALLOCATE_INDEX = ProceduralController.AllocateIndex(self._WINDOW_ID)
		if(self.__ALLOCATE_INDEX < 0):
			PrintLog(f"[ERROR_{self.__class__.__name__}] it is impossible to allocate memory, the space of allocated areas greatly exceeds the allowable value of objects for allocation.", LogColors.RED)
			return

		IgameObject = self._IGAME_OBJECT
		IgameObject.allocateIndex()
		if(not IgameObject.getStatusAllocated()):
			ProceduralController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
			self.__ALLOCATE_INDEX = -1
			return

		numpy_array = ProceduralController.GetAllocateNumpy(self._WINDOW_ID)
		numpy_array[self.__ALLOCATE_INDEX]["transform_index"] = IgameObject.getAllocateIndex()
		self.__ATTRIBUTE.LinkMemory(numpy_array[self.__ALLOCATE_INDEX]["material_index_and_type_object"],0)

		IgameObject.appendAllocatableComponent()

		self.__STATUS_ALLOCATED = True



	def _OnDestroy(self) -> None:
		if(not self.__STATUS_ALLOCATED): return

		self.__ATTRIBUTE.UnlinkMemory()
		ProceduralController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
		self.__ALLOCATE_INDEX = -1
		self.__STATUS_ALLOCATED = False

		IgameObject = self._IGAME_OBJECT
		IgameObject.removeAllocatableComponent()

		if(IgameObject.getAllocatableComponentCount() > 0): return
		IgameObject.deallocateIndex()



