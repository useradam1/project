from OpenGL.GL import *
from numpy import uint32, ndarray

# def UpdateSSBOBuffer(ssbo: uint32, data: ndarray) -> None:
#     glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo)
#     glBufferSubData(GL_SHADER_STORAGE_BUFFER, 0, data.nbytes, data)
#     glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0)


def UpdateSSBOBuffer(ssbo: uint32, data: ndarray) -> None:
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo)
	ptr = glMapBufferRange(GL_SHADER_STORAGE_BUFFER, 0, data.nbytes, GL_MAP_WRITE_BIT | GL_MAP_INVALIDATE_BUFFER_BIT)
	if ptr:
		ctypes.memmove(ptr, data.ctypes.data, data.nbytes)
		glUnmapBuffer(GL_SHADER_STORAGE_BUFFER)
	glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0)
