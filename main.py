from engine import *
from Project import *
import sys




def main() -> int:
	ProjectInit()

	Window(
		title="3DEngine1",
		size=vec2(500, 300),
		frame_rate=0,
		resize=False,
	)
	SceneManager.RunScene("MainScene")

	Window(
		title="3DEngine2",
		size=vec2(500, 300),
		frame_rate=0,
		resize=False,
	)
	SceneManager.RunScene("MainScene")

	StartEngine()
	return 0


if __name__ == "__main__":
	from engine.FlowControlSystem.FlowControlSystem import FlowControlSystem
	FlowControlSystem.Initialization()
	out = main()
	FlowControlSystem.Terminate()
	sys.exit(out)