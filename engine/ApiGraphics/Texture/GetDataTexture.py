from OpenGL.GL import *
from numpy import ndarray, uint8, zeros, uint32, dtype, float32
from typing import Tuple



def GetDataTexture2D(texture_id: uint32) -> ndarray[Tuple[int,int], dtype[uint8]]:
	glBindTexture(GL_TEXTURE_2D, texture_id)  # Привязываем текстуру

	width = glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH)
	height = glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT)
	
	data = zeros((height, width, 4), dtype=uint8)  # Буфер для данных (RGBA)
	
	glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_UNSIGNED_BYTE, data)
	
	glBindTexture(GL_TEXTURE_2D, 0)  # Отвязываем текстуру
	return data


def GetDataTexture2DFloat(texture_id: uint32) -> ndarray[Tuple[int,int], dtype[float32]]:
	glBindTexture(GL_TEXTURE_2D, texture_id)  # Привязываем текстуру

	width = glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_WIDTH)
	height = glGetTexLevelParameteriv(GL_TEXTURE_2D, 0, GL_TEXTURE_HEIGHT)
	
	data = zeros((height, width, 4), dtype=float32)  # Буфер для данных (RGBA)
	
	glGetTexImage(GL_TEXTURE_2D, 0, GL_RGBA, GL_FLOAT, data)
	
	glBindTexture(GL_TEXTURE_2D, 0)  # Отвязываем текстуру
	return data