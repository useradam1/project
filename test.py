

def rec(value: int) -> str:
	if(value>0): return rec(value - 1)
	return "fin"

from time import time




#for _ in range(10000): rec(4)

iterations = 100

r = 0

for _ in range(iterations):
	s = time()
	for _ in range(100000):
		if(1):
			rec(0)

	e = time()

	r = e-s

r /= iterations

print(r)





r = 0

for _ in range(iterations):
	s = time()
	for _ in range(100000):
		if(True):
			rec(0)

	e = time()

	r = e-s

r /= iterations

print(r)
