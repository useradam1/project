from .MaterialInterface import MaterialInterface, allowed_type_uniform
from .Texture2D import Texture2D
from ...ApiGraphics import allowed_types_shader, CreateMaterialBuffer, UpdateMaterialBuffer, DestroyMaterialBuffer
from ...Math import *

from typing import Dict, Set, Tuple

from numpy import dtype, float32, int32, uint32, uint8, ndarray, zeros, delete


from ...Log import LogColors, PrintLog
from ...CustomMetaclass import TaskQueue


convertor = {
	'bool': lambda x: (x, uint32),
	'int': lambda x: (x, int32),
	'float': lambda x: (x, float32),
	'vec2': lambda x: (x, float32, 2),
	'vec3': lambda x: (x, float32, 3),
	'vec4': lambda x: (x, float32, 4),
	'mat2': lambda x: (x, float32, 4),
	'mat3': lambda x: (x, float32, 9),
	'mat4': lambda x: (x, float32, 16),
	'Texture2D': lambda x: x,
	'Texture3D': lambda x: x,
	None: None
}


get_primitive = {
	'bool': lambda x: x,
	'int': lambda x: x,
	'float': lambda x: x,
	'vec2': lambda x: x.CreateCType(),
	'vec3': lambda x: x.CreateCType(),
	'vec4': lambda x: x.CreateCType(),
	'mat2': lambda x: x.CreateCType(),
	'mat3': lambda x: x.CreateCType(),
	'mat4': lambda x: x.CreateCType(),
	'Texture2D': lambda x: x.GetObject(),
	'Texture3D': lambda x: x,
	None: None
}





