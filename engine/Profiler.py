import matplotlib.pyplot as plt
from typing import Dict


class Profiler:
	__VALUES_PROFILER: Dict[str, float] = {}

	@classmethod
	def AppendData(cls, data_name: str, data_value: float) -> None:
		cls.__VALUES_PROFILER[data_name] = data_value

	@classmethod
	def RemoveData(cls, data_name: str, data_value: float) -> None:
		cls.__VALUES_PROFILER[data_name] = data_value

	@classmethod
	def ShowDiagram(cls) -> None:
		plt.clf()  # Очищаем текущий график
		names = list(cls.__VALUES_PROFILER.keys())
		values = list(cls.__VALUES_PROFILER.values())

		# Нормализуем значения для градиента (от 0 до 1)
		max_value = max(values, default=1)  # Защита от деления на 0
		normalized_values = [v / max_value for v in values]

		# Генерация цветов от зелёного к красному
		colors = [(nv, 1 - nv, 0) for nv in normalized_values]

		bars = plt.bar(names, values, color=colors)

		for bar, value in zip(bars, values):
			plt.text(
				x=bar.get_x() + bar.get_width() / 2,
				y=value*0.05,
				s=f"{value:.4f}",
				ha='center', va='top'
			)


	@classmethod
	def ProfilerOn(cls) -> None:
		plt.ion()
		#plt.figure(figsize=(10, 6))  # Размеры графика в дюймах (ширина, высота)
		plt.axis('off')
		plt.subplots_adjust(left=0, right=1, top=1, bottom=0)
	@classmethod
	def ProfilerOff(cls) -> None:
		plt.ioff()



