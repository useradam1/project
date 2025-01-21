from OpenGL.GL import *
from typing import Type

def ClearDepthBuffer() -> None:
	glClear(GL_DEPTH_BUFFER_BIT)

def ClearColor(r: float, g: float, b: float, a: float) -> None:
	glClearColor(r,g,b,a)
	glClear(GL_COLOR_BUFFER_BIT)

def SetViewport(width:int,height:int) -> None:
	glViewport(0,0,width,height)

def RenderNOW() -> None:
	glFlush()


from numpy import uint32
def BindTexture2D_rgba8(unit: int, texture_id: uint32) -> None:
	glBindImageTexture(unit, texture_id, 0, GL_FALSE, 0, GL_READ_WRITE, GL_RGBA8)
def BindTexture2D_rgba32f(unit: int, texture_id: uint32) -> None:
	glBindImageTexture(unit, texture_id, 0, GL_FALSE, 0, GL_READ_WRITE, GL_RGBA32F)
def BindTexture3D_rgba8(unit: int, texture_id: uint32) -> None:
    glBindImageTexture(unit, texture_id, 0, GL_TRUE, 0, GL_READ_WRITE, GL_RGBA8)
def BindTexture3D_rgba32f(unit: int, texture_id: uint32) -> None:
    glBindImageTexture(unit, texture_id, 0, GL_TRUE, 0, GL_READ_WRITE, GL_RGBA32F)



class CheckDrawStatus:
	

	def __init__(self) -> None:
		self.__SYNC = None


	def GetStatusSync(self) -> bool:
		if self.__SYNC is None:
			return True
		result = glClientWaitSync(self.__SYNC, GL_SYNC_FLUSH_COMMANDS_BIT, 0)
		if result == GL_ALREADY_SIGNALED or result == GL_CONDITION_SATISFIED:
			self.ClearSync()
			return True
		elif result == GL_WAIT_FAILED:
			print("Warning: Sync wait failed.")
			self.ClearSync()  # Optional: Clear if waiting failed
			return False
		return False

	def ClearSync(self) -> None:
		if self.__SYNC is not None:
			glDeleteSync(self.__SYNC)
			self.__SYNC = None

	def SetSync(self) -> None:
		self.ClearSync()
		self.__SYNC = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0)