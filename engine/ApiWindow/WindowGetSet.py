import glfw
import ctypes
from typing import Type, Tuple

window_type = Type[ctypes.POINTER(glfw._GLFWwindow)]



#def SetFullScrean(window: window_type, value: bool) -> None:



def GetWindowSize(window: window_type) -> Tuple[int,int]:
	return glfw.get_window_size(window)

def SetWindowSize(window: window_type, width:int, height:int) -> None:
	glfw.set_window_size(window, width, height)



def GetWindowPosition(window: window_type) -> Tuple[int,int]:
	return glfw.get_window_pos(window)

def SetWindowPosition(window: window_type, x:int, y:int) -> None:
	glfw.set_window_pos(window, x, y)



def SetWindowTitle(window: window_type, title: str) -> None:
	glfw.set_window_title(window, title)

def SetWindowResize(window: window_type, resizible: bool) -> None:
	glfw.set_window_attrib(window, glfw.RESIZABLE, resizible)

def GetWindowFocused(window: window_type) -> bool:
	return bool(glfw.get_window_attrib(window, glfw.FOCUSED))