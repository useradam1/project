from OpenGL.GL import *
from numpy import ndarray, dtype, float32, int32, uint32, array
from typing import Tuple, Generator, TypedDict

from dataclasses import dataclass
@dataclass
class GpuMeshInstanced:
	vao: uint32
	vbo_vertices: uint32
	vbo_uvs: uint32
	vbo_normals: uint32
	vbo_instance_transform_i: uint32
	vbo_instance_transform_j: uint32
	vbo_instance_transform_k: uint32
	vbo_instance_transform_l: uint32
	ebo_faces: uint32
	len_faces: int


def DestroyMesh(mesh: GpuMeshInstanced) -> None:

	# Delete VAO
	glDeleteVertexArrays(1, [mesh.vao])

	# Delete VBOs and EBO
	# Replace with the actual IDs of VBOs and EBO if not reused
	glDeleteBuffers(1, [mesh.vbo_vertices, mesh.vbo_uvs, mesh.vbo_normals, mesh.vbo_instance_transform_i, mesh.vbo_instance_transform_j, mesh.vbo_instance_transform_k, mesh.vbo_instance_transform_l, mesh.ebo_faces])

def CreateMesh(
		Vertices:ndarray[Tuple[int, ...],dtype[float32]],
		Uvs:ndarray[Tuple[int, ...],dtype[float32]],
		Normals:ndarray[Tuple[int, ...],dtype[float32]],
		Faces:ndarray[Tuple[int, ...],dtype[int32]]
		) -> GpuMeshInstanced:

	# Generate a new vertex array object (VAO)
	vao: uint32 = glGenVertexArrays(1)
	glBindVertexArray(vao)

	# Create vertex buffer object (VBO) for vertices
	glEnableVertexAttribArray(0)
	vbo_vertices: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ARRAY_BUFFER, vbo_vertices)
	glBufferData(GL_ARRAY_BUFFER, Vertices.nbytes, Vertices, GL_STATIC_DRAW)
	glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, None)

	# Create VBO for texture coordinates (UVs)
	glEnableVertexAttribArray(1)
	vbo_uvs: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ARRAY_BUFFER, vbo_uvs)
	glBufferData(GL_ARRAY_BUFFER, Uvs.nbytes, Uvs, GL_STATIC_DRAW)
	glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 0, None)

	# Create VBO for normals
	glEnableVertexAttribArray(2)
	vbo_normals: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ARRAY_BUFFER, vbo_normals)
	glBufferData(GL_ARRAY_BUFFER, Normals.nbytes, Normals, GL_STATIC_DRAW)
	glVertexAttribPointer(2, 3, GL_FLOAT, GL_FALSE, 0, None)

	# Create VBO for instance transform i
	glEnableVertexAttribArray(4)
	vbo_instance_transform_i: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_i)
	glBufferData(GL_ARRAY_BUFFER, 16, None, GL_DYNAMIC_DRAW)
	glVertexAttribPointer(4, 4, GL_FLOAT, GL_FALSE, 0, None)
	glVertexAttribDivisor(4, 1)

	# Create VBO for instance transform j
	glEnableVertexAttribArray(5)
	vbo_instance_transform_j: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_j)
	glBufferData(GL_ARRAY_BUFFER, 16, None, GL_DYNAMIC_DRAW)
	glVertexAttribPointer(5, 4, GL_FLOAT, GL_FALSE, 0, None)
	glVertexAttribDivisor(5, 1)

	# Create VBO for instance transform k
	glEnableVertexAttribArray(6)
	vbo_instance_transform_k: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_k)
	glBufferData(GL_ARRAY_BUFFER, 16, None, GL_DYNAMIC_DRAW)
	glVertexAttribPointer(6, 4, GL_FLOAT, GL_FALSE, 0, None)
	glVertexAttribDivisor(6, 1)

	# Create VBO for instance transform l
	glEnableVertexAttribArray(7)
	vbo_instance_transform_l: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_l)
	glBufferData(GL_ARRAY_BUFFER, 16, None, GL_DYNAMIC_DRAW)
	glVertexAttribPointer(7, 4, GL_FLOAT, GL_FALSE, 0, None)
	glVertexAttribDivisor(7, 1)

	# Create element buffer object (EBO) for faces
	ebo_faces: uint32 = glGenBuffers(1)
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo_faces)
	glBufferData(GL_ELEMENT_ARRAY_BUFFER, Faces.nbytes, Faces, GL_STATIC_DRAW)

	# Cleanup
	glBindVertexArray(0)
	glBindBuffer(GL_ARRAY_BUFFER, 0)
	glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0)

	return GpuMeshInstanced(
		vao = vao ,
		vbo_vertices = vbo_vertices ,
		vbo_uvs = vbo_uvs ,
		vbo_normals = vbo_normals ,
		vbo_instance_transform_i = vbo_instance_transform_i ,
		vbo_instance_transform_j = vbo_instance_transform_j ,
		vbo_instance_transform_k = vbo_instance_transform_k ,
		vbo_instance_transform_l = vbo_instance_transform_l ,
		ebo_faces = ebo_faces,
		len_faces = len(Faces)
	)

	return vao, vbo_vertices, vbo_uvs, vbo_normals, vbo_instance_transform_i, vbo_instance_transform_j, vbo_instance_transform_k, vbo_instance_transform_l, ebo_faces


