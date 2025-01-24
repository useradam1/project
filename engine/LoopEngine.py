from .WindowSystem import WindowManagerSystem



def StartEngine() -> None:
	while WindowManagerSystem.CanUpdateWindows():
		WindowManagerSystem.Tick()
	WindowManagerSystem.CleaningResources()