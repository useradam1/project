from .ApiWindow import GetCurrentTime
from .Profiler import Profiler


from .WindowSystem.Controllers.Mouse import MouseSystem
from .UpdateSystem import UpdateSystem
from .SceneObjectsSystem import SceneManagerSystem
from .SceneObjectsSystem import ComponentManagerSystem


def WindowInitialization(window_id: int) -> None:
	MouseSystem.WindowInitialization(window_id)
	UpdateSystem.WindowInitialization(window_id)
	ComponentManagerSystem.WindowInitialization(window_id)
	SceneManagerSystem.WindowInitialization(window_id)

def WindowFlush(window_id: int) -> None:
	SceneManagerSystem.WindowFlush(window_id)
	ComponentManagerSystem.WindowFlush(window_id)
	UpdateSystem.WindowFlush(window_id)

def WindowTerminate(window_id: int) -> None:
	SceneManagerSystem.WindowTerminate(window_id)
	ComponentManagerSystem.WindowTerminate(window_id)
	UpdateSystem.WindowTerminate(window_id)
	MouseSystem.WindowTerminate(window_id)


def WindowUpdate(window_id: int, time: float) -> None:
	# a = GetCurrentTime()

	UpdateSystem.Tick(window_id, time)

	# b = GetCurrentTime()
	# Profiler.AppendData(
	# 	data_name= f"{window_id} UpdateSystem.Tick",
	# 	data_value= b-a)


