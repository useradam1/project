import os
CACHE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Cache')
if not os.path.exists(CACHE_DIR):
	os.makedirs(CACHE_DIR)

from pickle import load, dump
from typing import Type, TypeVar, Optional

T = TypeVar("T")

def SaveData(obj: T, path_to_file: str) -> None:
	"""
	Saves the given object to the specified file using pickle.

	Parameters:
	obj (T): The object to save.
	path_to_file (str): The path to the file where the object will be saved.
	"""
	with open(path_to_file, 'wb') as file:
		dump(obj, file)
	#print(f"Data saved to {path_to_file}")

def LoadData(path_to_file: str, expected_data_type: Type[T]) -> Optional[T]:
	"""
	Loads data from the specified file and returns it if it matches the expected type.

	Parameters:
	path_to_file (str): The path to the file to load the data from.
	expected_data_type (Type[T]): The expected type of the data to be loaded.

	Returns:
	Optional[T]: The loaded data if it matches the expected type, None otherwise.
	"""
	try:
		with open(path_to_file, 'rb') as file:
			data = load(file)
			if isinstance(data, expected_data_type):
				return data
			else:
				print(f"Loaded data type {type(data)} does not match expected type {expected_data_type}")
				return None
	except (FileNotFoundError, EOFError, Exception) as e:
		print(f"An error occurred while loading data from {path_to_file}: {e}")
		return None