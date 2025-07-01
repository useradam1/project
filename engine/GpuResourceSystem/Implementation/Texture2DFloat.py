from ..GpuResourceSystem import GpuResourceManagerSystem, IGpuResource
from ...WindowSystem import WindowContextSystem
from ...UpdateSystem import Update
from ...FlowControlSystem import FlowControlSystem
from ...ApiGraphics import CreateTexture2D, ClearTexture2DFloat, FillTexture2DFloatWithColor, UpdateTexture2DFloat, DestroyTexture, BindTexture2D_rgba32f, GetDataTexture2DFloat
from ...ApiGraphics import CreateBindlessHandle, MakeTextureNonResident, MakeTextureResident
from ...Loader import ReadImage2D, ImageData2DFloat
from .TextureController import BindTextureController, ITexture


from ...Log import LogColors, PrintLog
from ...CustomMetaclass import TaskQueue


from typing import TypedDict, List, Tuple
from numpy import uint32, ndarray, dtype, float32, zeros, uint64


from .Texture2D import Texture2D


nulluint32 = uint32(0)
nulluint64 = uint64(0)


class ThreadLoad(TypedDict):
	ready: bool
	path: str
	image_data: ImageData2DFloat
	error_log: str

def TextureDataLoad(thread_load_ram: ThreadLoad) -> None:
	thread_load_ram['error_log'] = ReadImage2D(thread_load_ram['path'], thread_load_ram['image_data'])
	thread_load_ram['ready'] = True

