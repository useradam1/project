from setuptools import setup, Extension
from Cython.Build import cythonize

import numpy as np

FILENAME = 'vecf'

try:
	ext_modules = [
		Extension(
			FILENAME,
			[f"{FILENAME}.pyx"],
			include_dirs=[np.get_include()]  # Включаем путь к заголовочным файлам NumPy
		)
	]

	setup(
		ext_modules=cythonize(ext_modules),
		script_args=["build_ext", "--inplace"],
	)
except Exception as err:
	print(err)
input()