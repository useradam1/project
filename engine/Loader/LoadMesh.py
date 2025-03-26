from .LoadCache import LoadData, SaveData, CACHE_DIR

import os
from dataclasses import dataclass
from numpy import float32, int32, ndarray, dtype, array, min as npmin, max as npmax
from typing import List, Tuple, NamedTuple




@dataclass
class Vertex:
	point: Tuple[float,float,float]
	normal: Tuple[float,float,float]
	uv: Tuple[float,float]


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
class TriangleData(NamedTuple):
	posA: Tuple[float,float,float,float]
	posB: Tuple[float,float,float,float]
	posC: Tuple[float,float,float,float]
	normalA: Tuple[float,float,float,float]
	normalB: Tuple[float,float,float,float]
	normalC: Tuple[float,float,float,float]
	uvA: Tuple[float,float,float,float]
	uvB: Tuple[float,float,float,float]
	uvC: Tuple[float,float,float,float]
bvh_data_dtype = dtype([
	("next_left_bvh", int32, (1)),
	("next_right_bvh", int32, (1)),
	("start_index", int32, (1)),
	("stop_index", int32, (1)),
	("volumeA", float32, (4)),
	("volumeB", float32, (4)),
])
class BvhData(NamedTuple):
	next_left_bvh: int
	next_right_bvh: int
	start_index: int
	stop_index: int
	volumeA: Tuple[float,float,float,float]
	volumeB: Tuple[float,float,float,float]


from numpy import  argmax, mean, vstack, empty, pad, zeros

