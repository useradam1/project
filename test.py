import matplotlib.pyplot as plt
import numpy as np

# Данные для графика
categories = ['A', 'B', 'C', 'D', 'E']
values = [5, 7, 3, 8, 6]

# Создание столбчатой диаграммы
fig, ax = plt.subplots()
bars = ax.bar(categories, values, color='skyblue', edgecolor='black')

# Добавление значений внизу каждого столба
for bar, value in zip(bars, values):
    ax.text(bar.get_x() + bar.get_width() / 2, 0.5, str(value), ha='center', va='top', fontsize=10)

# Настройки отображения
ax.set_ylim(0, max(values) + 2)
ax.set_title('Пример столбчатой диаграммы', fontsize=14)
ax.set_ylabel('Значения', fontsize=12)
ax.set_xlabel('Категории', fontsize=12)
ax.grid(axis='y', linestyle='--', alpha=0.7)

plt.tight_layout()
plt.show()
