from ..GpuResourceSystem import GpuResourceManagerSystem, IGpuResource
from ...WindowSystem import WindowContextSystem
from ...ApiGraphics import GpuMeshInstanced, CreateMesh, DestroyMesh, DrawMesh, DrawMeshInstanced
from ...UpdateSystem import FixedUpdate
from ...FlowControlSystem import FlowControlSystem
from ...Loader import ReadObjData, MeshData
from typing import TypedDict, List
from numpy import uint32
nulluint32 = uint32(0)


from ...Log import LogColors, PrintLog
from ...CustomMetaclass import TaskQueue


class ThreadLoad(TypedDict):
	ready: bool
	path: str
	separate: bool
	meshes: List[MeshData]


class Mesh:

	__ID: int
	__STATUS_EXIST: bool
	__TASK_QUEUE: TaskQueue
	__OBJECT: GpuMeshInstanced
	__LOOAD_STATUS_GPU: bool
	__FIXED_UPDATE: FixedUpdate
	__THREAD_LOAD_RAM: ThreadLoad

	__WINDOW_ID: int
	__IGPU_RESOURCE: IGpuResource


	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__TASK_QUEUE = TaskQueue()
		self.__OBJECT = GpuMeshInstanced(nulluint32,nulluint32,nulluint32,nulluint32,nulluint32,0)
		self.__LOOAD_STATUS_GPU = False
		self.__FIXED_UPDATE = FixedUpdate(self.__CheckQueue, 1.0)
		self.__FIXED_UPDATE.enabled = False
		self.__THREAD_LOAD_RAM = ThreadLoad(
			ready= True,
			path= "",
			separate= False,
			meshes= []
		)

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
			GpuResourceManagerSystem.RemoveGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)
			del self.__IGPU_RESOURCE
			self.__STATUS_EXIST = False
			PrintLog(f"{self.__class__.__name__} Terminate", color= LogColors.YELLOW)


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	def GetObject(self) -> GpuMeshInstanced:
		return self.__OBJECT

	def GetLoadStatusGpu(self) -> bool:
		return self.__LOOAD_STATUS_GPU

	def GetStatusThreadActive(self) -> bool:
		return not self.__THREAD_LOAD_RAM['ready']




	def LoadToRam(self, value: str, separate: bool) -> 'Mesh':
		def __LoadToRam(thread_load: ThreadLoad) -> None:
			thread_load['meshes'] = ReadObjData(thread_load['path'], thread_load['separate'])
			thread_load['ready'] = True

		self.__THREAD_LOAD_RAM['ready'] = False
		self.__THREAD_LOAD_RAM['path'] = value
		self.__THREAD_LOAD_RAM['separate'] = separate
		FlowControlSystem.CreateFrameThreadTask(__LoadToRam, self.__THREAD_LOAD_RAM)
		return self

	def UnloadRam(self) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__THREAD_LOAD_RAM['meshes'] = []
			self.__FIXED_UPDATE.enabled = True
		return self


	def __loadToGpu(self, index: int = -1) -> None:
		self.__unloadGpu()
		meshes = self.__THREAD_LOAD_RAM['meshes']
		if(len(meshes) == 0):
			PrintLog(f"[ERROR] geometries are not loaded {self.__THREAD_LOAD_RAM['path']}", LogColors.RED)
			return
		if(index > len(meshes)):
			PrintLog(f"[ERROR] the index has exceeded the acceptable limit, the dictionary stores {len(meshes)} number of goemetries", LogColors.RED)
			return
		mesh = meshes[index]
		result: GpuMeshInstanced = CreateMesh(mesh.GetVertices(), mesh.GetUvCoords(), mesh.GetNormals(), mesh.GetFaces())
		(self.__OBJECT.vao,
		self.__OBJECT.vbo_vertices,
		self.__OBJECT.vbo_uvs,
		self.__OBJECT.vbo_normals,
		self.__OBJECT.ebo_faces,
		self.__OBJECT.len_faces) = (
		result.vao,
		result.vbo_vertices,
		result.vbo_uvs,
		result.vbo_normals,
		result.ebo_faces,
		result.len_faces)
		self.__LOOAD_STATUS_GPU = True

	def LoadToGpu(self) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToGpu)
			self.__FIXED_UPDATE.enabled = True
		else: self.__loadToGpu()
		return self


	def __unloadGpu(self) -> None:
		if(self.__LOOAD_STATUS_GPU):
			DestroyMesh(self.__OBJECT)
			self.__LOOAD_STATUS_GPU = True

	def UnloadGpu(self) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__unloadGpu)
			self.__FIXED_UPDATE.enabled = True
		else: self.__unloadGpu()
		return self



	def __CheckQueue(self) -> None:
		if(self.__THREAD_LOAD_RAM['ready']): self.__TASK_QUEUE.execute_next()
		if(self.__TASK_QUEUE.is_empty()):
			self.__FIXED_UPDATE.enabled = False



	def DrawMesh(self) -> None:
		if(self.__LOOAD_STATUS_GPU):
			DrawMesh(self.__OBJECT)

	def DrawMeshInstanced(self, instanceCount: int) -> None:
		if(self.__LOOAD_STATUS_GPU):
			DrawMeshInstanced(self.__OBJECT, instanceCount)