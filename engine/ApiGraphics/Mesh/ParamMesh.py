from OpenGL import *
from OpenGL.GL import *
from numpy import uint32

class CullFaceModeMesh:

	def drawModeCW(self):
		glFrontFace(GL_CW)
	def drawModeCCW(self):
		glFrontFace(GL_CCW)
	def cullFaceModeEnabaled(self):
		glEnable(GL_CULL_FACE)
	def cullFaceModeDisabled(self):
		glDisable(GL_CULL_FACE)
	def frontAndBackModeDraw(self):
		glDisable(GL_CULL_FACE)
	def frontModeDraw(self):
		glCullFace(GL_FRONT)
	def backModeDraw(self):
		glCullFace(GL_BACK)

class BlendModeMesh:

	def blendModeEnabaled(self):
		glEnable(GL_BLEND)
		#glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
		glBlendFuncSeparate(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA, GL_ONE, GL_ONE_MINUS_SRC_ALPHA)
		#glBlendFuncSeparate(GL_ONE, GL_ZERO, GL_ONE, GL_ZERO)
		#glBlendFuncSeparate(GL_ONE, GL_ONE, GL_ONE, GL_ONE)
	def blendModeDisabled(self):
		glDisable(GL_BLEND)

class DepthTestModeMesh:

	def depthFunctionLess(self):
		'''<'''
		glDepthFunc(GL_LESS)

	def depthFunctionLEqual(self):
		'''<='''
		glDepthFunc(GL_LEQUAL)

	def depthFunctionGreater(self):
		'''>'''
		glDepthFunc(GL_GREATER)

	def depthFunctionGEqual(self):
		'''>='''
		glDepthFunc(GL_GEQUAL)

	def depthMaskEnabled(self):
		'''Включить запись в буфер глубины'''
		glEnable(GL_DEPTH_TEST)
		glDepthMask(GL_TRUE)

	def depthMaskDisabled(self):
		'''Отключить запись в буфер глубины'''
		glDepthMask(GL_FALSE)
		glDisable(GL_DEPTH_TEST)

	def clearDepthBuffer(self, value: float):
		'''Очистить буфер глубины заданным значением value от 0.0 (ближе к камере), до 1.0 (дальше от камеры)'''
		glClearDepth(value)
		#glClear(GL_DEPTH_BUFFER_BIT)