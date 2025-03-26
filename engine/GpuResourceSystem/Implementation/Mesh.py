from ..GpuResourceSystem import GpuResourceManagerSystem, IGpuResource
from ...WindowSystem import WindowContextSystem
from ...ApiGraphics import GpuMeshInstanced, CreateMesh, DestroyMesh, DrawMesh, DrawMeshInstanced
from ...UpdateSystem import Update
from ...FlowControlSystem import FlowControlSystem
from ...Loader import ReadObjData, MeshData

from .BvhController import BvhController, bvh_data_dtype
from .TrianglesController import TrianglesController, triangles_data_dtype

from typing import TypedDict, List, Tuple
from numpy import uint32, array, float32

nulluint32 = uint32(0)


from ...Log import LogColors, PrintLog
from ...CustomMetaclass import TaskQueue


class ThreadLoad(TypedDict):
	ready: bool
	path: str
	separate: bool
	meshes: List[MeshData]
	error_log: str

def MeshDataLoad(thread_load_ram: ThreadLoad) -> None:
	thread_load_ram['meshes'], thread_load_ram['error_log'] = ReadObjData(thread_load_ram['path'], thread_load_ram['separate'])
	thread_load_ram['ready'] = True

class Mesh:

	__ID: int
	__STATUS_EXIST: bool
	__TASK_QUEUE: TaskQueue
	__LOAD_STATUS_GPU: bool
	__THREAD_LOAD_RAM: ThreadLoad

	__BVH_INDEX: int

	__WINDOW_ID: int
	__IGPU_RESOURCE: IGpuResource

	__OBJECT: GpuMeshInstanced
	__UPDATE: Update


	def __init__(self) -> None:
		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__TASK_QUEUE = TaskQueue()
		self.__LOAD_STATUS_GPU = False
		self.__THREAD_LOAD_RAM = ThreadLoad(
			ready= True,
			path= "",
			separate= False,
			meshes= [],
			error_log= ""
		)

		self.__BVH_INDEX = -1

		self.__WINDOW_ID = WindowContextSystem.GetCurrentWindowId()
		if(not self.__WINDOW_ID):
			PrintLog(f"{self.__class__.__name__} cannot be created outside of the window context", color= LogColors.RED)
			return

		self.__IGPU_RESOURCE = IGpuResource(self.Destroy)

		if(not GpuResourceManagerSystem.AppendGpuResource(self.__IGPU_RESOURCE, self.__WINDOW_ID)):
			del self.__IGPU_RESOURCE
			PrintLog(f"{self.__class__.__name__} registration denied", color= LogColors.RED)
			return

		self.__OBJECT = GpuMeshInstanced(nulluint32,nulluint32,nulluint32,nulluint32,nulluint32,0)

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
			self.UnloadGpu()
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
		return self.__LOAD_STATUS_GPU

	def GetMeshesData(self) -> List[MeshData]:
		return self.__THREAD_LOAD_RAM['meshes']

	def GetErrorLog(self) -> str:
		return self.__THREAD_LOAD_RAM['error_log']

	def GetStatusThreadActive(self) -> bool:
		return not self.__THREAD_LOAD_RAM['ready']



	def __loadToRamFromPath(self, path: str, separate: bool) -> None:
		self.__THREAD_LOAD_RAM['ready'] = False
		self.__THREAD_LOAD_RAM['path'] = path
		self.__THREAD_LOAD_RAM['separate'] = separate
		FlowControlSystem.CreateFrameProcessTask(MeshDataLoad, self.__THREAD_LOAD_RAM) #type: ignore

	def LoadToRamFromPath(self, path: str, separate: bool) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToRamFromPath, path, separate)
			self.__UPDATE.enabled = True
		else: self.__loadToRamFromPath(path, separate)
		return self



	def __loadToRamFromMeshesData(self, data: List[MeshData]) -> None:
		self.__THREAD_LOAD_RAM['meshes'] = data
		self.__THREAD_LOAD_RAM['error_log'] = ""
		self.__THREAD_LOAD_RAM['ready'] = True

	def LoadToRamFromMeshesData(self, data: List[MeshData]) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToRamFromMeshesData, data)
			self.__UPDATE.enabled = True
		else: self.__loadToRamFromMeshesData(data)
		return self



	def __unloadRam(self) -> None:
		self.__THREAD_LOAD_RAM['meshes'] = []
		self.__THREAD_LOAD_RAM['error_log'] = ""
		self.__THREAD_LOAD_RAM['ready'] = True
		PrintLog(f"{self.__class__.__name__} Unload from the RAM memory is completed", LogColors.GREEN)

	def UnloadRam(self) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__unloadRam)
			self.__UPDATE.enabled = True
		else: self.__unloadRam()
		return self



	def __loadToGpu(self, index: int = -1) -> None:
		self.__unloadGpu()
		if(self.__THREAD_LOAD_RAM['error_log']):
			PrintLog(f"[ERROR_{self.__class__.__name__}] {self.__THREAD_LOAD_RAM['error_log']}", LogColors.RED)
			return
		meshes = self.__THREAD_LOAD_RAM['meshes']
		if(len(meshes) == 0):
			PrintLog(f"[ERROR_{self.__class__.__name__}] geometries are not loaded {self.__THREAD_LOAD_RAM['path']}", LogColors.RED)
			return
		if(index >= len(meshes)):
			PrintLog(f"[ERROR_{self.__class__.__name__}] the index has exceeded the acceptable limit, the dictionary stores {len(meshes)} number of goemetries", LogColors.RED)
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
		self.__LOAD_STATUS_GPU = True
		PrintLog(f"{self.__class__.__name__} Load to the GPU memory is completed", LogColors.GREEN)

	def LoadToGpu(self, index: int = -1) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadToGpu, index)
			self.__UPDATE.enabled = True
		else: self.__loadToGpu()
		return self



	def __unloadGpu(self) -> None:
		if(self.__LOAD_STATUS_GPU):
			DestroyMesh(self.__OBJECT)
			(self.__OBJECT.vao,
			self.__OBJECT.vbo_vertices,
			self.__OBJECT.vbo_uvs,
			self.__OBJECT.vbo_normals,
			self.__OBJECT.ebo_faces,
			self.__OBJECT.len_faces) = (
			nulluint32,
			nulluint32,
			nulluint32,
			nulluint32,
			nulluint32,
			0)
			self.__LOAD_STATUS_GPU = False
			PrintLog(f"{self.__class__.__name__} Unload from the GPU memory is completed", LogColors.GREEN)

	def UnloadGpu(self) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__unloadGpu)
			self.__UPDATE.enabled = True
		else: self.__unloadGpu()
		return self



	def __CheckQueue(self) -> None:
		if(self.__THREAD_LOAD_RAM['ready']): self.__TASK_QUEUE.execute_next()
		if(self.__TASK_QUEUE.is_empty()):
			self.__UPDATE.enabled = False



	def DrawMesh(self) -> None:
		if(self.__LOAD_STATUS_GPU):
			DrawMesh(self.__OBJECT)

	def DrawMeshInstanced(self, instanceCount: int) -> None:
		if(self.__LOAD_STATUS_GPU):
			DrawMeshInstanced(self.__OBJECT, instanceCount)


	def __loadBvh(self) -> None:
		if(self.__THREAD_LOAD_RAM['error_log']):
			PrintLog(f"[ERROR_{self.__class__.__name__}] {self.__THREAD_LOAD_RAM['error_log']}", LogColors.RED)
			return
		meshes = self.__THREAD_LOAD_RAM['meshes']
		if(len(meshes) == 0):
			PrintLog(f"[ERROR_{self.__class__.__name__}] geometries are not loaded {self.__THREAD_LOAD_RAM['path']}", LogColors.RED)
			return
		mesh = meshes[-1]
		#mesh.BuildBVH()
		TrianglesController.AppendTriangles(self.__ID,
			mesh.GetTriangleData(),
			self.__WINDOW_ID
		)
		BvhController.AppendBVH(
			mesh.GetBvhData(),
			self.__WINDOW_ID
		)
		#print()
		#print(len(mesh.GetBvhData()))
		#print(len(mesh.GetTriangleData()))
		# TrianglesController.AppendTriangles(self.__ID,
		# 	array(
		# 		[
		# 			(
		# 			(2, 6, -2, 0), (-2, 6, -2, 0), (0, 6, 2, 0),	# posA, posB, posC
		# 			(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 			(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 			),
		# 			(
		# 			(2, 3, -2, 0), (-2, 3, -2, 0), (0, 3, 2, 0),	# posA, posB, posC
		# 			(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 			(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 			),
		# 			(
		# 			(2, -3, -2, 0), (-2, -3, -2, 0), (0, -3, 2, 0),	# posA, posB, posC
		# 			(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 			(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 			),
		# 			(
		# 			(2, -6, -2, 0), (-2, -6, -2, 0), (0, -6, 2, 0),	# posA, posB, posC
		# 			(0, 1, 0, 0), (0, 1, 0, 0), (0, 1, 0, 0),		# normalA, normalB, normalC
		# 			(0, 0, 0, 0), (0, 0, 0, 0), (0, 0, 0, 0)		# uvA, uvB, uvC
		# 			),
		# 		],
		# 		dtype=triangles_data_dtype
		# 	),
		# 	self.__WINDOW_ID
		# )
		# BvhController.AppendBVH(
		# 	array(
		# 		[
		# 			(
		# 				(1),							# next_left_bvh
		# 				(2),							# next_right_bvh
		# 				(-1),							# start_index
		# 				(-1),							# stop_index
		# 				(-8, -9, -8, 0), (8, 9, 8, 0),	# volumeA, volumeB
		# 			),
		# 			(
		# 				(3),							# next_left_bvh
		# 				(4),							# next_right_bvh
		# 				(-1),							# start_index
		# 				(-1),							# stop_index
		# 				(-6, 1, -6, 0), (6, 8, 6, 0),	# volumeA, volumeB
		# 			),
		# 			(
		# 				(5),							# next_left_bvh
		# 				(6),							# next_right_bvh
		# 				(-1),							# start_index
		# 				(-1),							# stop_index
		# 				(-6, -8, -6, 0), (6, -1, 6, 0),	# volumeA, volumeB
		# 			),


		# 			(
		# 				(-1),							# next_left_bvh
		# 				(-1),							# next_right_bvh
		# 				(0),							# start_index
		# 				(1),							# stop_index
		# 				(-4, 5, -4, 0), (4, 7, 4, 0),	# volumeA, volumeB
		# 			),
		# 			(
		# 				(-1),							# next_left_bvh
		# 				(-1),							# next_right_bvh
		# 				(1),							# start_index
		# 				(2),							# stop_index
		# 				(-4, 2, -4, 0), (4, 4, 4, 0),	# volumeA, volumeB
		# 			),


		# 			(
		# 				(-1),							# next_left_bvh
		# 				(-1),							# next_right_bvh
		# 				(2),							# start_index
		# 				(3),							# stop_index
		# 				(-4, -4, -4, 0), (4, -2, 4, 0),	# volumeA, volumeB
		# 			),
		# 			(
		# 				(-1),							# next_left_bvh
		# 				(-1),							# next_right_bvh
		# 				(3),							# start_index
		# 				(4),							# stop_index
		# 				(-4, -7, -4, 0), (4, -5, 4, 0),	# volumeA, volumeB
		# 			),
		# 		],
		# 		dtype=bvh_data_dtype
		# 	),
		# 	self.__WINDOW_ID
		# )


	def LoadBVH(self) -> 'Mesh':
		if(not self.__THREAD_LOAD_RAM['ready']):
			self.__TASK_QUEUE.add_task(self.__loadBvh)
			self.__UPDATE.enabled = True
		else: self.__loadBvh()
		return self
		BvhController.AppendBVH(
			array(
				[
					(
						(1),							# next_left_bvh
						(2),							# next_right_bvh
						(-1),							# start_index
						(-1),							# stop_index
						(-8, -9, -8, 0), (8, 9, 8, 0),	# volumeA, volumeB
					),
					(
						(3),							# next_left_bvh
						(4),							# next_right_bvh
						(-1),							# start_index
						(-1),							# stop_index
						(-6, 1, -6, 0), (6, 8, 6, 0),	# volumeA, volumeB
					),
					(
						(5),							# next_left_bvh
						(6),							# next_right_bvh
						(-1),							# start_index
						(-1),							# stop_index
						(-6, -8, -6, 0), (6, -1, 6, 0),	# volumeA, volumeB
					),


					(
						(-1),							# next_left_bvh
						(-1),							# next_right_bvh
						(0),							# start_index
						(1),							# stop_index
						(-4, 5, -4, 0), (4, 7, 4, 0),	# volumeA, volumeB
					),
					(
						(-1),							# next_left_bvh
						(-1),							# next_right_bvh
						(1),							# start_index
						(2),							# stop_index
						(-4, 2, -4, 0), (4, 4, 4, 0),	# volumeA, volumeB
					),


					(
						(-1),							# next_left_bvh
						(-1),							# next_right_bvh
						(2),							# start_index
						(3),							# stop_index
						(-4, -4, -4, 0), (4, -2, 4, 0),	# volumeA, volumeB
					),
					(
						(-1),							# next_left_bvh
						(-1),							# next_right_bvh
						(3),							# start_index
						(4),							# stop_index
						(-4, -7, -4, 0), (4, -5, 4, 0),	# volumeA, volumeB
					),
				],
				dtype=bvh_data_dtype
			)
			,self.__WINDOW_ID)

	def GetBvhNode(self) -> Tuple[int,int]:
		return self.__BVH_INDEX, 1