from engine import *
from ..settings import ASSETS_PATH

from ..Assets.Scripts.CameraScript import CameraScript
from ..Assets.Scripts.RotareScript import RotareScript


class MainScene(Scene):

	def __MaterialsForRoom(self) -> None:
		self.flor = Material(self.standart_shader, {
			"color": vec4( 	0.75 , 	0.75 , 	0.5	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})
		self.cell = Material(self.standart_shader, {
			"color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})
		self.left = Material(self.standart_shader, {
			"color": vec4( 	0.5 , 	0.5	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})
		self.right = Material(self.standart_shader, {
			"color": vec4( 	1	 , 	0.5	 , 	0.5	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})
		self.forward = Material(self.standart_shader, {
			"color": vec4( 	0.5	 , 	1	 , 	0.5	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})
		self.back = Material(self.standart_shader, {
			"color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})


	def Load(self) -> None:
		self.standart_shader = AssetsEngine.GetAssets()["rtx_shader"]

		self.__MaterialsForRoom()

		self.light_material = Material(self.standart_shader, {
			"color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	1	 , 	1	 , 	1	 ),
		})
		self.wall_material = Material(self.standart_shader, {
			"color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
		})



		pass







	def Start(self) -> None:

		self.Player = GameObject(
			name= "Player",
			tag= "Default",
			transform= Transform(
				vec3( 9 , 5 , -9 ),
				vec3( 1 , 1 , 1 ),
				Rotation().Ly(45)
			),
			components= [
			],
			childrens=[
				GameObject(
					name= "MainCamera",
					tag= "Default",
					transform= Transform(
						vec3( 0 , 0 , 0 ),
						vec3( 1 , 1 , 1 ),
						Rotation().Lx(-24)
					),
					components= [
						CameraScript(
							light_material= self.light_material
						),
						Camera(
							mod= "perspective",
							fov= 100,
							near= 0.1,
							far= 1000,
							left= -1,
							right= 1,
							bottom= -1,
							top= 1
						),
					],
					childrens=[]
				)
			]
		)


		self.room = GameObject(
			name= "room",
			tag= "Default",
			transform= Transform(
				vec3( 0 , 0 , 0 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
			),
			components= [
				#RotareScript()
			],
			childrens=[
				GameObject(
					name= "flor",
					tag= "Default",
					transform= Transform(
						vec3( 0 , -10 , 0 ),
						vec3( 15 , 0.5 , 15 ),
						Rotation()
					),
					components= [
						Procedural(
							material= self.flor,
							type_procedural_object= "Sphere"
						)
					],
					childrens=[]
				),
				GameObject(
					name= "cell",
					tag= "Default",
					transform= Transform(
						vec3( 0 , 10 , 0 ),
						vec3( 15 , 0.5 , 15 ),
						Rotation()
					),
					components= [
						Procedural(
							material= self.cell,
							type_procedural_object= "Sphere"
						)
					],
					childrens=[]
				),
				GameObject(
					name= "forward",
					tag= "Default",
					transform= Transform(
						vec3( 0 , 0 , 10 ),
						vec3( 15 , 15 , 0.5 ),
						Rotation()
					),
					components= [
						Procedural(
							material= self.forward,
							type_procedural_object= "Sphere"
						)
					],
					childrens=[]
				),
				GameObject(
					name= "back",
					tag= "Default",
					transform= Transform(
						vec3( 0 , 0 , -10 ),
						vec3( 15 , 15 , 0.5 ),
						Rotation()
					),
					components= [
						Procedural(
							material= self.back,
							type_procedural_object= "Sphere"
						)
					],
					childrens=[]
				),
				GameObject(
					name= "left",
					tag= "Default",
					transform= Transform(
						vec3( -10 , 0 , 0 ),
						vec3( 0.5 , 15 , 15 ),
						Rotation()
					),
					components= [
						Procedural(
							material= self.left,
							type_procedural_object= "Sphere"
						)
					],
					childrens=[]
				),
				GameObject(
					name= "right",
					tag= "Default",
					transform= Transform(
						vec3( 10 , 0 , 0 ),
						vec3( 0.5 , 15 , 15 ),
						Rotation()
					),
					components= [
						Procedural(
							material= self.right,
							type_procedural_object= "Sphere"
						)
					],
					childrens=[]
				),
			]
		)



		GameObject(
			name= "light",
			tag= "Default",
			transform= Transform(
				vec3( 0 , 9 , 0 ),
				vec3( 2 , 1 , 2 ),
				Rotation()
			),
			components= [
				Procedural(
					material= self.light_material,
					type_procedural_object= "Cube"
				)
			],
			childrens=[]
		)

		GameObject(
			name= "wall",
			tag= "Default",
			transform= Transform(
				vec3( 0 , -9 , 5 ),
				vec3( 5 , 5 , 1 ),
				Rotation()
			),
			components= [
				Procedural(
					material= self.wall_material,
					type_procedural_object= "Cube"
				)
			],
			childrens=[]
		)








	def Unload(self) -> None:
		pass