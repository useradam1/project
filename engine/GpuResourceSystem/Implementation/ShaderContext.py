from .ShaderInterface import ShaderInterface
from typing import Dict, Optional


class ShaderContext:

	__CURRENT_SHADER: Dict[int, Optional[ShaderInterface]] = {}
	__CURRENT_SHADER_ID: Dict[int, int] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__CURRENT_SHADER[window_id] = None
		cls.__CURRENT_SHADER_ID[window_id] = 0

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__CURRENT_SHADER.pop(window_id, None)
		cls.__CURRENT_SHADER_ID.pop(window_id, None)


	@classmethod
	def SetShader(cls, window_id: int, shader: Optional[ShaderInterface]) -> None:
		cls.__CURRENT_SHADER[window_id] = shader
		if(shader is not None): cls.__CURRENT_SHADER_ID[window_id] = shader.GetId()


	@classmethod
	def GetShader(cls, window_id: int) -> Optional[ShaderInterface]:
		return cls.__CURRENT_SHADER[window_id]

	@classmethod
	def GetShaderId(cls, window_id: int) -> int:
		return cls.__CURRENT_SHADER_ID[window_id]