from ..GpuResourceSystem import GpuResourceManagerSystem, IGpuResource
from ...WindowSystem import WindowContextSystem
from ...ApiGraphics import CreateShader, DestroyShader, UseShader, ShaderData, allowed_types_shader
from .ShaderInterface import ShaderInterface
from .ShaderContext import ShaderContext
from typing import Dict, Literal, Tuple
from numpy import uint32

nulluint32 = uint32(0)


from ...Log import LogColors, PrintLog




class Shader(ShaderInterface):

	__ID: int
	__STATUS_EXIST: bool
	__OBJECT: uint32
	__LOAD_STATUS_GPU: bool
	__SHADER_DATA: ShaderData
	__MATERIAL: Tuple[int, Dict[str, allowed_types_shader]]


	__WINDOW_ID: int
	__IGPU_RESOURCE: IGpuResource


	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__OBJECT = nulluint32
		self.__LOAD_STATUS_GPU = False
		self.__SHADER_DATA = ShaderData()
		self.__MATERIAL = (-1, {})

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		self.__IGPU_RESOURCE = IGpuResource(self.Destroy)

		if(not GpuResourceManagerSystem.AppendGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)):
			del self.__IGPU_RESOURCE
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return


		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			self.UnloadGpu()
			GpuResourceManagerSystem.RemoveGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)
			del self.__IGPU_RESOURCE
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)



	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	def GetObject(self) -> uint32:
		return self.__OBJECT

	def GetLoadStatusGpu(self) -> bool:
		return self.__LOAD_STATUS_GPU

	def GetShaderData(self) -> ShaderData:
		return self.__SHADER_DATA



	def LoadToGpu(self, value: Dict[str, Literal['VERTEX_SHADER','GEOMETRY_SHADER','FRAGMENT_SHADER']]) -> 'Shader':
		self.UnloadGpu()
		self.__OBJECT, self.__MATERIAL, error_log = CreateShader(value)
		if(error_log): PrintLog(f"[ERROR_{self.__class__.__name__}] {error_log}", LogColors.RED)
		else:
			self.__SHADER_DATA.UploadShader(self.__OBJECT)
			self.__LOAD_STATUS_GPU = True
			PrintLog(f"{self.__class__.__name__} Load to the GPU memory is completed", LogColors.GREEN)
		return self

	def UnloadGpu(self) -> 'Shader':
		if(self.__LOAD_STATUS_GPU):
			self.StopUseProgram()
			DestroyShader(self.__OBJECT)
			self.__OBJECT = nulluint32
			self.__MATERIAL = (-1, {})
			self.__SHADER_DATA.ClearShader()
			self.__LOAD_STATUS_GPU = False
			PrintLog(f"{self.__class__.__name__} Unload from the GPU memory is completed", LogColors.GREEN)
		return self



	def StartUseProgram(self) -> 'Shader':
		if(self.__LOAD_STATUS_GPU):
			if(ShaderContext.GetShaderId(self.__WINDOW_ID) != self.__ID):
				UseShader(self.__OBJECT)
				ShaderContext.SetShader(self.__WINDOW_ID, self)
		return self

	def StopUseProgram(self) -> 'Shader':
		UseShader(nulluint32)
		ShaderContext.SetShader(self.__WINDOW_ID, None)
		return self
	
	
	def GetMaterialDescriptor(self) -> Tuple[int, Dict[str, allowed_types_shader]]:
		return self.__MATERIAL