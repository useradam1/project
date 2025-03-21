
from typing import Dict, Set, List, Literal, get_args, Tuple, Optional
from dataclasses import dataclass
from numpy import dtype, float32, int32, uint32, ndarray, zeros, uint8, array

from ...Math import vec2, vec2_ptr_static

from ...ApiGraphics import CreateSSBOBuffer, UpdateSSBOBuffer, DestroySSBOBuffer

SSBO_INDEX = 44
SSBO_LIMIT = 40

bvh_data_dtype = dtype([
	("next_left_bvh", int32, (1)),
	("next_right_bvh", int32, (1)),
	("start_index", int32, (1)),
	("stop_index", int32, (1)),
	("volumeA", float32, (4)),
	("volumeB", float32, (4)),
])





class BvhController:

	__OBSLATE: Dict[int, bool] = {}
	__NUMPY_ARRAY_BVH_LINK_FREE_CELLS: Dict[int, Set[int]] = {}
	__NUMPY_ARRAY_BVH_LINK: Dict[int, ndarray] = {}
	__SSBO: Dict[int, uint32] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__OBSLATE[window_id] = True
		cls.__NUMPY_ARRAY_BVH_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))
		cls.__NUMPY_ARRAY_BVH_LINK[window_id] = zeros(SSBO_LIMIT, dtype=bvh_data_dtype)
		cls.__SSBO[window_id] = CreateSSBOBuffer(SSBO_INDEX, zeros(SSBO_LIMIT, dtype=bvh_data_dtype))



		# triangles = array(
		# 	[
		# 		(
		# 		(-1),							# next_left_bvh
		# 		(-1),							# next_right_bvh
		# 		(0),							# start_index
		# 		(1),							# stop_index
		# 		(-1, -1, -1, 0), (1, 1, 1, 0),	# volumeA, volumeB
		# 		),
		# 	],
		# 	dtype=bvh_data_dtype
		# )

		# cls.__NUMPY_ARRAY_BVH_LINK[window_id][0:1] = triangles


	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__OBSLATE[window_id] = True
		cls.__NUMPY_ARRAY_BVH_LINK_FREE_CELLS[window_id] = set(range(SSBO_LIMIT))

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__OBSLATE.pop(window_id, None)
		cls.__NUMPY_ARRAY_BVH_LINK_FREE_CELLS.pop(window_id, None)
		cls.__NUMPY_ARRAY_BVH_LINK.pop(window_id, None)
		ssbo = cls.__SSBO.pop(window_id)
		DestroySSBOBuffer(ssbo)


	@classmethod
	def AppendBVH(cls, bvh_data: ndarray, window_id: int) -> int:
		free_cells = cls.__NUMPY_ARRAY_BVH_LINK_FREE_CELLS[window_id]
		num_elements = len(bvh_data)
		
		# Проверяем, достаточно ли свободных ячеек
		if num_elements > len(free_cells):
			return -1
		
		# Выделяем реальные индексы для всех элементов данных
		real_indices = []
		for _ in range(num_elements):
			real_index = free_cells.pop()
			real_indices.append(real_index)
		
		ndarray_data = cls.__NUMPY_ARRAY_BVH_LINK[window_id]
		
		# Создаем карту для замены локальных индексов на реальные
		index_map = {local_idx: real_idx for local_idx, real_idx in enumerate(real_indices)}
		index_map[-1] = -1  # Для корректной обработки отсутствующих дочерних элементов
		
		# Обновляем индексы дочерних элементов и записываем данные
		for local_idx, real_idx in enumerate(real_indices):
			data = bvh_data[local_idx].copy()
			
			# Заменяем локальные индексы на реальные
			left = data["next_left_bvh"][0]
			right = data["next_right_bvh"][0]
			data["next_left_bvh"] = index_map.get(left, -1)
			data["next_right_bvh"] = index_map.get(right, -1)
			
			ndarray_data[real_idx] = data
		
		cls.__OBSLATE[window_id] = True
		return real_indices[0]  # Возвращаем корневой индекс




	@classmethod
	def RemoveBVH(cls, bvh_index: int, window_id: int) -> None:
		if bvh_index == -1:
			return
		
		# Собираем все дочерние индексы через обход в ширину
		nodes_to_remove = []
		queue = [bvh_index]
		
		while queue:
			current = queue.pop(0)
			nodes_to_remove.append(current)
			
			# Получаем дочерние элементы
			left = cls.__NUMPY_ARRAY_BVH_LINK[window_id][current]["next_left_bvh"][0]
			right = cls.__NUMPY_ARRAY_BVH_LINK[window_id][current]["next_right_bvh"][0]
			
			if left != -1:
				queue.append(left)
			if right != -1:
				queue.append(right)
		
		# Освобождаем ячейки
		free_cells = cls.__NUMPY_ARRAY_BVH_LINK_FREE_CELLS[window_id]
		for idx in nodes_to_remove:
			free_cells.add(idx)
		
		cls.__OBSLATE[window_id] = True

		




	@classmethod
	def UpdateBuffer(cls, window_id: int) -> None:
		if(not cls.__OBSLATE[window_id]): return
		UpdateSSBOBuffer(cls.__SSBO[window_id], cls.__NUMPY_ARRAY_BVH_LINK[window_id])
		cls.__OBSLATE[window_id] = False
		print(cls.__NUMPY_ARRAY_BVH_LINK[window_id])