class MeshData:
	__VERTICES: ndarray[tuple[int, int],dtype[float32]]
	__NORMALS: ndarray[tuple[int, int],dtype[float32]]
	__UV_COORDS: ndarray[tuple[int, int],dtype[float32]]
	__FACES: ndarray[tuple[int],dtype[int32]]

	__COUNT_FACES: int
	__MIN_VOLUME: Tuple[float,float,float]
	__MAX_VOLUME: Tuple[float,float,float]

	__BVH_DATA: ndarray
	__TRIANGLE_DATA: ndarray

	__V: List[Tuple[float,float,float]]
	__VN: List[Tuple[float,float,float]]
	__VT: List[Tuple[float,float]]
	__F: List[int]


	def __init__(self) -> None:
		self.__V = []
		self.__VN = []
		self.__VT = []
		self.__F = []

	def GetVertices(self) -> ndarray[tuple[int, int],dtype[float32]]: return self.__VERTICES
	def GetNormals(self) -> ndarray[tuple[int, int],dtype[float32]]: return self.__NORMALS
	def GetUvCoords(self) -> ndarray[tuple[int, int],dtype[float32]]: return self.__UV_COORDS
	def GetFaces(self) -> ndarray[tuple[int],dtype[int32]]: return self.__FACES

	def GetBvhData(self) -> ndarray: return self.__BVH_DATA
	def GetTriangleData(self) -> ndarray: return self.__TRIANGLE_DATA

	def GetCountFaces(self) -> int: return self.__COUNT_FACES
	def GetMinVolume(self) -> Tuple[float,float,float]: return self.__MIN_VOLUME
	def GetMaxVolume(self) -> Tuple[float,float,float]: return self.__MAX_VOLUME

	def AppendEdge(self, vertices: List[Vertex]) -> 'MeshData':
		start_index = len(self.__V)
		self.__V.extend(vertex.point for vertex in vertices)
		self.__VN.extend(vertex.normal for vertex in vertices)
		self.__VT.extend(vertex.uv for vertex in vertices)

		# triangulation
		max_len = len(vertices)
		if max_len == 3:
			self.__F.append(start_index)
			self.__F.append(start_index+1)
			self.__F.append(start_index+2)
		elif max_len == 4:
			self.__F.append(start_index)
			self.__F.append(start_index+1)
			self.__F.append(start_index+2)
			self.__F.append(start_index+2)
			self.__F.append(start_index+3)
			self.__F.append(start_index)
		elif max_len == 5:
			self.__F.append(start_index)
			self.__F.append(start_index+1)
			self.__F.append(start_index+2)
			self.__F.append(start_index)
			self.__F.append(start_index+2)
			self.__F.append(start_index+3)
			self.__F.append(start_index)
			self.__F.append(start_index+3)
			self.__F.append(start_index+4)
		
		return self

	def DecodeData(self) -> None:
		self.__VERTICES = array(self.__V, dtype=float32)
		self.__NORMALS = array(self.__VN, dtype=float32)
		self.__UV_COORDS = array(self.__VT, dtype=float32)
		self.__FACES = array(self.__F, dtype=int32)

		self.__COUNT_FACES = len(self.__FACES)
		self.__MIN_VOLUME = tuple(i for i in npmin(self.__VERTICES, axis=0))
		self.__MAX_VOLUME = tuple(i for i in npmax(self.__VERTICES, axis=0))

		self.__V.clear()
		self.__VN.clear()
		self.__VT.clear()
		self.__F.clear()

		self.__TRIANGLE_DATA = zeros(1, dtype=triangles_data_dtype)

		self.__BVH_DATA = zeros(1, dtype= bvh_data_dtype)
		


	#def BuildBVH(self) -> None:
		queue_test: List[Tuple[
			ndarray[Tuple[int, int], dtype[float32]],
			ndarray[Tuple[int, int], dtype[float32]],
			ndarray[Tuple[int, int], dtype[float32]],

			ndarray[Tuple[int], dtype[float32]], ndarray[Tuple[int], dtype[float32]]
		]] = []

		queue_separation: List[Tuple[
			ndarray[Tuple[int, int], dtype[float32]],
			ndarray[Tuple[int, int], dtype[float32]],
			ndarray[Tuple[int, int], dtype[float32]],

			ndarray[Tuple[int], dtype[float32]], ndarray[Tuple[int], dtype[float32]]
		]] = []


		bvh_list: List[BvhData] = []
		triangle_list: List[TriangleData] = []

		curent_triangle_index = 0
		curent_bvh_node_index = 0

		left_child_index = -1
		right_child_index = -1

		vert = self.__VERTICES[self.__FACES]
		queue_test.append((
			vert,
			self.__NORMALS[self.__FACES],
			self.__UV_COORDS[self.__FACES],

			npmin(self.__VERTICES, axis=0), npmax(self.__VERTICES, axis=0)
		))

		print()
		print(len(vert))

		for i in range(20):
			for master in queue_test:
				master_lenght = len(master[0])//3
				#if(master_lenght<=12):
				if(i>=12):
					PushTriangle(triangle_list, master[0], master[1], master[2])
					PushBvh(bvh_list, 
						-1, -1,
						curent_triangle_index, curent_triangle_index+master_lenght,
						(master[3][0],master[3][1],master[3][2],0),
						(master[4][0],master[4][1],master[4][2],0)
					)
					curent_triangle_index += master_lenght
				else:
					queue_separation.append(master)
					curent_bvh_node_index+=1
					left_child_index = curent_bvh_node_index
					curent_bvh_node_index+=1
					right_child_index = curent_bvh_node_index
					PushBvh(bvh_list, 
						left_child_index, right_child_index,
						-1, -1,
						(master[3][0],master[3][1],master[3][2],0),
						(master[4][0],master[4][1],master[4][2],0)
					)
			queue_test.clear()


			if(len(queue_separation) == 0): break
			for tested in queue_separation:
				(
					left_v, left_n, left_uv ,
					right_v, right_n, right_uv ,

					left_min_volume, left_max_volume,
					right_min_volume, right_max_volume,
				) = SeparationTriangles(
					tested[0], tested[1], tested[2]
				)

				queue_test.append((
					left_v, left_n, left_uv,
					left_min_volume, left_max_volume
				))
				queue_test.append((
					right_v, right_n, right_uv,
					right_min_volume, right_max_volume
				))
			queue_separation.clear()



		if(len(triangle_list)>0): self.__TRIANGLE_DATA = array(triangle_list, dtype=triangles_data_dtype)
		if(len(bvh_list)>0): self.__BVH_DATA = array(bvh_list, dtype= bvh_data_dtype)


		


def PushBvh(bvh_list: list[BvhData],
		next_left_bvh: int, next_right_bvh: int,
		start_index: int, stop_index: int,
		volumeA: Tuple[float,float,float,float],
		volumeB: Tuple[float,float,float,float]
	) -> None:
	bvh_list.append(
		BvhData(
			next_left_bvh,
			next_right_bvh,
			start_index,
			stop_index,
			volumeA,
			volumeB
		)
	)

def PushTriangle(triangle_list: list[TriangleData], vertices: ndarray, normals: ndarray, uv_coords: ndarray) -> None:
	for i in range(0, len(vertices) , 3):
		# Get the three vertices of the triangle
		v1, v2, v3 = vertices[i], vertices[i+1], vertices[i+2]
		# Get the three normals
		n1, n2, n3 = normals[i], normals[i+1], normals[i+2]
		# Get the three UV coordinates
		uv1, uv2, uv3 = uv_coords[i], uv_coords[i+1], uv_coords[i+2]
		triangle_list.append(TriangleData(
			posA=(v1[0], v1[1], v1[2], 0),
			posB=(v2[0], v2[1], v2[2], 0),
			posC=(v3[0], v3[1], v3[2], 0),
			normalA=(n1[0], n1[1], n1[2], 0),
			normalB=(n2[0], n2[1], n2[2], 0),
			normalC=(n3[0], n3[1], n3[2], 0),
			uvA=(uv1[0], uv1[1], 0, 0),
			uvB=(uv2[0], uv2[1], 0, 0),
			uvC=(uv3[0], uv3[1], 0, 0)
		))
		


