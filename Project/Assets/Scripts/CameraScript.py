from engine import *


class CameraScript(ScriptBase):

	__MOUSE_POSITION: vec2
	__HALF_WIDTH_SCREEN: int
	__HALF_HEIGHT_SCREEN: int
	__DIREVTION_VELOCITY: vec3

	__PARENT_TRANSFORM: Transform


	__BUTTON_PRESSED_FOR_CREATE: bool

	__BUTTON_PRESSED_IN_WINDOW: int

	__LIGHT_MATERIAL: Material


	def __init__(self, light_material: Material) -> None:
		self.__MOUSE_POSITION = vec2()
		self.__HALF_WIDTH_SCREEN = 1
		self.__HALF_HEIGHT_SCREEN = 1
		self.__DIREVTION_VELOCITY = vec3()
		self.__BUTTON_PRESSED_FOR_CREATE = False
		self.__BUTTON_PRESSED_IN_WINDOW = 0

		self.__LIGHT_MATERIAL = light_material


	def _OnStart(self) -> None:
		self.SetFixedUpdateInterruptionTime(0.01)
		w = WindowContext.GetCurrentWindow()
		if(w is not None): self.__WINDOW = w
		self.__WINDOW.AppendCallbackSize(self.__CallBack)
		size = self.__WINDOW.GetSize()
		self.__HALF_WIDTH_SCREEN = int(size.x*0.5)
		self.__HALF_HEIGHT_SCREEN = int(size.y*0.5)

	def __CallBack(self, width: int, height: int) -> None:
		self.__HALF_WIDTH_SCREEN = int(width*0.5)
		self.__HALF_HEIGHT_SCREEN = int(height*0.5)

	def _OnDestroy(self) -> None:
		pass


	def _OnFixedUpdate(self, dt: float) -> None:

		if(self.__BUTTON_PRESSED_IN_WINDOW):
			self.__Movement(dt)
		
		if(self.__WINDOW.InFocus() and not self.__BUTTON_PRESSED_IN_WINDOW and KeyBoard.GetFunctionalKey("tab")):
			self.__BUTTON_PRESSED_IN_WINDOW = 2
			Mouse.SetPosition(self.__HALF_WIDTH_SCREEN, self.__HALF_HEIGHT_SCREEN)
		if(self.__BUTTON_PRESSED_IN_WINDOW == 2 and not KeyBoard.GetFunctionalKey("tab")):
			self.__BUTTON_PRESSED_IN_WINDOW = 1
		
		if(not self.__WINDOW.InFocus() or (self.__BUTTON_PRESSED_IN_WINDOW == 1 and KeyBoard.GetFunctionalKey("tab"))):
			self.__BUTTON_PRESSED_IN_WINDOW = 3
		if(self.__BUTTON_PRESSED_IN_WINDOW == 3 and not KeyBoard.GetFunctionalKey("tab")):
			self.__BUTTON_PRESSED_IN_WINDOW = 0
		


	def __Movement(self, dt: float) -> None:
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

		parent_transform.position += direction_velocity * dt * (50 if KeyBoard.GetFunctionalKey("left_shift") else 10)


		mouse_pos = Mouse.GetPosition()
		acceleration = (mouse_pos - self.__MOUSE_POSITION) * dt * 15


		parent_transform.rotation.Ly(-acceleration.x)
		transform.local_rotation.Lx(-acceleration.y)
		if(KeyBoard.GetFunctionalKey("left")): parent_transform.rotation.Ly(1 * 100 * dt)
		if(KeyBoard.GetFunctionalKey("right")): parent_transform.rotation.Ly(-1 * 100 * dt)
		if(KeyBoard.GetFunctionalKey("up")): transform.local_rotation.Lx(1 * 100 * dt)
		if(KeyBoard.GetFunctionalKey("down")): transform.local_rotation.Lx(-1 * 100 * dt)

		Mouse.SetPosition(self.__HALF_WIDTH_SCREEN, self.__HALF_HEIGHT_SCREEN)
		self.__MOUSE_POSITION.SetValues(self.__HALF_WIDTH_SCREEN, self.__HALF_HEIGHT_SCREEN)
		self.__MOUSE_POSITION.SetVector(Mouse.GetPosition())

		if(not self.__BUTTON_PRESSED_FOR_CREATE and KeyBoard.GetKey("f")):
			self.__BUTTON_PRESSED_FOR_CREATE = True
			self.__CreateLight()
		if(not KeyBoard.GetKey("f") and self.__BUTTON_PRESSED_FOR_CREATE):
			self.__BUTTON_PRESSED_FOR_CREATE = False
	


	def __CreateLight(self) -> None:
		GameObject(
			name= "light",
			tag= "Default",
			transform= Transform(
				self.transform.position + self.transform.forward * 5,
				vec3( 0.1 , 0.1 , 4 ),
				Rotation().SetMatrix(mat3.GetInverse(self.transform.rotation))
			),
			components= [
				Procedural(
					material= self.__LIGHT_MATERIAL,
					type_procedural_object= "Cube"
				)
			],
			childrens=[]
		)