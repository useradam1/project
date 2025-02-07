from .WindowSystem import WindowManagerSystem
from .SceneObjectsSystem import SceneManagerSystem
from .Profiler import Profiler

PROFILER_UPDATE = 0

def showDiagram() -> None:
	global PROFILER_UPDATE
	if(PROFILER_UPDATE>10000):
		Profiler.ShowDiagram()
		PROFILER_UPDATE = 0
	PROFILER_UPDATE += 1

def StartEngine() -> None:
	#Profiler.ProfilerOn()
	while WindowManagerSystem.CanUpdateWindows():
		WindowManagerSystem.Tick()
		#showDiagram()
	WindowManagerSystem.CleaningResources()
	SceneManagerSystem.DestroyAllScenes()
	#Profiler.ProfilerOff()