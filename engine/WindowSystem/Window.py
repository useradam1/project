from ..WindowEvents import WindowInitialization, WindowTerminate, WindowUpdate
from .WindowInterface import WindowInterface, IWindow
from .WindowContext import WindowContextSystem
from .WindowManager import WindowManagerSystem
from ..Math import vec2, vec2_ptr_static
from ..ApiWindow import window_type, CreateWindow, DestroyWindow, SetWindowTitle, SetWindowSize, SetWindowResize, SetSwapInterval
from ..ApiWindow import WindowShouldClose
from typing import Optional


class Window(WindowInterface):

	__ID: int
	__STATUS_EXIST: bool
	__REQUEST_DESTROY: bool

	__TITLE: str
	__SIZE: vec2
	__SIZE_OUTPUT: vec2_ptr_static
	__FRAME_RATE: int
	__RESIZE: bool

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
		self.__REQUEST_DESTROY = False

		self.__TITLE = title
		self.__SIZE = size//1
		self.__SIZE_OUTPUT = vec2_ptr_static()
		self.__FRAME_RATE = frame_rate
		self.__RESIZE = resize

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

		self.__SIZE_OUTPUT.LinkVector(self.__SIZE)
		WindowContextSystem.SetCurrentWindow(self)
		SetSwapInterval(0)
		SetWindowResize(self.__WINDOW_OBJECT,self.__RESIZE)

		self.__STATUS_EXIST = True
		WindowInitialization(self.__ID)
	
	def __del__(self) -> None:
		print("Window deleted")
	
	def Destroy(self) -> None:
		self.__REQUEST_DESTROY = True
	
	def __ImmediateDestroy(self) -> None:
		if(self.__STATUS_EXIST):
			WindowTerminate(self.__ID)
			WindowManagerSystem.RemoveWindow(self.__IWINDOW)
			WindowContextSystem.SetCurrentWindow(None)
			DestroyWindow(self.__WINDOW_OBJECT) # type: ignore
			self.__SIZE_OUTPUT.Unlink()
			self.__WINDOW_OBJECT = None
			del self.__IWINDOW
			self.__STATUS_EXIST = False
		self.__REQUEST_DESTROY = False


	def GetId(self) -> int:
		return self.__ID

	def GetStatusExist(self) -> bool:
		return self.__STATUS_EXIST

	def GetWindowObject(self) -> Optional[window_type]:
		return self.__WINDOW_OBJECT


	def GetTitle(self) -> str:
		return self.__TITLE
	def SetTitle(self, title: str) -> None:
		if(self.__STATUS_EXIST):
			self.__TITLE = title
			SetWindowTitle(self.__WINDOW_OBJECT, self.__TITLE) # type: ignore

	def GetSize(self) -> vec2_ptr_static:
		return self.__SIZE_OUTPUT
	def SetSize(self, width: int, height: int) -> None:
		if(self.__STATUS_EXIST):
			self.__SIZE.x = width
			self.__SIZE.y = height
			SetWindowSize(self.__WINDOW_OBJECT, width, height) # type: ignore

	def GetFrameRate(self) -> int:
		return self.__FRAME_RATE
	def SetFrameRate(self, frame_rate: int) -> None:
		self.__FRAME_RATE = frame_rate


	def __Tick(self, time: float) -> None:
		if(self.__REQUEST_DESTROY or WindowShouldClose(self.__WINDOW_OBJECT)):
			self.__ImmediateDestroy()
			return

		WindowUpdate(self.__ID, time)
