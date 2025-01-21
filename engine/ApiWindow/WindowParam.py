import glfw
import ctypes
from typing import Type, Optional
from glfw.GLFW import glfwGetTime

window_type = Type[ctypes.POINTER(glfw._GLFWwindow)]



def ApiWindowInitialization() -> bool:
	if(glfw.init()):
		glfw.set_error_callback(None)
		glfw.window_hint(glfw.DOUBLEBUFFER, glfw.FALSE)
		#glfw.window_hint(glfw.CONTEXT_VERSION_MAJOR, 3)  # Версия OpenGL 3.x
		#glfw.window_hint(glfw.CONTEXT_VERSION_MINOR, 3)
		#glfw.window_hint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
		return True
	return False

def ApiWindowTerminate() -> None:
	glfw.terminate()


def CreateWindow(width: int, height: int, title: str) -> Optional[window_type]:
	return glfw.create_window(width, height, title, None, None)

def DestroyWindow(window: window_type) -> None:
	glfw.destroy_window(window)

def WindowShouldClose(window: Optional[window_type]) -> bool:
	if(window is not None): return bool(glfw.window_should_close(window))
	return True

def WindowPollEvents() -> None:
	glfw.poll_events()

def WindowSwapBuffers(window: window_type) -> None:
	glfw.swap_buffers(window)

def SetCurrentContextWindow(window: Optional[window_type]) -> None:
	glfw.make_context_current(window)

def SetSwapInterval(interval: int) -> None:
	glfw.swap_interval(interval)

def GetCurrentTime() -> float:
	return glfwGetTime()