class MaterialControllerSystem:

	__ENABLE_QUEUE_MATERIAL: Dict[int, bool] = {}
	__ALL_MATERIALS: Dict[int, Set[MaterialInterface]] = {}

	__DESCRIPTOR_MATERIAL: Dict[int, Dict[int, dtype]] = {}
	__CONFIRMED_MATERIALS_LENGHT: Dict[int, Dict[int, int]] = {}
	__CONFIRMED_MATERIALS_INDEX: Dict[int, Dict[int, Dict[int, int]]] = {}
	__CONFIRMED_MATERIALS_DATA: Dict[int, Dict[int, Dict[int, Dict[str, allowed_type_uniform]]]] = {}

	__CREATION_NDARRAY_DATA_REQUEST: Dict[int, Set[int]] = {}
	__CREATION_REQUEST: Dict[int, bool] = {}

	__UPDATE_NDARRAY_DATA_REQUEST: Dict[int, Dict[int, Dict[int, int]]] = {}
	__UPDATE_REQUEST: Dict[int, bool] = {}

	__DELETE_FROM_NDARRAY_DATA_BY_INDEX_REQUEST: Dict[int, Dict[int, Set[int]]] = {}
	__DELETE_FROM_REQUEST: Dict[int, bool] = {}

	__DESTRUCTION_NDARRAY_DATA_REQUEST: Dict[int, Set[int]] = {}
	__DESTRUCTION_REQUEST: Dict[int, bool] = {}

	__NDARRAY_DATA_MATERIAL: Dict[int, Dict[int, ndarray]] = {}

	__SSBO: Dict[int, Dict[int, uint32]] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_MATERIAL[window_id] = True
		cls.__ALL_MATERIALS[window_id] = set()

		cls.__DESCRIPTOR_MATERIAL[window_id] = {}
		cls.__CONFIRMED_MATERIALS_LENGHT[window_id] = {}
		cls.__CONFIRMED_MATERIALS_INDEX[window_id] = {}
		cls.__CONFIRMED_MATERIALS_DATA[window_id] = {}

		cls.__CREATION_NDARRAY_DATA_REQUEST[window_id] = set()
		cls.__CREATION_REQUEST[window_id] = False

		cls.__UPDATE_NDARRAY_DATA_REQUEST[window_id] = {}
		cls.__UPDATE_REQUEST[window_id] = False

		cls.__DELETE_FROM_NDARRAY_DATA_BY_INDEX_REQUEST[window_id] = {}
		cls.__DELETE_FROM_REQUEST[window_id] = False

		cls.__DESTRUCTION_NDARRAY_DATA_REQUEST[window_id] = set()
		cls.__DESTRUCTION_REQUEST[window_id] = False

		cls.__NDARRAY_DATA_MATERIAL[window_id] = {}

		cls.__SSBO[window_id] = {}


	@classmethod
	def WindowFlush(cls, window_id: int) -> None:

		cls.__ENABLE_QUEUE_MATERIAL[window_id] = False
		materials = cls.__ALL_MATERIALS[window_id]
		for material in materials: material.Destroy()
		cls.__ENABLE_QUEUE_MATERIAL[window_id] = True
		materials.clear()

		cls.__DESCRIPTOR_MATERIAL[window_id].clear()
		cls.__CONFIRMED_MATERIALS_LENGHT[window_id].clear()
		cls.__CONFIRMED_MATERIALS_INDEX[window_id].clear()
		cls.__CONFIRMED_MATERIALS_DATA[window_id].clear()

		cls.__CREATION_NDARRAY_DATA_REQUEST[window_id].clear()
		cls.__CREATION_REQUEST[window_id] = False

		cls.__UPDATE_NDARRAY_DATA_REQUEST[window_id].clear()
		cls.__UPDATE_REQUEST[window_id] = False

		cls.__DELETE_FROM_NDARRAY_DATA_BY_INDEX_REQUEST[window_id].clear()
		cls.__DELETE_FROM_REQUEST[window_id] = False

		cls.__DESTRUCTION_NDARRAY_DATA_REQUEST[window_id].clear()
		cls.__DESTRUCTION_REQUEST[window_id] = False

		cls.__NDARRAY_DATA_MATERIAL[window_id].clear()

		for _, ssbo_id in cls.__SSBO[window_id].items():
			DestroyMaterialBuffer(ssbo_id)
		cls.__SSBO[window_id].clear()


	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:

		cls.__ENABLE_QUEUE_MATERIAL[window_id] = False
		for material in cls.__ALL_MATERIALS[window_id]: material.Destroy()
		cls.__ENABLE_QUEUE_MATERIAL.pop(window_id, None)
		cls.__ALL_MATERIALS.pop(window_id, None)

		cls.__DESCRIPTOR_MATERIAL.pop(window_id, None)
		cls.__CONFIRMED_MATERIALS_LENGHT.pop(window_id, None)
		cls.__CONFIRMED_MATERIALS_INDEX.pop(window_id, None)
		cls.__CONFIRMED_MATERIALS_DATA.pop(window_id, None)

		cls.__CREATION_NDARRAY_DATA_REQUEST.pop(window_id, None)
		cls.__CREATION_REQUEST.pop(window_id, None)

		cls.__UPDATE_NDARRAY_DATA_REQUEST.pop(window_id, None)
		cls.__UPDATE_REQUEST.pop(window_id, None)

		cls.__DELETE_FROM_NDARRAY_DATA_BY_INDEX_REQUEST.pop(window_id, None)
		cls.__DELETE_FROM_REQUEST.pop(window_id, None)

		cls.__DESTRUCTION_NDARRAY_DATA_REQUEST.pop(window_id, None)
		cls.__DESTRUCTION_REQUEST.pop(window_id, None)

		cls.__NDARRAY_DATA_MATERIAL.pop(window_id, None)

		for _, ssbo_id in cls.__SSBO[window_id].items():
			DestroyMaterialBuffer(ssbo_id)
		cls.__SSBO.pop(window_id, None)


	@classmethod
	def GetRegisteredIndexOfMaterial(cls, ssbo_index: int, material_id: int, window_id: int) -> int:
		by_ssbo = cls.__CONFIRMED_MATERIALS_INDEX[window_id].get(ssbo_index)
		if(by_ssbo is None): return -1
		return by_ssbo.get(material_id, -1)



	@classmethod
	def AppendMaterialDescriptor(cls, material: MaterialInterface, material_descriptor: Tuple[int, Dict[str, allowed_types_shader]], window_id: int) -> None:
		ssbo_index = material_descriptor[0]

		dtype_material = cls.__DESCRIPTOR_MATERIAL[window_id]
		confirmed_materials_lenght = cls.__CONFIRMED_MATERIALS_LENGHT[window_id]
		confirmed_materials_index = cls.__CONFIRMED_MATERIALS_INDEX[window_id]
		confirmed_materials_data = cls.__CONFIRMED_MATERIALS_DATA[window_id]

		data = [convertor[t](name) for name, t in material_descriptor[1].items()]
		data.append(('padding', uint8, len(data)))
		material_dtype = dtype(data)

		if(ssbo_index in dtype_material):
			if(material_dtype != dtype_material[ssbo_index]):
				PrintLog(f"[ERROR] Conflict of materials, the material cannot be added due to the fact that there was a conflict of indexes in the shaders[Existing: {dtype_material[ssbo_index]}, New: {material_dtype}, Index: {ssbo_index}]", LogColors.RED)
				return
			material_id = material.GetId()
			confirmed_materials_index[ssbo_index][material_id] = confirmed_materials_lenght[ssbo_index]
			confirmed_materials_data[ssbo_index][material_id] = material.GetUniforms()
		else:
			dtype_material[ssbo_index] = material_dtype
			confirmed_materials_lenght[ssbo_index] = 0
			material_id = material.GetId()
			confirmed_materials_index[ssbo_index] = {material_id: 0}
			confirmed_materials_data[ssbo_index] = {material_id: material.GetUniforms()}

		confirmed_materials_lenght[ssbo_index] += 1
		cls.__CREATION_NDARRAY_DATA_REQUEST[window_id].add(ssbo_index)

		cls.__CREATION_REQUEST[window_id] = True

	@classmethod
	def RemoveMaterialDescriptor(cls, material: MaterialInterface, ssbo_index: int, window_id: int) -> None:
		material_id = material.GetId()

		confirmed_materials_lenght = cls.__CONFIRMED_MATERIALS_LENGHT[window_id][ssbo_index]
		confirmed_materials_index = cls.__CONFIRMED_MATERIALS_INDEX[window_id][ssbo_index]

		index_deleted_material = confirmed_materials_index.pop(material_id, -1)
		cls.__CONFIRMED_MATERIALS_DATA[window_id][ssbo_index].pop(material_id, None)
		confirmed_materials_lenght -= 1


		if(confirmed_materials_lenght == 0):
			cls.__DESCRIPTOR_MATERIAL[window_id].pop(ssbo_index, None)
			cls.__CREATION_NDARRAY_DATA_REQUEST[window_id].discard(ssbo_index)
			cls.__DELETE_FROM_NDARRAY_DATA_BY_INDEX_REQUEST[window_id].pop(ssbo_index, None)
			cls.__DESTRUCTION_NDARRAY_DATA_REQUEST[window_id].add(ssbo_index)
			cls.__DESTRUCTION_REQUEST[window_id] = True
			return

		for k in (k for k, v in confirmed_materials_index.items() if v > index_deleted_material):
			confirmed_materials_index[k] -= 1
		
		delete_from = cls.__DELETE_FROM_NDARRAY_DATA_BY_INDEX_REQUEST[window_id]
		if(ssbo_index not in delete_from): delete_from[ssbo_index] = set([index_deleted_material])
		else: delete_from[ssbo_index].add(index_deleted_material)
		cls.__DELETE_FROM_REQUEST[window_id] = True


	@classmethod
	def UpdateMaterialDescriptor(cls, material: MaterialInterface, ssbo_index: int, window_id: int) -> None:
		material_id = material.GetId()
		material_index = cls.__CONFIRMED_MATERIALS_INDEX[window_id][ssbo_index][material_id]
		cls.__CONFIRMED_MATERIALS_DATA[window_id][ssbo_index][material_index] = material.GetUniforms()
		
		update = cls.__UPDATE_NDARRAY_DATA_REQUEST[window_id]
		if(ssbo_index not in update): update[ssbo_index] = {material_id: material_index}
		else: update[ssbo_index][material_id] = material_index
		cls.__UPDATE_REQUEST[window_id] = True


	@classmethod
	def UpdateNdArrayDataRequest(cls, window_id: int) -> None:
		if(not cls.__UPDATE_REQUEST[window_id]): return
		update_ndarray_data_request_in_window = cls.__UPDATE_NDARRAY_DATA_REQUEST[window_id]
		descriptor_material = cls.__DESCRIPTOR_MATERIAL[window_id]
		confirmed_materials_data = cls.__CONFIRMED_MATERIALS_DATA[window_id]
		ndarray_data_material = cls.__NDARRAY_DATA_MATERIAL[window_id]

		ssbo = cls.__SSBO[window_id]

		for ssbo_index, materials_index in update_ndarray_data_request_in_window.items():
			material_dtype = descriptor_material[ssbo_index]
			materials_data = confirmed_materials_data[ssbo_index]
			materials_ndarray_data = ndarray_data_material[ssbo_index]

			for material_class_id, index in materials_index.items():
				material_data = materials_data[material_class_id]
				for field_name in material_dtype.names: # type: ignore
					data = material_data.get(field_name)
					if(data is None): break
					primitive = get_primitive.get(data.__class__.__name__)
					if(primitive is None): break
					materials_ndarray_data[index][field_name] = primitive(data)

			#ndarray_data_material[ssbo_index] = materials_ndarray_data
			UpdateMaterialBuffer(ssbo[ssbo_index], materials_ndarray_data)

		cls.__UPDATE_REQUEST[window_id] = False


	@classmethod
	def DeleteFromNdArrayDataByIndexRequest(cls, window_id: int) -> None:
		if(not cls.__DELETE_FROM_REQUEST[window_id]): return
		delete_from_ndarray_data_by_index_request_in_window = cls.__DELETE_FROM_NDARRAY_DATA_BY_INDEX_REQUEST[window_id]
		ndarray_data_material = cls.__NDARRAY_DATA_MATERIAL[window_id]

		for ssbo_index, index_deleted_materials in delete_from_ndarray_data_by_index_request_in_window.items():
			for index_deleted_material in index_deleted_materials:
				ndarray_data_material[ssbo_index] = delete(ndarray_data_material[ssbo_index], index_deleted_material)
			UpdateMaterialBuffer(cls.__SSBO[window_id][ssbo_index], ndarray_data_material[ssbo_index])

		delete_from_ndarray_data_by_index_request_in_window.clear()
		cls.__DELETE_FROM_REQUEST[window_id] = False

	@classmethod
	def DestroyNdArrayDataRequest(cls, window_id: int) -> None:
		if(not cls.__DESTRUCTION_REQUEST[window_id]): return
		destruction_request_in_window = cls.__DESTRUCTION_NDARRAY_DATA_REQUEST[window_id]
		for ssbo_index in destruction_request_in_window:
			cls.__NDARRAY_DATA_MATERIAL[window_id].pop(ssbo_index, None)
			DestroyMaterialBuffer(cls.__SSBO[window_id][ssbo_index])
		destruction_request_in_window.clear()
		cls.__DESTRUCTION_REQUEST[window_id] = False


	@classmethod
	def CreateNdArrayDataRequest(cls, window_id: int) -> None:
		if(not cls.__CREATION_REQUEST[window_id]): return
		creation_request_in_window = cls.__CREATION_NDARRAY_DATA_REQUEST[window_id]
		descriptor_material = cls.__DESCRIPTOR_MATERIAL[window_id]
		confirmed_materials_lenght = cls.__CONFIRMED_MATERIALS_LENGHT[window_id]
		confirmed_materials_index = cls.__CONFIRMED_MATERIALS_INDEX[window_id]
		confirmed_materials_data = cls.__CONFIRMED_MATERIALS_DATA[window_id]
		ndarray_data_material = cls.__NDARRAY_DATA_MATERIAL[window_id]

		ssbo = cls.__SSBO[window_id]

		for ssbo_index in creation_request_in_window:
			material_dtype = descriptor_material[ssbo_index]
			num_materials = confirmed_materials_lenght[ssbo_index]
			materials_index = confirmed_materials_index[ssbo_index]
			materials_data = confirmed_materials_data[ssbo_index]
			materials_ndarray_data = zeros(num_materials, dtype= material_dtype)

			for material_class_id, index in materials_index.items():
				material_data = materials_data[material_class_id]
				for field_name in material_dtype.names: # type: ignore
					data = material_data.get(field_name)
					if(data is None): break
					primitive = get_primitive.get(data.__class__.__name__)
					if(primitive is None): break
					materials_ndarray_data[index][field_name] = primitive(data)

			ndarray_data_material[ssbo_index] = materials_ndarray_data
		
			ssbo[ssbo_index] = CreateMaterialBuffer(ssbo_index, materials_ndarray_data)
		
		creation_request_in_window.clear()
		cls.__CREATION_REQUEST[window_id] = False


	@classmethod
	def CheckQueueChange(cls, window_id: int) -> None:
		cls.CreateNdArrayDataRequest(window_id)
		cls.DestroyNdArrayDataRequest(window_id)
		cls.DeleteFromNdArrayDataByIndexRequest(window_id)
		cls.UpdateNdArrayDataRequest(window_id)


	@classmethod
	def AppendMaterial(cls, material: MaterialInterface, window_id: int) -> bool:
		if(not cls.__ENABLE_QUEUE_MATERIAL[window_id]): return False
		cls.__ALL_MATERIALS[window_id].add(material)
		return True

	@classmethod
	def RemoveMaterial(cls, material: MaterialInterface, window_id: int) -> None:
		if(not cls.__ENABLE_QUEUE_MATERIAL[window_id]): return
		cls.__ALL_MATERIALS[window_id].remove(material)