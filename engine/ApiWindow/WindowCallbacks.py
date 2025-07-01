import glfw
import ctypes
from typing import Type, Optional, Callable

window_type = Type[ctypes.POINTER(glfw._GLFWwindow)]



def SetCallbackWindowPosition(window: window_type, method:Optional[Callable[[window_type,int,int],None]]) -> None:
	glfw.set_window_pos_callback(window, method)

def SetCallbackWindowSize(window: window_type, method:Optional[Callable[[window_type,int,int],None]]) -> None:
	glfw.set_window_size_callback(window, method)

def SetCallbackWindowFocus(window: window_type, method:Optional[Callable[[window_type,int],None]]) -> None:
	glfw.set_window_focus_callback(window, method)