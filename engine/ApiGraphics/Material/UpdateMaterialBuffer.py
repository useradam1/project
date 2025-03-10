from OpenGL.GL import *
from numpy import uint32, ndarray

def UpdateMaterialBuffer(ssbo: uint32, materials_data: ndarray) -> None:
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, ssbo)
    glBufferSubData(GL_SHADER_STORAGE_BUFFER, 0, materials_data.nbytes, materials_data)
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0)
