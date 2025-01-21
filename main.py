from engine import *
import sys



def main() -> int:
	Window(
		title="3DEngine1",
		size=vec2(800, 600),
		frame_rate=60,
		resize=True,
	)
	Window(
		title="3DEngine2",
		size=vec2(800, 600),
		frame_rate=60,
		resize=True,
	)

	StartEngine()
	return 0


if __name__ == "__main__":
	output = main()
	sys.exit(output)