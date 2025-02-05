
class FinalMeta(type):
	def __new__(cls, name, bases, dct):
		for base in bases:
			for attr in dct:
				if attr in base.__dict__:
					if isinstance(base.__dict__[attr], Protected):
						raise TypeError(f"Cannot override final method '{attr}' in class '{base.__name__}'")
		return super().__new__(cls, name, bases, dct)

class Protected:
	def __init__(self, func):
		self.func = func

	def __get__(self, instance, owner):
		return self.func.__get__(instance, owner)