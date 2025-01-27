from engine import *
import sys


def update1() -> None:
	w = WindowContext.GetCurrentWindow()
	if(w is None): return
	center = Mouse.GetPosition() - w.GetSize()*0.5
	nor = vec2.GetNormalized(center)
	posw = w.GetPosition()
	p = posw + nor*2
	print(center, nor, posw, p)
	w.SetPosition(int(p.x),int(p.y))
	pass

def update2() -> None: ...
	#print("update2")


def main() -> int:
	Window(
		title="3DEngine1",
		size=vec2(500, 300),
		frame_rate=60,
		resize=False,
	)
	#for _ in range(1000): Update(update1)
	Update(update1)
	# Window(
	# 	title="3DEngine2",
	# 	size=vec2(500, 300),
	# 	frame_rate=0,
	# 	resize=True,
	# )
	# Update(update2)



	StartEngine()
	return 0


if __name__ == "__main__":
	output = main()
	sys.exit(output)