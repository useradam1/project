from ..SceneObjectsSystem import Component
from ..WindowSystem import WindowContextSystem
from ..Math import mat4, mat4_ptr_static, tan, deg2rad

from .CameraController import CameraController
from ..Log import LogColors, PrintLog

from typing import Literal


class Camera(Component):

	__STATUS_ALLOCATED: bool
	__ALLOCATE_INDEX: int

	__MOD: Literal['perspective','orthographic']
	__FOV: float
	__NEAR: float
	__FAR: float
	__LEFT: float
	__RIGHT: float
	__BOTTOM: float
	__TOP: float
	__ASPECT: float

	__PROJECTION: mat4
	__PROJECTION_PTR: mat4_ptr_static


	def __init__(self,
			mod: Literal['perspective','orthographic'], 
			fov: float, 
			near: float, 
			far: float, 
			left: float, 
			right: float, 
			bottom: float, 
			top: float
		) -> None:
		self.__STATUS_ALLOCATED = False
		self.__ALLOCATE_INDEX = -1

		self.__MOD = mod
		self.__FOV = fov
		self.__NEAR = near
		self.__FAR = far
		self.__LEFT = left
		self.__RIGHT = right
		self.__BOTTOM = bottom
		self.__TOP = top
		self.__ASPECT = 1.0

		self.__PROJECTION = mat4()
		self.__PROJECTION_PTR = mat4_ptr_static()



	def __perspective_matrix(self) -> None:
		f = 1 / tan(deg2rad(self.__FOV) / 2)
		self.__PROJECTION.SetValues(
			f / self.__ASPECT, 0, 0, 0,
			0, f, 0, 0,
			0, 0, (self.__FAR + self.__NEAR) / (self.__NEAR - self.__FAR), -1,
			0, 0, 2 * self.__FAR * self.__NEAR / (self.__NEAR - self.__FAR), 0
		)
	def __orthographic_matrix(self) -> None:
		self.__PROJECTION.SetValues(
			   2/(self.__RIGHT-self.__LEFT)  ,       0      ,       0      ,       0      ,
			       0      ,   2/(self.__TOP-self.__BOTTOM)  ,       0      ,       0      ,
			       0      ,       0      ,     -1/self.__FAR     ,       0      ,
			       0      ,       0      ,-(self.__FAR-self.__NEAR-1)/(self.__FAR-1),       1      
		)


	def _OnStart(self) -> None:
		if(self.__STATUS_ALLOCATED): return
		self.__ALLOCATE_INDEX = CameraController.AllocateIndex(self._WINDOW_ID)
		if(self.__ALLOCATE_INDEX < 0):
			PrintLog(f"[ERROR_{self.__class__.__name__}] it is impossible to allocate memory, the space of allocated areas greatly exceeds the allowable value of objects for allocation.", LogColors.RED)
			return
		gameObject = self.gameObject
		gameObject.AllocateIndex()
		if(not gameObject.GetStatusAllocated()):
			CameraController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
			self.__ALLOCATE_INDEX = -1
			return

		window = WindowContextSystem.GetCurrentWindow()
		window.AppendCallbackSize(self.__UpdateScreen) # type: ignore
		size = window.GetSize() # type: ignore
		self.__ASPECT = size.x / size.y
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

		numpy_array = CameraController.GetAllocateNumpy(self._WINDOW_ID)
		numpy_array[self.__ALLOCATE_INDEX]["transform_index"] = gameObject.GetAllocateIndex()
		self.__PROJECTION.LinkMemory(numpy_array[self.__ALLOCATE_INDEX]["projection"],0)		
		self.__PROJECTION_PTR.LinkMatrix(self.__PROJECTION)

		gameObject.AppendAllocatableComponent()

		self.__STATUS_ALLOCATED = True


	def _OnDestroy(self) -> None:
		if(not self.__STATUS_ALLOCATED): return

		self.__PROJECTION_PTR.UnlinkMatrix()
		self.__PROJECTION.UnlinkMemory()
		CameraController.DeallocateIndex(self.__ALLOCATE_INDEX, self._WINDOW_ID)
		self.__ALLOCATE_INDEX = -1
		self.__STATUS_ALLOCATED = False
		self.gameObject.RemoveAllocatableComponent()

		WindowContextSystem.GetCurrentWindow().RemoveCallbackSize(self.__UpdateScreen) # type: ignore

		if(self.gameObject.GetAllocatableComponentCount() > 0): return
		self.gameObject.DeallocateIndex()


	def __UpdateScreen(self, width: int, height: int) -> None:
		self.__ASPECT = width/height
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())


	def GetStatusAllocated(self) -> bool:
		return self.__STATUS_ALLOCATED
	
	def GetAllocateIndex(self) -> int:
		return self.__ALLOCATE_INDEX


	@property
	def projection(self) -> mat4:
		return self.__PROJECTION_PTR

	@property
	def mod(self) -> Literal['perspective','orthographic']:
		return self.__MOD
	@mod.setter
	def mod(self, value: Literal['perspective','orthographic']) -> None:
		self.__MOD = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

	@property
	def fov(self) -> float:
		return self.__FOV
	@fov.setter
	def fov(self, value: float) -> None:
		self.__FOV = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

	@property
	def near(self) -> float:
		return self.__NEAR
	@near.setter
	def near(self, value: float) -> None:
		self.__NEAR = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

	@property
	def far(self) -> float:
		return self.__FAR
	@far.setter
	def far(self, value: float) -> None:
		self.__FAR = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

	@property
	def left(self) -> float:
		return self.__LEFT
	@left.setter
	def left(self, value: float) -> None:
		self.__LEFT = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

	@property
	def right(self) -> float:
		return self.__RIGHT
	@right.setter
	def right(self, value: float) -> None:
		self.__RIGHT = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

	@property
	def bottom(self) -> float:
		return self.__BOTTOM
	@bottom.setter
	def bottom(self, value: float) -> None:
		self.__BOTTOM = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())

	@property
	def top(self) -> float:
		return self.__TOP
	@top.setter
	def top(self, value: float) -> None:
		self.__TOP = value
		(self.__perspective_matrix() if(self.__MOD=='perspective') else self.__orthographic_matrix())