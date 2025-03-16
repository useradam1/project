from OpenGL.GL import *
from numpy import uint32, ndarray

def UpdateSSBOBuffer(ssbo: uint32, data: ndarray) -> None:
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo)
    glBufferSubData(GL_SHADER_STORAGE_BUFFER, 0, data.nbytes, data)
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0)
