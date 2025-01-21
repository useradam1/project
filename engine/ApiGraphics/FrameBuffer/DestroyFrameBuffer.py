from OpenGL.GL import *
from numpy import uint32

def DestroyFrameBuffer(fbo: uint32, rbo: uint32) -> None:
	glDeleteFramebuffers(1, [fbo])
	glDeleteRenderbuffers(1, [rbo])