from engine import *


class RotareScript(ScriptBase):

	def __init__(self) -> None:
		pass


	def _OnStart(self) -> None:
		self.SetFixedUpdateInterruptionTime(0.01)
		pass

	def __CallBack(self, width: int, height: int) -> None:
		pass

	def _OnDestroy(self) -> None:
		pass


	def _OnFixedUpdate(self, dt: float) -> None:
		self.gameObject.transform.rotation.Lz(100*dt)