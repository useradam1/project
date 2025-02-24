from engine import *

class MainScene(Scene):


	def Load(self) -> None:
		self.shader = Shader().LoadToRam({
			"path": 'FRAGMENT_SHADER'
		})
		pass







	def Start(self) -> None:
		self.MainCamera = GameObject(
			name= "MainCamera",
			tag= "Default",
			transform= Transform(
				vec3( 0 , 0 , 0 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
			),
			components= [
				
			]
		)











	def Unload(self) -> None:
		pass