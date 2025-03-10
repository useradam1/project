from engine import *
from ..settings import ASSETS_PATH



class MainScene(Scene):


	def Load(self) -> None:
		self.standart_shader = AssetsEngine.GetAssets()["rtx_shader"]

		Material(self.standart_shader, {
			"main_color": vec4(1,0,0,1),
			"albedo_map": 0,
			"roughness": 0.0,
			"metallic": False
		})

		mat = Material(self.standart_shader, {
			"main_color": vec4(0,1,0,1),
			"albedo_map": 0,
			"roughness": 0.0,
			"metallic": False
		})

		mat.Destroy()

		self.mesh = Mesh().LoadToRamFromPath(
			rf"{ASSETS_PATH}\Models\cube.obj", separate= False
		).LoadToGpu().UnloadRam()
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