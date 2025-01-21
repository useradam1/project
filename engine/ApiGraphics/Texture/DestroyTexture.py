from OpenGL.GL import *
from numpy import uint32



def DestroyTexture(
		target_id: uint32
	) -> None:

	# Удаление текстуры
	glDeleteTextures(1, [target_id])