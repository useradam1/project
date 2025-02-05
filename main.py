from engine import *
from Project import *
import sys


def update1() -> None:
	pass

def update2() -> None:
	pass


def main() -> int:
	Window(
		title="3DEngine1",
		size=vec2(500, 300),
		frame_rate=0,
		resize=False,
	)
	#for _ in range(1000): Update(update1)
	Update(update2)
	GameObject(
		name= "GameObject1",
		tag= "0",
		transform= Transform(
			vec3( 0 , 0 , 0 ),
			vec3( 1 , 1 , 1 ),
			Rotation()
		),
		components= [
			Component()
		]
	)
	#a.Destroy()
	Window(
		title="3DEngine2",
		size=vec2(500, 300),
		frame_rate=0,
		resize=True,
	)
	GameObject(
		name= "GameObject2",
		tag= "0",
		transform= Transform(
			vec3( 0 , 0 , 0 ),
			vec3( 1 , 1 , 1 ),
			Rotation()
		),
		components= [
			Component()
		]
	)
	# u.Destroy()
	# del u
	# Update(update2)



	StartEngine()
	return 0


if __name__ == "__main__": sys.exit(main())