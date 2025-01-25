from engine import *
import sys


def update1() -> None: ...
	#print("update1")

def update2() -> None: ...
	#print("update2")


def main() -> int:
	Window(
		title="3DEngine1",
		size=vec2(800, 600),
		frame_rate=0,
		resize=True,
	)
	Update(update1)

	


	StartEngine()
	return 0


if __name__ == "__main__":
	output = main()
	sys.exit(output)