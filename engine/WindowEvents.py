from .UpdateSystem import UpdateSystem
from .ApiWindow import GetCurrentTime
from .Profiler import Profiler

def WindowInitialization(window_id: int) -> None:
	UpdateSystem.WindowInitialization(window_id)


def WindowTerminate(window_id: int) -> None:
	UpdateSystem.WindowTerminate(window_id)


def WindowUpdate(window_id: int, time: float) -> None:
	#a = GetCurrentTime()

	UpdateSystem.Tick(window_id, time)

	# b = GetCurrentTime()
	# Profiler.AppendData(
	# 	data_name= f"{window_id} UpdateSystem.Tick",
	# 	data_value= b-a)


