from OpenGL.GL import *
from numpy import uint32

def DestroyMaterialBuffer(ssbo: uint32) -> None:
	glDeleteBuffers(1, [ssbo])