from setuptools import setup, Extension
from Cython.Build import cythonize
import numpy as np

FILENAME = 'vecf'

try:
	ext_modules = [
		Extension(
			FILENAME,
			[f"{FILENAME}.pyx"],
			include_dirs=[np.get_include()],  # Включаем путь к заголовочным файлам NumPy
			extra_compile_args=["/O2", "/fp:fast", "/openmp", "/arch:AVX"],  # Оптимизации для MSVC
			extra_link_args=["/openmp"],  # Поддержка OpenMP
		)
	]

	setup(
		ext_modules=cythonize(
			ext_modules,
			compiler_directives={
				"language_level": "3",  # Устанавливаем Python 3
				"boundscheck": False,  # Отключаем проверку границ массива
				"wraparound": False,  # Отключаем негативные индексы
				"cdivision": True,  # Ускоряем целочисленное деление
			},
			language_level=3
		),
		script_args=["build_ext", "--inplace"],
	)
except Exception as err:
	print(err)
input()
