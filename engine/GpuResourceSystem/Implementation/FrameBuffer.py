from ...ApiGraphics import CreateFrameBuffer, UpdateSizeFrameBuffer, BindFrameBuffer, DestroyFrameBuffer
from ...ApiGraphics import SetTextures2DFrameBuffer, ClearTextures2DFromFrameBuffer
from ..GpuResourceSystem import GpuResourceManagerSystem, IGpuResource
from ...WindowSystem import WindowContextSystem
from .Texture2D import Texture2D

from ...Log import LogColors, PrintLog
from numpy import uint32
from typing import List, Tuple

nulluint32 = uint32(0)


class FrameBuffer:

	__ID: int
	__STATUS_EXIST: bool

	__FBO: uint32
	__RBO: uint32
	__REGISTERED_TEXTURES2D: Tuple[Texture2D, ...]

	__WINDOW_ID: int
	__IGPU_RESOURCE: IGpuResource


	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False

		self.__FBO, self.__RBO = nulluint32, nulluint32
		self.__REGISTERED_TEXTURES2D = ()

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		self.__IGPU_RESOURCE = IGpuResource(self.Destroy)

		if(not GpuResourceManagerSystem.AppendGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)):
			del self.__IGPU_RESOURCE
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return

		self.__FBO, self.__RBO = CreateFrameBuffer()

		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			GpuResourceManagerSystem.RemoveGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)
			del self.__IGPU_RESOURCE
			ClearTextures2DFromFrameBuffer(self.__FBO, len(self.__REGISTERED_TEXTURES2D))
			DestroyFrameBuffer(self.__FBO, self.__RBO)
			self.__REGISTERED_TEXTURES2D = ()
			self.__FBO, self.__RBO = nulluint32, nulluint32
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST


	def GetTextures(self) -> Tuple[Texture2D, ...]:
		return self.__REGISTERED_TEXTURES2D

	def SetTextures(self, textures: List[Texture2D]) -> 'FrameBuffer':
		self.__REGISTERED_TEXTURES2D = tuple(texture for texture in textures)
		SetTextures2DFrameBuffer(self.__FBO, (texture.GetObject() for texture in textures))
		return self

	def ResetTextures(self) -> 'FrameBuffer':
		ClearTextures2DFromFrameBuffer(self.__FBO, len(self.__REGISTERED_TEXTURES2D))
		return self


	def Bind(self) -> 'FrameBuffer':
		BindFrameBuffer(self.__FBO)
		return self

	def Unbind(self) -> 'FrameBuffer':
		BindFrameBuffer(nulluint32)
		return self


	def UpdateSize(self, width: int, height: int) -> 'FrameBuffer':
		for texture in self.__REGISTERED_TEXTURES2D:
			texture.SetEmptyData(width, height).LoadToGpu()
		UpdateSizeFrameBuffer(self.__RBO, width, height)
		return self