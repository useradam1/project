import glfw
import glfw.GLFW as GLFW_CONSTANTS
import ctypes
from typing import Type, Optional, Callable, Tuple, Literal, Dict

window_type = Type[ctypes.POINTER(glfw._GLFWwindow)]



def GetMousePosition(window: window_type) -> Tuple[float,float]:
	return glfw.get_cursor_pos(window)

def SetMousePosition(window: window_type, x: int, y: int) -> None:
	glfw.set_cursor_pos(window, x, y)



def SetCallbackMousePosition(window: window_type, method:Optional[Callable[[window_type,int,int],None]]) -> None:
	glfw.set_cursor_pos_callback(window, method)

def SetCallbackMouseScroll(window: window_type, method:Optional[Callable[[window_type,float,float],None]]) -> None:
	glfw.set_scroll_callback(window, method)

def SetCallbackMouseButton(window: window_type, method:Optional[Callable[[window_type,int,int,int],None]]) -> None:
	GLFW_CONSTANTS.glfwSetMouseButtonCallback(window, method)

mouse_status_list = Literal[
	'NORMAL',
	'CAPTURED',
	'DISABLED',
	'HIDDEN',
	'UNAVAILABLE'
]

def SetWindowMouseStatus(window: window_type, status: mouse_status_list) -> None:
	glfw.set_input_mode(window, glfw.CURSOR, eval("glfw.CURSOR_" + status))



mouse_button = Literal[
    'LEFT',
    'RIGHT',
    'MIDDLE',
    'BACKWARD',
    'FORWARD'
]

mouse_button_map: Dict[int, mouse_button] = {
    glfw.MOUSE_BUTTON_LEFT: "LEFT",
    glfw.MOUSE_BUTTON_RIGHT: "RIGHT",
    glfw.MOUSE_BUTTON_MIDDLE: "MIDDLE",
    glfw.MOUSE_BUTTON_4: "BACKWARD",
    glfw.MOUSE_BUTTON_5: "FORWARD",
}

def GetWindowMouseButton(window, button: mouse_button) -> bool:
	return glfw.get_mouse_button(window, eval("glfw.MOUSE_BUTTON_" + button)) == glfw.PRESS