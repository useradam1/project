from .UpdateSystem import UpdateSystem


def WindowInitialization(window_id: int) -> None:
	UpdateSystem.WindowInitialization(window_id)


def WindowTerminate(window_id: int) -> None:
	UpdateSystem.WindowTerminate(window_id)


def WindowUpdate(window_id: int, time: float) -> None:
	UpdateSystem.Tick(window_id, time)


