from dataclasses import dataclass


# первой значение привязка ssbo второе количество (опционально)
@dataclass
class GraphicSettings:
	transforms = (1,100)
	camara = (2,5)
	textures2d = (3,1000)