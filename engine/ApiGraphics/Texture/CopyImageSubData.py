from OpenGL.GL import *
from numpy import uint32

def CopyImageSubDataTexture2DAny(srcTexture: uint32, dstTexture: uint32, width: int, height: int) -> None:
	# Вызов функции копирования
	glCopyImageSubData(
		srcTexture, GL_TEXTURE_2D, 0, 0, 0, 0,
		dstTexture, GL_TEXTURE_2D, 0, 0, 0, 0,
		height, width , 1
	)