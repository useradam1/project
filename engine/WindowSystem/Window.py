from ..WindowEvents import WindowInitialization, WindowTerminate, WindowUpdate
from .WindowInterface import WindowInterface, IWindow
from .WindowContext import WindowContextSystem
from .WindowManager import WindowManagerSystem
from ..Math import vec2, vec2_ptr_static, vec4
from ..ApiWindow import window_type, CreateWindow, DestroyWindow, WindowShouldClose, GetCurrentTime, GetWindowPosition
from ..ApiWindow import SetWindowTitle, SetSwapInterval, SetWindowPosition, SetWindowResize, SetWindowSize
from ..ApiWindow import SetCallbackWindowFocus, SetCallbackWindowSize, SetCallbackWindowPosition
from typing import Optional
from ..Profiler import Profiler


class Window(WindowInterface):

	__ID: int
	__STATUS_EXIST: bool
	__REQUEST_DESTROY: int

	__TITLE: str
	__SIZE: vec2
	__SIZE_OUTPUT: vec2_ptr_static
	__POSITION: vec2
	__POSITION_OUTPUT: vec2_ptr_static
	__FRAME_RATE: int
	__FRAME_RATE_CONTROL: vec4
	__TITLE_FPS_ACCUMULATE: float
	__RESIZE: bool

	__IN_FOCUS: int

	__IWINDOW: IWindow
	__WINDOW_OBJECT: Optional[window_type]


	def __init__(self,
		title: str,
		size: vec2,
		frame_rate: int,
		resize: bool
		) -> None:

		self.__ID = id(self)
		self.__STATUS_EXIST = False
		self.__REQUEST_DESTROY = 0

		self.__TITLE = title
		self.__SIZE = size//1
		self.__SIZE_OUTPUT = vec2_ptr_static()
		self.__POSITION = vec2()
		self.__POSITION_OUTPUT = vec2_ptr_static()
		self.__FRAME_RATE = frame_rate
		self.__FRAME_RATE_CONTROL = vec4()
		self.__TITLE_FPS_ACCUMULATE = 0.0
		if(frame_rate > 0): self.__FRAME_RATE_CONTROL.x = 1.0/float(frame_rate)
		self.__RESIZE = resize

		self.__IN_FOCUS = 0

		self.__WINDOW_OBJECT = None
		self.__IWINDOW = IWindow(self, self.__Tick, self.__ImmediateDestroy)

		if(not WindowManagerSystem.AppendWindow(self.__IWINDOW)):
			del self.__IWINDOW
			return

		self.__WINDOW_OBJECT = CreateWindow(int(self.__SIZE.x), int(self.__SIZE.y), self.__TITLE)

		if self.__WINDOW_OBJECT is None:
			WindowManagerSystem.RemoveWindow(self.__IWINDOW)
			del self.__IWINDOW
			return

		self.__IN_FOCUS = 1
		self.__SIZE_OUTPUT.LinkVector(self.__SIZE)
		self.__POSITION_OUTPUT.LinkVector(self.__POSITION)
		WindowContextSystem.SetCurrentWindow(self)
		SetSwapInterval(0)
		SetWindowResize(self.__WINDOW_OBJECT,self.__RESIZE)
		self.__POSITION.x, self.__POSITION.y = GetWindowPosition(self.__WINDOW_OBJECT)
		SetCallbackWindowSize(self.__WINDOW_OBJECT, self.__CallbackSize)
		SetCallbackWindowFocus(self.__WINDOW_OBJECT, self.__CallbackFocus)
		SetCallbackWindowPosition(self.__WINDOW_OBJECT, self.__CallbackPosition)

		self.__STATUS_EXIST = True
		WindowInitialization(self.__ID)


	def __del__(self) -> None:
		print("Window deleted")

	def Destroy(self) -> None:
		self.__REQUEST_DESTROY = 1

	def __ImmediateDestroy(self) -> None:
		if(self.__STATUS_EXIST):
			push_context_window = WindowContextSystem.GetCurrentWindow()
			WindowContextSystem.SetCurrentWindow(self)
			WindowTerminate(self.__ID)
			WindowManagerSystem.RemoveWindow(self.__IWINDOW)
			SetCallbackWindowSize(self.__WINDOW_OBJECT, None) # type: ignore
			SetCallbackWindowFocus(self.__WINDOW_OBJECT, None) # type: ignore
			SetCallbackWindowPosition(self.__WINDOW_OBJECT, None) # type: ignore
			WindowContextSystem.SetCurrentWindow(push_context_window)
			DestroyWindow(self.__WINDOW_OBJECT) # type: ignore
			self.__SIZE_OUTPUT.Unlink()
			self.__POSITION_OUTPUT.Unlink()
			self.__WINDOW_OBJECT = None
			del self.__IWINDOW
			self.__STATUS_EXIST = False
		self.__REQUEST_DESTROY = 0


	def __CallbackFocus(self, window: window_type, value: int) -> None:
		self.__IN_FOCUS = value

	def __CallbackSize(self, window: window_type, width: int, height: int) -> None:
		self.__SIZE.x = width
		self.__SIZE.y = height

	def __CallbackPosition(self, window: window_type, x: int, y: int) -> None:
		self.__POSITION.x = x
		self.__POSITION.y = y


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	def GetWindowObject(self) -> Optional[window_type]:
		return self.__WINDOW_OBJECT


	def InFocus(self) -> bool:
		return self.__IN_FOCUS # type: ignore


	def GetIsResizeable(self) -> bool:
		return self.__RESIZE 
	def SetIsResizeable(self, value: bool) -> None:
		if(self.__STATUS_EXIST):
			self.__RESIZE = value
			SetWindowResize(self.__WINDOW_OBJECT, value) # type: ignore


	def GetTitle(self) -> str:
		return self.__TITLE
	def SetTitle(self, title: str) -> None:
		if(self.__STATUS_EXIST):
			self.__TITLE = title
			SetWindowTitle(self.__WINDOW_OBJECT, title) # type: ignore

	def GetSize(self) -> vec2:
		return self.__SIZE_OUTPUT
	def SetSize(self, width: int, height: int) -> None:
		if(self.__STATUS_EXIST):
			self.__SIZE.x = width
			self.__SIZE.y = height
			SetWindowSize(self.__WINDOW_OBJECT, width, height) # type: ignore

	def GetPosition(self) -> vec2:
		return self.__POSITION_OUTPUT
	def SetPosition(self, x: int, y: int) -> None:
		if(self.__STATUS_EXIST):
			self.__POSITION.x = x
			self.__POSITION.y = y
			SetWindowPosition(self.__WINDOW_OBJECT, x, y) # type: ignore

	def GetFrameRate(self) -> int:
		return self.__FRAME_RATE
	def SetFrameRate(self, frame_rate: int) -> None:
		self.__FRAME_RATE = frame_rate
		if(frame_rate > 0): self.__FRAME_RATE_CONTROL.x = 1.0/float(frame_rate)
		else: self.__FRAME_RATE_CONTROL.x = 0.0

	def GetCurrentFrameRate(self) -> float:
		return self.__FRAME_RATE_CONTROL.y


	def __Tick(self) -> None:
		WindowContextSystem.SetCurrentWindow(self)
		if(self.__REQUEST_DESTROY or WindowShouldClose(self.__WINDOW_OBJECT)):
			self.__ImmediateDestroy()
			return
		time = GetCurrentTime()
		if(time < self.__FRAME_RATE_CONTROL.w): return



		WindowUpdate(self.__ID, time)



		self.__FRAME_RATE_CONTROL.y = GetCurrentTime() - self.__FRAME_RATE_CONTROL.z
		self.__TITLE_FPS_ACCUMULATE += self.__FRAME_RATE_CONTROL.y

		if(self.__TITLE_FPS_ACCUMULATE > 1.0):
			SetWindowTitle(self.__WINDOW_OBJECT, f"{self.__TITLE} - {1.0/self.__FRAME_RATE_CONTROL.y:.1f}fps") # type: ignore
			self.__TITLE_FPS_ACCUMULATE = 0

		self.__FRAME_RATE_CONTROL.z = time
		self.__FRAME_RATE_CONTROL.w = time + self.__FRAME_RATE_CONTROL.x