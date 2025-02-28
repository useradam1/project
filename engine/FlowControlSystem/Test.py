from ProcessTask import ProcessTask
from typing import Dict
from time import sleep

def task(data: Dict) -> None:
	data["ready"] = True



if __name__ == "__main__":
	th = ProcessTask()
	th.Run()

	d = {
		"ready": False
	}
	th.Put(task, d)

	sleep(1)
	print(d)

	th.Destroy()