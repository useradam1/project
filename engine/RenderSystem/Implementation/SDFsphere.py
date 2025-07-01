from ...SceneObjectsSystem import Component
from ...WindowSystem import WindowContextSystem

from .ProceduralSDFController import ProceduralSDFController, allowed_types, AllowedTypes, AllowedOperators, allowed_operators
from ...Log import LogColors, PrintLog

from ...GpuResourceSystem import Material

from ...Math import vec4, mat4

from typing import Optional
from numpy import ndarray



class SDFsphere(Component):

	__STATUS_ALLOCATED: bool
	__ALLOCATE_INDEX: int

	__MATERIAL: Optional[Material]

	__MATERIAL_ID: int
	__CURRENT_OPERATOR: AllowedOperators
	__PARAM: mat4

	__NUMPY_ARRAY: Optional[ndarray]


	def __init__(self,
			material: Material,
			operator: AllowedOperators,
			repetition: vec4,
			radius_size: float,
		) -> None:
		self.__STATUS_ALLOCATED = False
		self.__ALLOCATE_INDEX = -1

		self.__MATERIAL = material

		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()
		self.__PARAM = mat4()
		self.__PARAM[0] = radius_size
		self.__CURRENT_OPERATOR = operator
		self.__PARAM[15] = allowed_operators[operator]
		self.__PARAM[8] = repetition[0]
		self.__PARAM[9] = repetition[1]
		self.__PARAM[10] = repetition[2]
		self.__PARAM[11] = repetition[3]

		self.__NUMPY_ARRAY = None

	def SetOperator(self, operator: AllowedOperators) -> None:
		self.__CURRENT_OPERATOR = operator
		self.__PARAM[15] = allowed_operators[operator]
		if(self.__STATUS_ALLOCATED):
			ProceduralSDFController.SetStatusChanged(self._WINDOW_ID)
	def GetOperator(self) -> AllowedOperators:
		return self.__CURRENT_OPERATOR

	def SetRepetition(self, repetition: vec4) -> None:
		self.__PARAM[8] = repetition[0]
		self.__PARAM[9] = repetition[1]
		self.__PARAM[10] = repetition[2]
		self.__PARAM[11] = repetition[3]
		if(self.__STATUS_ALLOCATED):
			ProceduralSDFController.SetStatusChanged(self._WINDOW_ID)

	def GetRepetition(self) -> vec4:
		return vec4(
			self.__PARAM[8],
			self.__PARAM[9],
			self.__PARAM[10],
			self.__PARAM[11],
		)


	def SetRadiusSize(self, value: float) -> None:
		self.__PARAM[0] = value
		if(self.__STATUS_ALLOCATED):
			ProceduralSDFController.SetStatusChanged(self._WINDOW_ID)
	
	def GetRadiusSize(self) -> float:
		return self.__PARAM[0]


	def SetMaterial(self, material: Optional[Material]) -> None:
		self.__MATERIAL = material
		self.__MATERIAL_ID = -1 if(material is None) else material.GetRegisteredIndex()
		if(self.__STATUS_ALLOCATED):
			self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["material_index"] = self.__MATERIAL_ID # type: ignore
			ProceduralSDFController.SetStatusChanged(self._WINDOW_ID)
	def GetMaterial(self) -> Optional[Material]: return self.__MATERIAL


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

		type_object: AllowedTypes = "Sphere"
		self.__NUMPY_ARRAY[self.__ALLOCATE_INDEX]["object_type"] = allowed_types.get(type_object, -1)
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



