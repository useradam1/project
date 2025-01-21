from OpenGL.GL import *
from numpy import ndarray, dtype, uint8, uint32, array, float32
from typing import Tuple



def UpdateTexture2D(texture_id: uint32, data: ndarray[tuple, dtype[uint8]]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_2D, texture_id)

	# Обновляем данные текстуры
	glTexImage2D(
		GL_TEXTURE_2D, 0, GL_RGBA, data.shape[1], data.shape[0],
					   0, GL_RGBA, GL_UNSIGNED_BYTE, data)

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_2D, 0)


def ClearTexture2D(texture_id: uint32, clear_color: Tuple[float,float,float,float]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_2D, texture_id)

	# Обновляем данные текстуры
	glClearTexImage(texture_id, 0, GL_RGBA, GL_UNSIGNED_BYTE, array(clear_color, dtype=float32))

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_2D, 0)


def UpdateTexture2DFloat(texture_id: uint32, data: ndarray[tuple, dtype[uint8]]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_2D, texture_id)

	# Обновляем данные текстуры
	glTexImage2D(
		GL_TEXTURE_2D, 0, GL_RGBA32F, data.shape[1], data.shape[0],
					   0, GL_RGBA, GL_FLOAT, data)

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_2D, 0)


def ClearTexture2DFloat(texture_id: uint32, clear_color: Tuple[float,float,float,float]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_2D, texture_id)

	# Обновляем данные текстуры
	glClearTexImage(texture_id, 0, GL_RGBA, GL_FLOAT, array(clear_color, dtype=float32))

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_2D, 0)


def UpdateTexture3D(texture_id: uint32, data: ndarray[tuple, dtype[uint8]]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_3D, texture_id)

	# Обновляем данные текстуры
	glTexImage3D(
		GL_TEXTURE_3D, 0, GL_RGBA, data.shape[2], data.shape[1], data.shape[0],
		0, GL_RGBA, GL_UNSIGNED_BYTE, data)

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_3D, 0)


def ClearTexture3D(texture_id: uint32, clear_color: Tuple[float,float,float,float]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_3D, texture_id)

	# Обновляем данные текстуры
	glClearTexImage(texture_id, 0, GL_RGBA, GL_UNSIGNED_BYTE, array(clear_color, dtype=float32))

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_3D, 0)


def UpdateTexture3DFloat(texture_id: uint32, data: ndarray[tuple, dtype[uint8]]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_3D, texture_id)

	# Обновляем данные текстуры
	glTexImage3D(
		GL_TEXTURE_3D, 0, GL_RGBA32F, data.shape[2], data.shape[1], data.shape[0],
		0, GL_RGBA, GL_FLOAT, data)

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_3D, 0)


def ClearTexture3DFloat(texture_id: uint32, clear_color: Tuple[float,float,float,float]):
	# Привязываем текстуру
	glBindTexture(GL_TEXTURE_3D, texture_id)

	# Обновляем данные текстуры
	glClearTexImage(texture_id, 0, GL_RGBA, GL_FLOAT, array(clear_color, dtype=float32))

	# Отвязка текстуры
	glBindTexture(GL_TEXTURE_3D, 0)
