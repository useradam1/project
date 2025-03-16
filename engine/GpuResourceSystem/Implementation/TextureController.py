from typing import Dict, Set


class ITexture:
	link_number: int
	def __init__(self, link_number: int) -> None:
		self.link_number = link_number



class BindTextureController:

	__BINDED_TEXTURE: Dict[int, Set[int]] = {}
	
	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__BINDED_TEXTURE[window_id] = set()

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__BINDED_TEXTURE[window_id].clear()

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__BINDED_TEXTURE.pop(window_id, None)
	

	@classmethod
	def AppendTexture(cls, texture: ITexture, window_id: int) -> bool:
		binds = cls.__BINDED_TEXTURE[window_id]
		if(texture.link_number in binds): return False
		binds.add(texture.link_number)
		return True
	
	@classmethod
	def RemoveTexture(cls, texture: ITexture, window_id: int) -> None:
		cls.__BINDED_TEXTURE[window_id].remove(texture.link_number)