from OpenGL.GL import *
from numpy import uint32, ndarray

def CreateMaterialBuffer(ssbo_index: int, materials_data: ndarray) -> uint32:
	ssbo = glGenBuffers(1)
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo)
	glBufferData(GL_SHADER_STORAGE_BUFFER, materials_data.nbytes, materials_data, GL_DYNAMIC_DRAW)
	glBindBufferBase(GL_SHADER_STORAGE_BUFFER, ssbo_index, ssbo)
	return ssbo