def half_area_of_aabb(min_volume: ndarray, max_volume: ndarray) -> float:
	"""Вычисляет половину площади AABB."""
	sizes = max_volume - min_volume
	return sizes[0] * (sizes[1] + sizes[2]) + sizes[1] * sizes[2]

def compute_aabb(vertices: ndarray) -> Tuple[ndarray, ndarray]:
	"""Вычисляет min и max для набора вершин."""
	if vertices.size == 0:
		# Пустой AABB, для безопасности вернём нули
		return array([0.0, 0.0, 0.0], dtype=float32), array([0.0, 0.0, 0.0], dtype=float32)
	return vertices.min(axis=0), vertices.max(axis=0)

def evaluate_split(
	vertices: ndarray,
	axis: int,
	split_value: float
) -> Tuple[float, ndarray, ndarray]:
	"""
	Разделяет треугольники по заданному split_value на заданной axis.
	Возвращает (стоимость, left_indices, right_indices).
	"""
	# Собираем индексы треугольников, которые идут влево/вправо
	left_indices = []
	right_indices = []

	# Идём по треугольникам батчами по 3 вершины
	for i in range(0, len(vertices), 3):
		tri = vertices[i : i + 3]
		# Считаем среднее положение треугольника по выбранной оси
		center = mean(tri[:, axis])
		if center < split_value:
			left_indices.append(i)
		else:
			right_indices.append(i)

	# Если все треугольники ушли влево или вправо, 
	# «стоимость» будет не очень хорошая, но надо это учесть
	if len(left_indices) == 0 or len(right_indices) == 0:
		# Можно вернуть какую-то большую стоимость, 
		# чтобы алгоритм не выбирал такой сплит
		return float('inf'), array([]), array([])

	# Формируем массив вершин для левой/правой части
	left_vertices = vstack([vertices[idx:idx+3] for idx in left_indices])
	right_vertices = vstack([vertices[idx:idx+3] for idx in right_indices])

	# Считаем AABB и половину площади
	left_min, left_max = compute_aabb(left_vertices)
	right_min, right_max = compute_aabb(right_vertices)

	half_area_left = half_area_of_aabb(left_min, left_max)
	half_area_right = half_area_of_aabb(right_min, right_max)

	# Число треугольников
	n_left = len(left_vertices) // 3
	n_right = len(right_vertices) // 3

	# SAH-стоимость
	cost = half_area_left * n_left + half_area_right * n_right

	return cost, array(left_indices), array(right_indices)

def choose_sah_split(vertices: ndarray, num_tests_per_axis: int = 8) -> Tuple[int, float]:
	"""
	Ищем лучшую ось и позицию split по SAH (равномерно перебирая несколько позиций).
	Возвращаем (axis, split_value).
	"""
	# Глобальный AABB, чтобы понять границы
	min_vol, max_vol = compute_aabb(vertices)

	best_cost = float('inf')
	best_axis = 0
	best_split = 0.0

	for axis in [0, 1, 2]:
		# Берём границы по текущей оси
		bound_start = min_vol[axis]
		bound_end = max_vol[axis]

		# Чтобы не split-ить ровно на границе, перебираем несколько 
		# промежуточных значений (1..num_tests_per_axis)
		for i in range(1, num_tests_per_axis + 1):
			fraction = i / (num_tests_per_axis + 1)
			split_value = bound_start * (1.0 - fraction) + bound_end * fraction

			cost, _, _ = evaluate_split(vertices, axis, split_value)

			if cost < best_cost:
				best_cost = cost
				best_axis = axis
				best_split = split_value

	return best_axis, best_split


