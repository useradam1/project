from ..GpuResourceSystem import GpuResourceManagerSystem, IGpuResource
from ...WindowSystem import WindowContextSystem
from ...ApiGraphics import CreateShader, DestroyShader, UseShader, ShaderData
from ...UpdateSystem import FixedUpdate
from ...FlowControlSystem import FlowControlSystem
from typing import Dict, Literal, TypedDict
from numpy import uint32
from time import sleep
nulluint32 = uint32(0)


from ...Log import LogColors, PrintLog
from ...CustomMetaclass import TaskQueue


class ThreadLoad(TypedDict):
	ready: bool
	path: Dict[str,Literal['VERTEX_SHADER','GEOMETRY_SHADER','FRAGMENT_SHADER']]
	result: uint32


class Shader:

	__ID: int
	__STATUS_EXIST: bool

	__TASK_QUEUE: TaskQueue
	__THREAD_LOAD: ThreadLoad

	__WINDOW_ID: int
	__IGPU_RESOURCE: IGpuResource


	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False

		self.__TASK_QUEUE = TaskQueue()
		self.__THREAD_LOAD = ThreadLoad(
			ready= True,
			path= {},
			result= nulluint32
		)

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		self.__IGPU_RESOURCE = IGpuResource(
			destroy= self.Destroy,
			object_id= uint32(0),
			load_status= False,
			fixed_update= FixedUpdate(
				action= self.__CheckQueue,
				interruption_time= 1.0
			)
		)
		self.__IGPU_RESOURCE.fixed_update.enabled = False

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
			self.__IGPU_RESOURCE.fixed_update.Destroy()
			GpuResourceManagerSystem.RemoveGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)
			del self.__IGPU_RESOURCE
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST
	
	def GetObjectId(self) -> uint32:
		return self.__IGPU_RESOURCE.object_id
	
	def GetLoadStatus(self) -> bool:
		return self.__IGPU_RESOURCE.load_status
	



	def LoadToRam(self, value: Dict[str,Literal['VERTEX_SHADER','GEOMETRY_SHADER','FRAGMENT_SHADER']]) -> 'Shader':
		def __LoadToRam(value: ThreadLoad) -> None:
			sleep(1)
			print(value)
			value['ready'] = True

		self.__THREAD_LOAD['ready'] = False
		self.__THREAD_LOAD['path'] = value
		FlowControlSystem.CreateFrameThreadTask(__LoadToRam, self.__THREAD_LOAD)
		return self

	def UnloadRam(self) -> 'Shader':
		
		self.__IGPU_RESOURCE.fixed_update.enabled = True
		return self



	def LoadToGpu(self) -> 'Shader':

		self.__IGPU_RESOURCE.fixed_update.enabled = True
		return self

	def UnloadToGpu(self) -> 'Shader':

		self.__IGPU_RESOURCE.fixed_update.enabled = True
		return self



	def __CheckQueue(self) -> None:
		if(self.__THREAD_LOAD['ready']): self.__TASK_QUEUE.execute_next()
		if(self.__TASK_QUEUE.is_empty()):
			self.__IGPU_RESOURCE.fixed_update.enabled = False