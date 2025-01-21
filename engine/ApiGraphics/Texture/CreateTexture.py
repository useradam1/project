from OpenGL.GL import *
from numpy import ndarray, dtype, byte, uint32



def CreateTexture2D() -> uint32:

	# Генерация ID текстуры
	texture_id = glGenTextures(1)

	# Привязка текстуры
	glBindTexture(GL_TEXTURE_2D, texture_id)

	# Установка параметров текстуры
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_LOD, 0)  # Установить минимальный уровень детализации
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LOD, 0)  # Установить максимальный уровень детализации
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_LOD_BIAS, 0)  # Установить смещение уровня детализации

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_2D, 0)

	return texture_id

def CreateTexture3D() -> uint32:
	# Generate a texture ID
	texture_id = glGenTextures(1)

	# Bind the texture
	glBindTexture(GL_TEXTURE_3D, texture_id)

	# Set texture parameters
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_S, GL_REPEAT)
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_T, GL_REPEAT)
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_WRAP_R, GL_REPEAT)  # Additional parameter for 3D textures
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MIN_LOD, 0)  # Set the minimum level of detail
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_MAX_LOD, 0)  # Set the maximum level of detail
	glTexParameteri(GL_TEXTURE_3D, GL_TEXTURE_LOD_BIAS, 0)  # Set the level of detail bias

	# Unbind the texture
	glBindTexture(GL_TEXTURE_3D, 0)

	return texture_id