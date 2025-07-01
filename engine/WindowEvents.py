from .ApiWindow import GetCurrentTime
from .ApiGraphics import GetVersion
from .Profiler import Profiler


from .WindowSystem.Controllers.KeyBoard import KeyboardSystem
from .WindowSystem.Controllers.Mouse import MouseSystem
from .UiSystem import UiSystem

from .GpuResourceSystem import MeshController
from .RenderSystem import CameraController
from .RenderSystem import ProceduralController
from .RenderSystem import ProceduralMeshController
from .RenderSystem import ProceduralSDFController

from .GpuResourceSystem import BindTextureController
from .GpuResourceSystem import GpuResourceManagerSystem
from .GpuResourceSystem import ShaderContext
from .GpuResourceSystem import MaterialControllerSystem
from .UpdateSystem import UpdateManagerSystem
from .AssetsEngineSystem import AssetsEngineSystem
from .SceneObjectsSystem import SceneManagerSystem
from .SceneObjectsSystem import ComponentManagerSystem
from .RenderSystem import RenderingPipeline


VERSION_PRINTED: bool = False

def WindowInitialization(window_id: int) -> None:
	global VERSION_PRINTED
	if(not VERSION_PRINTED):
		print(GetVersion())
		VERSION_PRINTED = True
	KeyboardSystem.WindowInitialization(window_id)
	MouseSystem.WindowInitialization(window_id)
	#UiSystem.WindowInitialization(window_id)

	MeshController.WindowInitialization(window_id)
	CameraController.WindowInitialization(window_id)
	ProceduralController.WindowInitialization(window_id)
	ProceduralMeshController.WindowInitialization(window_id)
	ProceduralSDFController.WindowInitialization(window_id)

	BindTextureController.WindowInitialization(window_id)
	GpuResourceManagerSystem.WindowInitialization(window_id)
	ShaderContext.WindowInitialization(window_id)
	MaterialControllerSystem.WindowInitialization(window_id)
	UpdateManagerSystem.WindowInitialization(window_id)
	AssetsEngineSystem.WindowInitialization(window_id)
	ComponentManagerSystem.WindowInitialization(window_id)
	SceneManagerSystem.WindowInitialization(window_id)
	RenderingPipeline.WindowInitialization(window_id)


def WindowFlush(window_id: int) -> None:
	SceneManagerSystem.WindowFlush(window_id)
	ComponentManagerSystem.WindowFlush(window_id)
	UpdateManagerSystem.WindowFlush(window_id)
	MaterialControllerSystem.WindowFlush(window_id)
	GpuResourceManagerSystem.WindowFlush(window_id)
	BindTextureController.WindowFlush(window_id)

	ProceduralSDFController.WindowFlush(window_id)
	ProceduralMeshController.WindowFlush(window_id)
	ProceduralController.WindowFlush(window_id)
	CameraController.WindowFlush(window_id)
	MeshController.WindowFlush(window_id)

	#UiSystem.WindowFlush(window_id)


def WindowTerminate(window_id: int) -> None:
	RenderingPipeline.WindowTerminate(window_id)
	SceneManagerSystem.WindowTerminate(window_id)
	ComponentManagerSystem.WindowTerminate(window_id)
	AssetsEngineSystem.WindowTerminate(window_id)
	UpdateManagerSystem.WindowTerminate(window_id)
	MaterialControllerSystem.WindowTerminate(window_id)
	ShaderContext.WindowTerminate(window_id)
	GpuResourceManagerSystem.WindowTerminate(window_id)
	BindTextureController.WindowTerminate(window_id)

	ProceduralSDFController.WindowTerminate(window_id)
	ProceduralMeshController.WindowTerminate(window_id)
	ProceduralController.WindowTerminate(window_id)
	CameraController.WindowTerminate(window_id)
	MeshController.WindowTerminate(window_id)

	#UiSystem.WindowTerminate(window_id)
	MouseSystem.WindowTerminate(window_id)
	KeyboardSystem.WindowTerminate(window_id)



def WindowUpdate(window_id: int, time: float) -> None:
	# a = GetCurrentTime()

	KeyboardSystem.WindowUpdate(window_id)
	MouseSystem.WindowUpdate(window_id)

	# b = GetCurrentTime()
	# Profiler.AppendData(
	# 	data_name= f"{window_id} controllers",
	# 	data_value= b-a)
	# a = GetCurrentTime()

	UpdateManagerSystem.Tick(window_id, time)

	# b = GetCurrentTime()
	# Profiler.AppendData(
	# 	data_name= f"{window_id} UpdateSystem.Tick",
	# 	data_value= b-a)

	RenderingPipeline.ShowScene(
		window_id, 
		(
			SceneManagerSystem.UpdateBuffer,
			CameraController.UpdateBuffer,
			ProceduralController.UpdateBuffer,
			MeshController.UpdateBuffer,
			ProceduralMeshController.UpdateBuffer,
			ProceduralSDFController.UpdateBuffer
		)
	)

	#UiSystem.ShowUi(window_id)



