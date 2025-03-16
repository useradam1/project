from engine import *
from ..settings import ASSETS_PATH

from ..Assets.Scripts.CameraScript import CameraScript
from ..Assets.Scripts.RotareScript import RotareScript


class MainScene(Scene):


	def Load(self) -> None:
		self.standart_shader = AssetsEngine.GetAssets()["rtx_shader"]

		self.m1 = Material(self.standart_shader, {
			"color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	1	 , 	1	 , 	1	 ),
		})
		self.m2 = Material(self.standart_shader, {
			"color": vec4( 	0.8	 , 	1	 , 	0.8	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})



		pass







	def Start(self) -> None:

		self.Player = GameObject(
			name= "Player",
			tag= "Default",
			transform= Transform(
				vec3( 0 , 0 , 0 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
			),
			components= [
			]
		)
		self.MainCamera = GameObject(
			name= "MainCamera",
			tag= "Default",
			transform= Transform(
				vec3( 0 , 0 , 0 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
			),
			components= [
				CameraScript(),
				Camera(
					mod= "perspective",
					fov= 60,
					near= 0.1,
					far= 1000,
					left= -1,
					right= 1,
					bottom= -1,
					top= 1
				),
			]
		)
		self.MainCamera.SetParent(self.Player)



		self.struct = GameObject(
			name= "GameObject",
			tag= "Default",
			transform= Transform(
				vec3( 0 , 0 , 5 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
			),
			components= [
				#RotareScript()
			]
		)

		self.Sphere = GameObject(
			name= "GameObject",
			tag= "Default",
			transform= Transform(
				vec3( 0 , -2 , 0 ),
				vec3( 10 , 0.5 , 10 ),
				Rotation()
			),
			components= [
				Procedural(
					material= self.m2,
					type_procedural_object= "Sphere"
				)
			]
		)
		self.Sphere.SetParent(self.struct)


		self.Sphere1 = GameObject(
			name= "GameObject",
			tag= "Default",
			transform= Transform(
				vec3( 0 , 2 , 0 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
			),
			components= [
				Procedural(
					material= self.m1,
					type_procedural_object= "Sphere"
				)
			]
		)
		self.Sphere1.SetParent(self.struct)











	def Unload(self) -> None:
		pass