from ...ApiGraphics import CreateSSBOBuffer, DestroySSBOBuffer, UpdateSSBOBuffer


from numpy import dtype, float32, int32, uint32, ndarray, zeros, uint8, array

from typing import Dict, Set, List, Literal, get_args, Tuple, Optional



SSBO_INDEX_TRIANGLE = 43
SSBO_LIMIT_TRIANGLE = 10000000
triangles_data_dtype = dtype([
	("posA", float32, (4)),
	("posB", float32, (4)),
	("posC", float32, (4)),
	("normalA", float32, (4)),
	("normalB", float32, (4)),
	("normalC", float32, (4)),
	("uvA", float32, (4)),
	("uvB", float32, (4)),
	("uvC", float32, (4)),
])


SSBO_INDEX_BVH = 44
SSBO_LIMIT_BVH = 2000000
bvh_data_dtype = dtype([
	("next_left_bvh", int32, (1)),
	("next_right_bvh", int32, (1)),
	("start_index", int32, (1)),
	("stop_index", int32, (1)),
	("volumeA", float32, (4)),
	("volumeB", float32, (4)),
])


SSBO_INDEX_MESH = 45
SSBO_LIMIT_MESH = 10
mesh_data_dtype = dtype([
	("bvh_index", int32, (1)),
	("padding1", int32, (1)),
	("padding2", int32, (1)),
	("padding3", int32, (1)),
])


