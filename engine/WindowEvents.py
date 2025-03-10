from .ApiWindow import GetCurrentTime
from .ApiGraphics import GetVersion
from .Profiler import Profiler


from .WindowSystem.Controllers.Mouse import MouseSystem
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
	MouseSystem.WindowInitialization(window_id)
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

def WindowTerminate(window_id: int) -> None:
	RenderingPipeline.WindowTerminate(window_id)
	SceneManagerSystem.WindowTerminate(window_id)
	ComponentManagerSystem.WindowTerminate(window_id)
	AssetsEngineSystem.WindowTerminate(window_id)
	UpdateManagerSystem.WindowTerminate(window_id)
	MaterialControllerSystem.WindowTerminate(window_id)
	ShaderContext.WindowTerminate(window_id)
	GpuResourceManagerSystem.WindowTerminate(window_id)
	MouseSystem.WindowTerminate(window_id)


def WindowUpdate(window_id: int, time: float) -> None:
	# a = GetCurrentTime()

	UpdateManagerSystem.Tick(window_id, time)

	RenderingPipeline.RenderScene(window_id)

	# b = GetCurrentTime()
	# Profiler.AppendData(
	# 	data_name= f"{window_id} UpdateSystem.Tick",
	# 	data_value= b-a)


