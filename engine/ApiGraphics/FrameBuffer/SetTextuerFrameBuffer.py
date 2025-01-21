from OpenGL.GL import *
from numpy import uint32
from typing import Tuple, List, Union, Generator






def SetTextures2DFrameBuffer(fbo: uint32, texture_ids: Union[Tuple[uint32, ...], Generator[uint32,None,None]]) -> None:
	glBindFramebuffer(GL_FRAMEBUFFER, fbo)

	draw_buffers: List[int] = []
	for i, id in enumerate(texture_ids):
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0+i, GL_TEXTURE_2D, id, 0)
		draw_buffers.append(GL_COLOR_ATTACHMENT0+i)

	glDrawBuffers(len(draw_buffers), draw_buffers)

	glBindFramebuffer(GL_FRAMEBUFFER, 0)


def UpdateFrameBuffer(rbo: uint32, width: int, height: int) -> None:
	glBindRenderbuffer(GL_RENDERBUFFER, rbo)
	#glViewport(0,0,width,height)
	glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH24_STENCIL8, width, height)
	glBindRenderbuffer(GL_RENDERBUFFER, 0)





