from OpenGL.GL import *
from numpy import uint32

nulluint32 = uint32(0)

def UseShader(targetId: uint32) -> bool:
	glUseProgram(targetId)
	if(targetId == nulluint32):
		glColor3f(1.0, 0.0, 1.0)
		return False
	return True