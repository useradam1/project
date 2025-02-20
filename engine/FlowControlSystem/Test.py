from ThreadTask import ThreadTask
from ProcessTask import ProcessTask
from time import sleep

engine = True
th = ThreadTask()

def calc(num: int) -> None:
	#sleep(1)
	print(f"hello {num}")

def Loop():
	for i in range(2):
		print(i)
		#sleep(1)
		th.Put(calc, i+1)
		if(not engine): break

def main() -> None:
	th.Run()
	Loop()
	th.Destroy()
	sleep(1)

if __name__ == '__main__':
	main()