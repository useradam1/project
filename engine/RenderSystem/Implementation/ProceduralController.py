
from typing import Dict, Set, List, Literal, get_args
from numpy import dtype, float32, int32, uint32, ndarray, zeros, uint8

from ...ApiGraphics import CreateSSBOBuffer, UpdateSSBOBuffer, DestroySSBOBuffer

SSBO_INDEX = 42
SSBO_LIMIT = 100

typedata = dtype([
	("material_index", int32, (1)),
	("object_type", int32, (1)),
	("transform_index", int32, (1)),
	("padding", int32, (1)),
])


AllowedTypes = Literal[
	"Sphere",
	"Cube"
]

allowed_types = {t: i for i, t in enumerate(get_args(AllowedTypes))}




class ProceduralController:

	__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS: Dict[int, Set[int]] = {}
	__NUMPY_ARRAY_CAMERAS_LINK: Dict[int, ndarray] = {}
	__LIST_OF_REGISTERED_PROCEDURAL: Dict[int, ndarray[tuple[int], dtype[uint8]]] = {}
	__SSBO: Dict[int, uint32] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))
		cls.__NUMPY_ARRAY_CAMERAS_LINK[window_id] = zeros(SSBO_LIMIT, dtype=typedata)
		cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id] = zeros(SSBO_LIMIT, dtype= bool)
		cls.__SSBO[window_id] = CreateSSBOBuffer(SSBO_INDEX, zeros(SSBO_LIMIT, dtype=typedata))

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))
		cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id].fill(False)

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
			cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id][index] = True
			return index
		return -1

	@classmethod
	def DeallocateIndex(cls, index: int, window_id: int) -> None:
		cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id][index] = False
		cls.__NUMPY_ARRAY_CAMERAS_LINK_FREE_CELLS[window_id].add(index)
	

	@classmethod
	def UpdateBuffer(cls, window_id: int) -> int:
		procedurals = cls.__NUMPY_ARRAY_CAMERAS_LINK[window_id][cls.__LIST_OF_REGISTERED_PROCEDURAL[window_id]]
		UpdateSSBOBuffer(cls.__SSBO[window_id], procedurals)
		return len(procedurals)