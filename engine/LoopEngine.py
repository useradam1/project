from .WindowSystem import WindowManager



def StartEngine() -> None:
	while WindowManager.CanUpdateWindows():
		WindowManager.Tick()
	WindowManager.ClearWindows()
