from .LoadCache import LoadData, SaveData, CACHE_DIR

import os
from dataclasses import dataclass
from numpy import float32, int32, ndarray, dtype, array, min as npmin, max as npmax
from typing import List, Tuple



@dataclass
class Vertex:
	point: Tuple[float,float,float]
	normal: Tuple[float,float,float]
	uv: Tuple[float,float]



class MeshData:
	__VERTICES: ndarray[tuple[int, ...],dtype[float32]]
	__NORMALS: ndarray[tuple[int, ...],dtype[float32]]
	__UV_COORDS: ndarray[tuple[int, ...],dtype[float32]]
	__FACES: ndarray[tuple[int, ...],dtype[int32]]

	__COUNT_FACES: int
	__MIN_VOLUME: Tuple[float,float,float]
	__MAX_VOLUME: Tuple[float,float,float]

	__V: List[Tuple[float,float,float]]
	__VN: List[Tuple[float,float,float]]
	__VT: List[Tuple[float,float]]
	__F: List[int]

	def __init__(self) -> None:
		self.__V = []
		self.__VN = []
		self.__VT = []
		self.__F = []

	def GetVertices(self) -> ndarray[tuple[int, ...],dtype[float32]]: return self.__VERTICES
	def GetNormals(self) -> ndarray[tuple[int, ...],dtype[float32]]: return self.__NORMALS
	def GetUvCoords(self) -> ndarray[tuple[int, ...],dtype[float32]]: return self.__UV_COORDS
	def GetFaces(self) -> ndarray[tuple[int, ...],dtype[int32]]: return self.__FACES

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

	try:

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
				face_vertices: List[Vertex] = []
				for elem in elements[1:]:
					vertex_indices = elem.split('/')
					vi = int(vertex_indices[0]) - 1			# Vertex index
					vti = int(vertex_indices[1]) - 1		# Texture coordinate index
					vni = int(vertex_indices[2]) - 1		# Normal index
					face_vertices.append(Vertex(
						point=(V[vi] if(v_size>vi) else (0.0,0.0,0.0)),
						uv=(VT[vti] if(vt_size>vti) else (0.0,0.0)),
						normal=(VN[vni] if(vn_size>vni) else (0.0,0.0,0.0))
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

	except Exception as err:
		error_log = f"{err}"

	return meshes, error_log