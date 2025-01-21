from engine import *
import sys



def main() -> int:
	window = Window(
		title="3DEngine",
		size=vec2(800, 600),
		frame_rate=60,
		resize=True,
	)

	StartEngine()
	return 0


if __name__ == "__main__":
	output = main()
	sys.exit(output)