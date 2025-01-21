from OpenGL.GL import *
from numpy import uint32
from typing import Tuple

def CreateFrameBuffer() -> Tuple[uint32,uint32]:
	fbo: uint32 = glGenFramebuffers(1)
	glBindFramebuffer(GL_FRAMEBUFFER, fbo)
	rbo: uint32 = glGenRenderbuffers(1)
	glBindRenderbuffer(GL_RENDERBUFFER, rbo)
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, 1, 1)
	glBindRenderbuffer(GL_RENDERBUFFER, 0)
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_STENCIL_ATTACHMENT, GL_RENDERBUFFER, rbo)
	glBindFramebuffer(GL_FRAMEBUFFER, 0)
	return fbo, rbo

def BindFrameBuffer(fbo: uint32) -> None:
	glBindFramebuffer(GL_FRAMEBUFFER, fbo)