def SetInstanceTransformDataMesh(
		mesh: GpuMeshInstanced, 
		lenght: int,
		data: Generator[Tuple[float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float], None, None]) -> None:
	v = lenght*16

	# Преобразуем данные в numpy массив
	mat = array(list(data), dtype=float32)

	# Обновляем каждый буфер отдельно
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_i)
	glBufferData(GL_ARRAY_BUFFER, v, mat[:, 0:4], GL_DYNAMIC_DRAW)

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_j)
	glBufferData(GL_ARRAY_BUFFER, v, mat[:, 4:8], GL_DYNAMIC_DRAW)

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_k)
	glBufferData(GL_ARRAY_BUFFER, v, mat[:, 8:12], GL_DYNAMIC_DRAW)

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_l)
	glBufferData(GL_ARRAY_BUFFER, v, mat[:, 12:16], GL_DYNAMIC_DRAW)

	del v, mat
	glBindBuffer(GL_ARRAY_BUFFER, 0)

def SetInstanceTransformDataLenghtMesh(
		mesh: GpuMeshInstanced, 
		lenght: int) -> None:
	v = lenght*16

	# Обновляем каждый буфер отдельно
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_i)
	glBufferData(GL_ARRAY_BUFFER, v, None, GL_DYNAMIC_DRAW)

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_j)
	glBufferData(GL_ARRAY_BUFFER, v, None, GL_DYNAMIC_DRAW)

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_k)
	glBufferData(GL_ARRAY_BUFFER, v, None, GL_DYNAMIC_DRAW)

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_l)
	glBufferData(GL_ARRAY_BUFFER, v, None, GL_DYNAMIC_DRAW)

	del v
	glBindBuffer(GL_ARRAY_BUFFER, 0)

def UpdateInstanceTransformDataMesh(
		mesh: GpuMeshInstanced, 
		lenght: int,
		data: Generator[Tuple[float,float,float,float,float,float,float,float,float,float,float,float,float,float,float,float], None, None]) -> None:
	v = lenght*16

	'''
	ar = ((ctypes.c_float*(4*lenght))*4)()
	for i, value in enumerate(data):
		index = i * 4
		for j in range(4):
			ar[j][index:index+4] = value[j*4:(j+1)*4]


	# Обновляем каждый буфер отдельно
	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_i)
	glBufferSubData(GL_ARRAY_BUFFER, 0, ctypes.sizeof(ar[0]), ar[0])

	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_j)
	glBufferSubData(GL_ARRAY_BUFFER, 0, ctypes.sizeof(ar[1]), ar[1])

	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_k)
	glBufferSubData(GL_ARRAY_BUFFER, 0, ctypes.sizeof(ar[2]), ar[2])

	glBindBuffer(GL_ARRAY_BUFFER, vbo_instance_transform_l)
	glBufferSubData(GL_ARRAY_BUFFER, 0, ctypes.sizeof(ar[3]), ar[3])

	del ar
	glBindBuffer(GL_ARRAY_BUFFER, 0)
	#'''

	#ar = ((ctypes.c_float*(4*lenght))*4)()

	# Преобразуем данные в numpy массив
	#'''
	mat = array(tuple(data), dtype=float32)
	#print(mat)

	# Обновляем каждый буфер отдельно
	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_i)
	glBufferSubData(GL_ARRAY_BUFFER, 0, v, mat[:, 0:4])

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_j)
	glBufferSubData(GL_ARRAY_BUFFER, 0, v, mat[:, 4:8])

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_k)
	glBufferSubData(GL_ARRAY_BUFFER, 0, v, mat[:, 8:12])

	glBindBuffer(GL_ARRAY_BUFFER, mesh.vbo_instance_transform_l)
	glBufferSubData(GL_ARRAY_BUFFER, 0, v, mat[:, 12:16])

	del v, mat
	glBindBuffer(GL_ARRAY_BUFFER, 0)
	#'''