class Texture2DFloat:

	__ID: int
	__STATUS_EXIST: bool

	__TASK_QUEUE: TaskQueue
	__THREAD_LOAD_RAM: ThreadLoad

	__DATA: ndarray[Tuple[int,int], dtype[float32]]
	__HEIGHT: int
	__WIDTH: int

	__BIND_NUMBER: ITexture

	__WINDOW_ID: int
	__IGPU_RESOURCE: IGpuResource

	__OBJECT: uint32
	__OBJECT_HANDLE: uint64
	__UPDATE: Update


	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__OBJECT = nulluint32

		self.__TASK_QUEUE = TaskQueue()
		self.__THREAD_LOAD_RAM = ThreadLoad(
			ready= True,
			path= "",
			image_data= ImageData2DFloat(),
			error_log= ""
		)
		self.__DATA = self.__THREAD_LOAD_RAM['image_data'].GetData()
		self.__HEIGHT = self.__THREAD_LOAD_RAM['image_data'].GetHeight()
		self.__WIDTH = self.__THREAD_LOAD_RAM['image_data'].GetWidth()

		self.__BIND_NUMBER = ITexture(-1)

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		self.__IGPU_RESOURCE = IGpuResource(self.Destroy)

		if(not GpuResourceManagerSystem.AppendGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)):
			del self.__IGPU_RESOURCE
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return

		self.__OBJECT = CreateTexture2D()
		ClearTexture2DFloat(self.__OBJECT, (0,0,0,0))
		self.__OBJECT_HANDLE = nulluint64

		self.__UPDATE = Update(self.__CheckQueue)
		self.__UPDATE.enabled = False

		self.__STATUS_EXIST = True
		PrintLog(f"{self.__class__.__name__} Initialization", color= LogColors.GREEN)

	def __del__(self) -> None:
		PrintLog(f"{self.__class__.__name__} deleted", color= LogColors.BLUE)

	def Destroy(self) -> None:
		if(self.__STATUS_EXIST):
			self.__UPDATE.Destroy()
			self.UnloadRam()
			GpuResourceManagerSystem.RemoveGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)
			del self.__IGPU_RESOURCE
			self.CloseTextureForAll()
			DestroyTexture(self.__OBJECT)
			self.__OBJECT = nulluint32
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)


	def __OpenTextureForAll(self) -> None:
		if(self.__STATUS_EXIST):
			if(self.__OBJECT_HANDLE == nulluint64):
				self.__OBJECT_HANDLE = CreateBindlessHandle(self.__OBJECT)
				MakeTextureResident(self.__OBJECT_HANDLE)
			else: MakeTextureResident(self.__OBJECT_HANDLE)
	def OpenTextureForAll(self) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__OpenTextureForAll)
			self.__UPDATE.enabled = True
		else: self.__OpenTextureForAll()
		return self

	def __CloseTextureForAll(self) -> None:
		if(self.__STATUS_EXIST):
			if(self.__OBJECT_HANDLE != nulluint64):
				MakeTextureNonResident(self.__OBJECT_HANDLE)
	def CloseTextureForAll(self) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__CloseTextureForAll)
			self.__UPDATE.enabled = True
		else: self.__CloseTextureForAll()
		return self


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	def GetObject(self) -> uint32:
		return self.__OBJECT

	def GetWidth(self) -> int:
		return self.__WIDTH

	def GetHeight(self) -> int:
		return self.__HEIGHT

	def GetData(self) -> ndarray[Tuple[int,int], dtype[float32]]:
		return self.__DATA

	def GetImageData(self) -> ImageData2DFloat:
		return self.__THREAD_LOAD_RAM['image_data']

	def GetActualData(self) -> ndarray[Tuple[int,int], dtype[float32]]:
		self.__DATA = GetDataTexture2DFloat(self.__OBJECT)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		return self.__DATA

	def GetErrorLog(self) -> str:
		return self.__THREAD_LOAD_RAM['error_log']

	def GetStatusThreadActive(self) -> bool:
		return not self.__THREAD_LOAD_RAM['ready']



	def __setEmptyData(self, width: int, height: int) -> None:
		self.__THREAD_LOAD_RAM['image_data'].SetEmptyData(width, height)

	def SetEmptyData(self, width: int, height: int) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__setEmptyData, width, height)
			self.__UPDATE.enabled = True
		else: self.__setEmptyData(width, height)
		return self



	def __loadToRamFromPath(self, path: str) -> None:
		self.__THREAD_LOAD_RAM['ready'] = False
		self.__THREAD_LOAD_RAM['path'] = path
		FlowControlSystem.CreateFrameProcessTask(TextureDataLoad, self.__THREAD_LOAD_RAM) #type: ignore

	def LoadToRamFromPath(self, path: str) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToRamFromPath, path)
			self.__UPDATE.enabled = True
		else: self.__loadToRamFromPath(path)
		return self



	def __loadToRamFromImageData(self, data: ImageData2DFloat) -> None:
		self.__THREAD_LOAD_RAM['image_data'] = data
		self.__THREAD_LOAD_RAM['error_log'] = ""
		self.__THREAD_LOAD_RAM['ready'] = True

	def LoadToRamFromImageData(self, data: ImageData2DFloat) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToRamFromImageData, data)
			self.__UPDATE.enabled = True
		else: self.__loadToRamFromImageData(data)
		return self



	def __loadToRamFromData(self, data: List[List[Tuple[float,float,float,float]]]) -> None:
		self.__THREAD_LOAD_RAM['image_data'].SetData(data)
		self.__THREAD_LOAD_RAM['error_log'] = ""
		self.__THREAD_LOAD_RAM['ready'] = True

	def LoadToRamFromData(self, data: List[List[Tuple[float,float,float,float]]]) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToRamFromData, data)
			self.__UPDATE.enabled = True
		else: self.__loadToRamFromData(data)
		return self



	def __unloadRam(self) -> None:
		self.__THREAD_LOAD_RAM['image_data'].SetEmptyData(1,1)
		self.__THREAD_LOAD_RAM['error_log'] = ""
		self.__THREAD_LOAD_RAM['ready'] = True
		PrintLog(f"{self.__class__.__name__} Unload from the RAM memory is completed", LogColors.GREEN)

	def UnloadRam(self) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__unloadRam)
			self.__UPDATE.enabled = True
		else: self.__unloadRam()
		return self



	def __loadToGpu(self) -> None:
		if(self.__THREAD_LOAD_RAM['error_log']):
			PrintLog(f"[ERROR_{self.__class__.__name__}] {self.__THREAD_LOAD_RAM['error_log']}", LogColors.RED)
			return
		self.__DATA = self.__THREAD_LOAD_RAM['image_data'].GetData()
		self.__HEIGHT = self.__THREAD_LOAD_RAM['image_data'].GetHeight()
		self.__WIDTH = self.__THREAD_LOAD_RAM['image_data'].GetWidth()
		UpdateTexture2DFloat(self.__OBJECT, self.__DATA)
		PrintLog(f"{self.__class__.__name__} Load to the GPU memory is completed", LogColors.GREEN)

	def LoadToGpu(self) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToGpu)
			self.__UPDATE.enabled = True
		else: self.__loadToGpu()
		return self



	def __unloadGpu(self) -> None:
		ClearTexture2DFloat(self.__OBJECT, ( 0.0 , 0.0 , 0.0 , 0.0 ))
		self.__DATA = zeros((1, 1, 4), dtype=float32)
		self.__HEIGHT = 1
		self.__WIDTH = 1
		PrintLog(f"{self.__class__.__name__} Unload from the GPU memory is completed", LogColors.GREEN)

	def UnloadGpu(self) -> 'Texture2DFloat':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__unloadGpu)
			self.__UPDATE.enabled = True
		else: self.__unloadGpu()
		return self


	def FillWithColor(self, color: Tuple[float,float,float,float]) -> None:
		FillTexture2DFloatWithColor(self.__OBJECT, color)
	

	def Bind(self, link_number: int) -> None:
		if(self.__BIND_NUMBER.link_number != -1): return
		self.__BIND_NUMBER.link_number = link_number
		if(not BindTextureController.AppendTexture(self.__BIND_NUMBER, self.__WINDOW_ID)):
			self.__BIND_NUMBER.link_number = -1
			PrintLog(f"[ERROR_{self.__class__.__name__}] the link number is already in use: {link_number}")
			return
		BindTexture2D_rgba32f(link_number, self.__OBJECT)
	
	def UnBind(self) -> None:
		if(self.__BIND_NUMBER.link_number == -1): return
		BindTexture2D_rgba32f(self.__BIND_NUMBER.link_number, nulluint32)
		self.__BIND_NUMBER.link_number = -1


	def __CheckQueue(self) -> None:
		if(self.__THREAD_LOAD_RAM['ready']): self.__TASK_QUEUE.execute_next()
		if(self.__TASK_QUEUE.is_empty()):
			self.__UPDATE.enabled = False