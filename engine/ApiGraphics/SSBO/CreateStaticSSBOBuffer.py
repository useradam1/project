from OpenGL.GL import *
from numpy import uint32, ndarray

def CreateStaticSSBOBuffer(ssbo_index: int, data: ndarray) -> uint32:
	ssbo = glGenBuffers(1)
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo)
	glBufferData(GL_SHADER_STORAGE_BUFFER, data.nbytes, data, GL_STATIC_DRAW)
	glBindBufferBase(GL_SHADER_STORAGE_BUFFER, ssbo_index, ssbo)
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0)
	return ssbo