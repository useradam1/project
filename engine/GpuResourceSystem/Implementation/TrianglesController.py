
from typing import Dict, Set, List, Literal, get_args, Tuple, Optional
from dataclasses import dataclass
from numpy import dtype, float32, int32, uint32, ndarray, zeros, uint8, array

from ...Math import vec2, vec2_ptr_static

from ...ApiGraphics import CreateStaticSSBOBuffer, DestroySSBOBuffer

SSBO_INDEX = 43
SSBO_LIMIT = 9000000

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






class TrianglesController:

	__OBSLATE: Dict[int, bool] = {}
	__OCCUPIED_INDEXES: Dict[int, Dict[int, Set[vec2]]] = {}
	__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX: Dict[int, int] = {}
	__NUMPY_ARRAY_TRIANGLES_LINK: Dict[int, ndarray] = {}
	__SSBO: Dict[int, uint32] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__OBSLATE[window_id] = True
		cls.__OCCUPIED_INDEXES[window_id] = {}
		cls.__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX[window_id] = 0
		cls.__NUMPY_ARRAY_TRIANGLES_LINK[window_id] = zeros(SSBO_LIMIT, dtype=triangles_data_dtype)
		#cls.__SSBO[window_id] = CreateSSBOBuffer(SSBO_INDEX, zeros(SSBO_LIMIT, dtype=triangles_data_dtype))



		# triangles = array(
		# 	[
		# 		(
		# 		(2, 6, -2, 0), (-2, 6, -2, 0), (0, 6, 2, 0),	# posA, posB, posC
		# 		(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 		(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 		),
		# 		(
		# 		(2, 3, -2, 0), (-2, 3, -2, 0), (0, 3, 2, 0),	# posA, posB, posC
		# 		(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 		(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 		),
		# 		(
		# 		(2, -3, -2, 0), (-2, -3, -2, 0), (0, -3, 2, 0),	# posA, posB, posC
		# 		(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 		(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 		),
		# 		(
		# 		(2, -6, -2, 0), (-2, -6, -2, 0), (0, -6, 2, 0),	# posA, posB, posC
		# 		(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 		(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 		),
		# 	],
		# 	dtype=triangles_data_dtype
		# )

		# start_index = cls.__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX[window_id]
		# stop_index = start_index + len(triangles)
		# cls.__NUMPY_ARRAY_TRIANGLES_LINK[window_id][start_index : stop_index] = triangles
		# cls.__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX[window_id] = stop_index


	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__OBSLATE[window_id] = True
		cls.__OCCUPIED_INDEXES[window_id].clear()
		cls.__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX[window_id] = 0

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__OBSLATE.pop(window_id, None)
		cls.__OCCUPIED_INDEXES.pop(window_id, None)
		cls.__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX.pop(window_id, None)
		cls.__NUMPY_ARRAY_TRIANGLES_LINK.pop(window_id, None)

		if(window_id not in cls.__SSBO): return
		ssbo = cls.__SSBO.pop(window_id)
		DestroySSBOBuffer(ssbo)


	@classmethod
	def AppendTriangles(cls,
			mesh_geometry_procedure_id: int, 
			triangles: ndarray, 
			window_id: int
		) -> Optional[vec2_ptr_static]:

		start_index = cls.__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX[window_id]
		stop_index = start_index + len(triangles)
		cls.__NUMPY_ARRAY_TRIANGLES_LINK[window_id][start_index : stop_index] = triangles
		cls.__NUMPY_ARRAY_TRIANGLES_LINK_LAST_UNOCCUPIED_INDEX[window_id] = stop_index
		cls.__OBSLATE[window_id] = True




	@classmethod
	def RemoveTriangles(cls, mesh_geometry_procedure_id: int) -> None:
		pass



	@classmethod
	def UpdateBuffer(cls, window_id: int) -> None:
		if(not cls.__OBSLATE[window_id]): return
		if(window_id in cls.__SSBO): DestroySSBOBuffer(cls.__SSBO[window_id])
		cls.__SSBO[window_id] = CreateStaticSSBOBuffer(SSBO_INDEX, cls.__NUMPY_ARRAY_TRIANGLES_LINK[window_id])
		cls.__OBSLATE[window_id] = False