
from typing import Dict, Set, List, Literal, get_args
from numpy import dtype, float32, int32, uint32, ndarray, zeros

from ..ApiGraphics import CreateSSBOBuffer, UpdateSSBOBuffer, DestroySSBOBuffer

SSBO_INDEX = 42
SSBO_LIMIT = 100

typedata = dtype([
	("material_index_and_type_object", float32, (3)),
	("transform_index", int32, (1)),
], align=True)


AllowedTypes = Literal[
	"Sphere",
	"Cube"
]

allowed_types = {t: i for i, t in enumerate(get_args(AllowedTypes))}




class ProceduralController:

	__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS: Dict[int, Set[int]] = {}
	__NUMPY_ARRAY_CAMERAS_LINK: Dict[int, ndarray] = {}
	__LIST_OF_REGISTERED_PROCEDURAL: Dict[int, List[int]] = {}
	__SSBO: Dict[int, uint32] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))
		cls.__NUMPY_ARRAY_CAMERAS_LINK[window_id] = zeros(SSBO_LIMIT, dtype=typedata)
		cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id] = []
		cls.__SSBO[window_id] = CreateSSBOBuffer(SSBO_INDEX, zeros(SSBO_LIMIT, dtype=typedata))

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))
		cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id].clear()

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS.pop(window_id, None)
		cls.__NUMPY_ARRAY_CAMERAS_LINK.pop(window_id, None)
		cls.__LIST_OF_REGISTERED_PROCEDURAL.pop(window_id, None)
		ssbo = cls.__SSBO.pop(window_id)
		DestroySSBOBuffer(ssbo)
	

	@classmethod
	def GetAllocateNumpy(cls, window_id: int) -> ndarray:
		return cls.__NUMPY_ARRAY_CAMERAS_LINK[window_id]

	@classmethod
	def AllocateIndex(cls, window_id: int) -> int:
		s = cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS[window_id]
		if(s):
			index = s.pop()
			cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id].append(index)
			return index
		return -1

	@classmethod
	def DeallocateIndex(cls, index: int, window_id: int) -> None:
		cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id].remove(index)
		cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS[window_id].add(index)
	

	@classmethod
	def UpdateBuffer(cls, window_id: int) -> int:
		procedurals =cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id]
		UpdateSSBOBuffer(cls.__SSBO[window_id], cls.__NUMPY_ARRAY_CAMERAS_LINK[window_id][procedurals])
		return len(procedurals)