def SeparationTriangles(
	__VERTICES: ndarray[Tuple[int, int], dtype[float32]],
	__NORMALS: ndarray[Tuple[int, int], dtype[float32]],
	__UV_COORDS: ndarray[Tuple[int, int], dtype[float32]]
) -> Tuple[
	ndarray[Tuple[int, int], dtype[float32]],
	ndarray[Tuple[int, int], dtype[float32]],
	ndarray[Tuple[int, int], dtype[float32]],

	ndarray[Tuple[int, int], dtype[float32]],
	ndarray[Tuple[int, int], dtype[float32]],
	ndarray[Tuple[int, int], dtype[float32]],

	ndarray[Tuple[int], dtype[float32]], ndarray[Tuple[int], dtype[float32]],
	ndarray[Tuple[int], dtype[float32]], ndarray[Tuple[int], dtype[float32]]
]:
	num_tests_per_axis = 8
	"""
	Пример функции разделения треугольников по SAH.
	Возвращает левую и правую группы (вершины, нормали, UV) и их AABB.
	"""
	# 1) Ищем лучшую ось и split
	axis, split_value = choose_sah_split(__VERTICES, num_tests_per_axis)

	# 2) Разделяем треугольники
	left_indices = []
	right_indices = []

	for i in range(0, len(__VERTICES), 3):
		tri = __VERTICES[i : i + 3]
		center = mean(tri[:, axis])
		if center < split_value:
			left_indices.append(i)
		else:
			right_indices.append(i)

	def safe_vstack(indices, data):
		return vstack([data[i:i+3] for i in indices]) if indices else empty((0, 3, data.shape[1]), dtype=float32)

	LEFT_VERTICES = safe_vstack(left_indices, __VERTICES)
	RIGHT_VERTICES = safe_vstack(right_indices, __VERTICES)

	LEFT_NORMALS = safe_vstack(left_indices, __NORMALS)
	RIGHT_NORMALS = safe_vstack(right_indices, __NORMALS)

	LEFT_UV = safe_vstack(left_indices, __UV_COORDS)
	RIGHT_UV = safe_vstack(right_indices, __UV_COORDS)

	# AABB левой/правой части
	left_min, left_max = compute_aabb(LEFT_VERTICES)
	right_min, right_max = compute_aabb(RIGHT_VERTICES)

	return (
		LEFT_VERTICES, LEFT_NORMALS, LEFT_UV,
		RIGHT_VERTICES, RIGHT_NORMALS, RIGHT_UV,
		left_min, left_max, right_min, right_max
	)



import threading

def ReadObjData(path_to_file: str, separate: bool) -> Tuple[List[MeshData], str]:

	error_log: str = ""
	meshes: List[MeshData] = []

	file_name: str = os.path.splitext(os.path.basename(path_to_file))[0] + ".MDL"
	path_to_cache_file = os.path.join(CACHE_DIR, file_name)

	if(os.path.exists(path_to_cache_file)):

		file1_mtime = os.path.getmtime(path_to_file)
		file2_mtime = os.path.getmtime(path_to_cache_file)

		if(file1_mtime < file2_mtime):
			load = LoadData(path_to_cache_file, list)
			if(load): meshes.extend(load)
			del load
		del file1_mtime, file2_mtime

	if(meshes): return meshes, error_log

	#try:

	threads: List[threading.Thread] = []
	V: List[Tuple[float,float,float]] = []
	VT: List[Tuple[float,float]] = []
	VN: List[Tuple[float,float,float]] = []

	file: str = ""
	with open(path_to_file, 'r') as f: file += f.read()
	lines = file.splitlines()

	current_mesh = MeshData()
	v_size: int = 0
	vt_size: int = 0
	vn_size: int = 0
	for line in lines:
		elements = line.split()
		if not elements: continue
		if elements[0] == 'v':
			V.append((float(elements[1]), float(elements[2]), float(elements[3])))
			v_size+=1
		elif elements[0] == 'vt':
			VT.append((float(elements[1]), float(elements[2])))
			vt_size+=1
		elif elements[0] == 'vn':
			VN.append((float(elements[1]), float(elements[2]), float(elements[3])))
			vn_size+=1
		elif elements[0] == 'f':
	# for line in lines:
	# 	elements = line.split()
	# 	if elements[0] == 'f':
			face_vertices: List[Vertex] = []
			for elem in elements[1:]:
				vertex_indices = elem.split('/')
				vi = int(vertex_indices[0]) - 1			# Vertex index
				vti = -1
				vni = -1
				if(len(vertex_indices)>1):
					if(vertex_indices[1] != ''): vti = int(vertex_indices[1]) - 1		# Texture coordinate index
					if(vertex_indices[2] != ''): vni = int(vertex_indices[2]) - 1		# Normal index
				face_vertices.append(Vertex(
					point=(V[vi] if(v_size>vi) else (0.0,0.0,0.0)),
					uv=(VT[vti] if(vti>0 and vt_size>vti) else (0.0,0.0)),
					normal=(VN[vni] if(vni>0 and vn_size>vni) else (0.0,0.0,0.0))
				))
				del vertex_indices, vi, vti, vni
			current_mesh.AppendEdge(face_vertices)
			del face_vertices
		elif separate and elements[0] == 'o':
			thread = threading.Thread(target=current_mesh.DecodeData)
			threads.append(thread)
			thread.start()
			meshes.append(current_mesh)
			current_mesh = MeshData()
		del elements
	thread = threading.Thread(target=current_mesh.DecodeData)
	threads.append(thread)
	thread.start()
	meshes.append(current_mesh)
	del current_mesh, v_size, vt_size, vn_size

	for thread in threads:
		thread.join()

	V.clear()
	VT.clear()
	VN.clear()
	del V, VT, VN
	SaveData(meshes, path_to_cache_file)

	#except Exception as err:
	#	error_log = f"{err}"

	return meshes, error_log