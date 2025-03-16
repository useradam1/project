from engine import *


class CameraScript(ScriptBase):

	__MOUSE_POSITION: vec2
	__HALF_WIDTH_SCREEN: int
	__HALF_HEIGHT_SCREEN: int
	__DIREVTION_VELOCITY: vec3

	__PARENT_TRANSFORM: Transform

	def __init__(self) -> None:
		self.__MOUSE_POSITION = vec2()
		self.__HALF_WIDTH_SCREEN = 1
		self.__HALF_HEIGHT_SCREEN = 1
		self.__DIREVTION_VELOCITY = vec3()


	def _OnStart(self) -> None:
		self.SetFixedUpdateInterruptionTime(0.01)
		self.__WINDOW = WindowContext.GetCurrentWindow() # type: ignore
		self.__WINDOW.AppendCallbackSize(self.__CallBack) # type: ignore
		size = self.__WINDOW.GetSize() # type: ignore
		self.__HALF_WIDTH_SCREEN = int(size.x*0.5)
		self.__HALF_HEIGHT_SCREEN = int(size.y*0.5)

	def __CallBack(self, width: int, height: int) -> None:
		self.__HALF_WIDTH_SCREEN = int(width*0.5)
		self.__HALF_HEIGHT_SCREEN = int(height*0.5)

	def _OnDestroy(self) -> None:
		pass


	def _OnFixedUpdate(self, dt: float) -> None:
		transform = self.gameObject.transform
		parent_transform = self.gameObject.GetParent().transform # type: ignore
	
		self.__DIREVTION_VELOCITY *= 0
		if(KeyBoard.GetKey("w")): self.__DIREVTION_VELOCITY.z += 1
		if(KeyBoard.GetKey("a")): self.__DIREVTION_VELOCITY.x -= 1
		if(KeyBoard.GetKey("s")): self.__DIREVTION_VELOCITY.z -= 1
		if(KeyBoard.GetKey("d")): self.__DIREVTION_VELOCITY.x += 1
		if(KeyBoard.GetKey("e")): self.__DIREVTION_VELOCITY.y += 1
		if(KeyBoard.GetKey("q")): self.__DIREVTION_VELOCITY.y -= 1
		self.__DIREVTION_VELOCITY.Normalize()
		direction_velocity = self.__DIREVTION_VELOCITY @ transform.rotation

		#dt = Time.GetDeltaTime()

		parent_transform.position += direction_velocity * 10 * dt


		#mouse_pos = Mouse.GetPosition()
		#acceleration = mouse_pos - self.__MOUSE_POSITION


		#parent_transform.rotation.Ly(-acceleration.x)
		#transform.local_rotation.Lx(-acceleration.y)
		if(KeyBoard.GetFunctionalKey("left")): parent_transform.rotation.Ly(1 * 100 * dt)
		if(KeyBoard.GetFunctionalKey("right")): parent_transform.rotation.Ly(-1 * 100 * dt)
		if(KeyBoard.GetFunctionalKey("up")): transform.local_rotation.Lx(1 * 100 * dt)
		if(KeyBoard.GetFunctionalKey("down")): transform.local_rotation.Lx(-1 * 100 * dt)

		#Mouse.SetPosition(self.__HALF_WIDTH_SCREEN, self.__HALF_HEIGHT_SCREEN)
		#self.__MOUSE_POSITION.SetValues(self.__HALF_WIDTH_SCREEN, self.__HALF_HEIGHT_SCREEN)
		#self.__MOUSE_POSITION.SetVector(Mouse.GetPosition())