class MeshController:

	__OBSLATE: Dict[int, bool] = {}

	__NUMPY_ARRAY_TRIANGLES_OCCUPIED_CELLS: Dict[int, int] = {}
	__NUMPY_ARRAY_TRIANGLES: Dict[int, ndarray] = {}
	__SSBO_TRIANGLES: Dict[int, uint32] = {}

	__NUMPY_ARRAY_BVH_OCCUPIED_CELLS: Dict[int, int] = {}
	__NUMPY_ARRAY_BVH: Dict[int, ndarray] = {}
	__SSBO_BVH: Dict[int, uint32] = {}

	__NUMPY_ARRAY_MESHES_FREE_CELLS: Dict[int, Set[int]] = {}
	__NUMPY_ARRAY_MESHES: Dict[int, ndarray] = {}
	__SSBO_MESH: Dict[int, uint32] = {}



	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__OBSLATE[window_id] = True

		cls.__NUMPY_ARRAY_TRIANGLES_OCCUPIED_CELLS[window_id] = 0
		cls.__NUMPY_ARRAY_TRIANGLES[window_id] = zeros(SSBO_LIMIT_TRIANGLE, dtype=triangles_data_dtype)
		cls.__SSBO_TRIANGLES[window_id] = CreateSSBOBuffer(SSBO_INDEX_TRIANGLE, cls.__NUMPY_ARRAY_TRIANGLES[window_id])

		cls.__NUMPY_ARRAY_BVH_OCCUPIED_CELLS[window_id] = 0
		cls.__NUMPY_ARRAY_BVH[window_id] = zeros(SSBO_LIMIT_BVH, dtype=bvh_data_dtype)
		cls.__SSBO_BVH[window_id] = CreateSSBOBuffer(SSBO_INDEX_BVH, cls.__NUMPY_ARRAY_BVH[window_id])

		cls.__NUMPY_ARRAY_MESHES_FREE_CELLS[window_id] = set(range(SSBO_LIMIT_MESH))
		cls.__NUMPY_ARRAY_MESHES[window_id] = zeros(SSBO_LIMIT_MESH, dtype=mesh_data_dtype)
		cls.__SSBO_MESH[window_id] = CreateSSBOBuffer(SSBO_INDEX_MESH, cls.__NUMPY_ARRAY_MESHES[window_id])



	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__OBSLATE[window_id] = True

		cls.__NUMPY_ARRAY_TRIANGLES_OCCUPIED_CELLS[window_id] = 0

		cls.__NUMPY_ARRAY_BVH_OCCUPIED_CELLS[window_id] = 0

		cls.__NUMPY_ARRAY_MESHES_FREE_CELLS[window_id] = set(range(SSBO_LIMIT_MESH))



	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__OBSLATE.pop(window_id, None)

		cls.__NUMPY_ARRAY_TRIANGLES_OCCUPIED_CELLS.pop(window_id, None)
		cls.__NUMPY_ARRAY_TRIANGLES.pop(window_id, None)
		DestroySSBOBuffer(cls.__SSBO_TRIANGLES.pop(window_id))

		cls.__NUMPY_ARRAY_BVH_OCCUPIED_CELLS.pop(window_id, None)
		cls.__NUMPY_ARRAY_BVH.pop(window_id, None)
		DestroySSBOBuffer(cls.__SSBO_BVH.pop(window_id))

		cls.__NUMPY_ARRAY_MESHES_FREE_CELLS.pop(window_id, None)
		cls.__NUMPY_ARRAY_MESHES.pop(window_id, None)
		DestroySSBOBuffer(cls.__SSBO_MESH.pop(window_id))




	@classmethod
	def GetAllocateNumpy(cls, window_id: int) -> ndarray:
		return cls.__NUMPY_ARRAY_MESHES[window_id]

	@classmethod
	def AllocateIndex(cls, window_id: int) -> int:
		s = cls.__NUMPY_ARRAY_MESHES_FREE_CELLS[window_id]
		if(s):
			index = s.pop()
			cls.__OBSLATE[window_id] = True
			return index
		return -1

	@classmethod
	def DeallocateIndex(cls, index: int, window_id: int) -> None:
		cls.__NUMPY_ARRAY_MESHES_FREE_CELLS[window_id].add(index)
		cls.__OBSLATE[window_id] = True
	
	@classmethod
	def SetStatusChanged(cls, window_id: int) -> None:
		cls.__OBSLATE[window_id] = True



	@classmethod
	def PushTriangles(cls, triangles: ndarray, window_id: int) -> None:
		start_index = cls.__NUMPY_ARRAY_TRIANGLES_OCCUPIED_CELLS[window_id]
		stop_index = start_index + len(triangles)
		cls.__NUMPY_ARRAY_TRIANGLES_OCCUPIED_CELLS[window_id] = stop_index
		cls.__NUMPY_ARRAY_TRIANGLES[window_id][start_index : stop_index] = triangles
		cls.__OBSLATE[window_id] = True

	@classmethod
	def PushBVH(cls, allocated_index: int, bvh_data: ndarray, window_id: int) -> None:
		start_index = cls.__NUMPY_ARRAY_BVH_OCCUPIED_CELLS[window_id]
		stop_index = start_index + len(bvh_data)
		cls.__NUMPY_ARRAY_BVH_OCCUPIED_CELLS[window_id] = stop_index

		start_index_triangles = cls.__NUMPY_ARRAY_TRIANGLES_OCCUPIED_CELLS[window_id]
		normalized_bvh_data = bvh_data.copy()
		for i in range(len(bvh_data)):
			normalized_bvh_data[i]["next_left_bvh"] += start_index
			normalized_bvh_data[i]["next_right_bvh"] += start_index
			if(normalized_bvh_data[i]["start_index"] >= 0):
				normalized_bvh_data[i]["start_index"] += start_index_triangles
				normalized_bvh_data[i]["stop_index"] += start_index_triangles

		cls.__NUMPY_ARRAY_BVH[window_id][start_index : stop_index] = normalized_bvh_data

		cls.__NUMPY_ARRAY_MESHES[window_id][allocated_index]["bvh_index"] = start_index
		cls.__OBSLATE[window_id] = True



	@classmethod
	def UpdateBuffer(cls, window_id: int) -> None:
		if(not cls.__OBSLATE[window_id]): return
		UpdateSSBOBuffer(cls.__SSBO_TRIANGLES[window_id], cls.__NUMPY_ARRAY_TRIANGLES[window_id])
		UpdateSSBOBuffer(cls.__SSBO_BVH[window_id], cls.__NUMPY_ARRAY_BVH[window_id])
		UpdateSSBOBuffer(cls.__SSBO_MESH[window_id], cls.__NUMPY_ARRAY_MESHES[window_id])
		cls.__OBSLATE[window_id] = False