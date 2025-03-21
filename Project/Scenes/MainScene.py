from engine import *
from ..settings import ASSETS_PATH

from ..Assets.Scripts.CameraScript import CameraScript
from ..Assets.Scripts.RotareScript import RotareScript


class MainScene(Scene):

	def __MaterialsForRoom(self) -> None:
		self.flor = Material(self.standart_shader, {
			"diffuse_color": vec4( 	0.75 , 	0.75 , 	0.5	 , 	1	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
			"smoothness": vec3( 	0	 , 	0	 , 	0	 ),
			"density": 1.0
		})
		self.cell = Material(self.standart_shader, {
			"diffuse_color": vec4( 	0.75	 , 	0.75	 , 	0.75	 , 	1	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
			"smoothness": vec3( 	0	 , 	0	 , 	0	 ),
			"density": 1.0
		})
		self.left = Material(self.standart_shader, {
			"diffuse_color": vec4( 	0.25 , 	1	 , 	0.25	 , 	1	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
			"smoothness": vec3( 	0	 , 	0	 , 	0	 ),
			"density": 1.0
		})
		self.right = Material(self.standart_shader, {
			"diffuse_color": vec4( 	1	 , 	0.25	 , 	0.25	 , 	1	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
			"smoothness": vec3( 	0	 , 	0	 , 	0	 ),
			"density": 1.0
		})
		self.forward = Material(self.standart_shader, {
			"diffuse_color": vec4( 	0.25	 , 	0.25	 , 	1	 , 	1	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
			"smoothness": vec3( 	0	 , 	0	 , 	0	 ),
			"density": 1.0
		})
		self.back = Material(self.standart_shader, {
			"diffuse_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
			"smoothness": vec3( 	0	 , 	0	 , 	0	 ),
			"density": 1.0
		})


	def Load(self) -> None:

		self.mesh = Mesh().LoadBVH()

		self.standart_shader = AssetsEngine.GetAssets()["rtx_shader"]

		self.__MaterialsForRoom()

		self.light_created_material = Material(self.standart_shader, {
			"diffuse_color": vec4( 	1	 , 	0.1	 , 	0.1	 , 	1	 ),
			"specular_color": vec4( 	0.1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0.5	 , 	0.75	 , 	1	 )*0,
			"smoothness": vec3( 	0	 , 	1	 , 	0.15	 ),
			"density": 2
		})
		self.light_material = Material(self.standart_shader, {
			"diffuse_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	1	 , 	1	 , 	1	 )*10,
			"smoothness": vec3( 	0	 , 	0	 , 	0	 ),
			"density": 1.0
		})
		self.wall_material = Material(self.standart_shader, {
			"diffuse_color": vec4( 	1	 , 	1	 , 	1	 , 	0	 ),
			"specular_color": vec4( 	1	 , 	1	 , 	1	 , 	1	 ),
			"emmision": vec3( 	0	 , 	0	 , 	0	 ),
			"smoothness": vec3( 	1	 , 	0	 , 	0	 ),
			"density": 2.0
		})



		pass







	def Start(self) -> None:

		GameObject(
			name= "Player",
			tag= "Default",
			transform= Transform(
				vec3( 8 , -5 , -8 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
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
						Rotation()
					),
					components= [
						CameraScript(
							light_material= self.light_created_material
						),
						Camera(
							mod= "perspective",
							fov= 100,
							near= 0.1,
							far= 1000,
							left= -1,
							right= 1,
							bottom= -1,
							top= 1,
							max_bounce_count= 10,
							num_samples= 5,
							iso= 1
						),
					],
					childrens=[
						# GameObject(
						# 	name= "MainCamera",
						# 	tag= "Default",
						# 	transform= Transform(
						# 		vec3( -0.5 , 0 , 0 ),
						# 		vec3( 1 , 1 , 1 ),
						# 		Rotation()
						# 	),
						# 	components= [
						# 		Camera(
						# 			mod= "perspective",
						# 			fov= 100,
						# 			near= 0.1,
						# 			far= 1000,
						# 			left= -1,
						# 			right= 1,
						# 			bottom= -1,
						# 			top= 1,
						# 			max_bounce_count= 10,
						# 			num_samples= 5,
						# 			exposure= 5
						# 		),
						# 	],
						# 	childrens=[]
						# )
					]
				),
			]
		)


		GameObject(
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
				vec3( 3 , 0.1 , 3 ),
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
				vec3( 0 , -7 , 4 ),
				vec3( 5 , 3 , 0.1 ),
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



		GameObject(
			name= "light",
			tag= "Default",
			transform= Transform(
				vec3( 0 , -5 , 0 ),
				vec3( 1 , 1 , 1 ),
				Rotation()
			),
			components= [
				#RotareScript(),
				ProceduralMesh(
					material= self.light_material
				)
			],
			childrens=[]
		)





	def Unload(self) -> None:
		pass