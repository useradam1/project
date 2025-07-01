from .LoadCache import LoadData, SaveData, CACHE_DIR

import os


from numpy import ndarray, dtype, uint8, float32, array, flipud, zeros
from PIL import Image
from typing import Tuple, List, Union




class ImageData2D:
	__DATA: ndarray[Tuple[int,int], dtype[uint8]]
	__WIDTH: int
	__HEIGHT: int

	def __init__(self) -> None:
		self.__DATA = zeros((1, 1, 4), dtype=uint8)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]

	def SetNpData(self, data: ndarray[Tuple[int,int], dtype[uint8]]) -> 'ImageData2D':
		self.__DATA = data
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		return self
	
	def SetData(self, data: List[List[Tuple[float,float,float,float]]]) -> 'ImageData2D':
		self.__DATA = array(data, dtype=uint8)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		return self

	def SetEmptyData(self, width: int, height: int) -> 'ImageData2D':
		self.__DATA = zeros((height, width, 4), dtype=uint8)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		return self

	def GetData(self) -> ndarray[Tuple[int,int], dtype[uint8]]: return self.__DATA
	def GetWidth(self) -> int: return self.__WIDTH
	def GetHeight(self) -> int: return self.__HEIGHT

class ImageData2DFloat:
	__DATA: ndarray[Tuple[int,int], dtype[float32]]
	__WIDTH: int
	__HEIGHT: int

	def __init__(self) -> None:
		self.__DATA = zeros((1, 1, 4), dtype=float32)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]

	def SetNpData(self, data: ndarray[Tuple[int,int], dtype[float32]]) -> 'ImageData2DFloat':
		self.__DATA = data
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		return self
	
	def SetData(self, data: List[List[Tuple[float,float,float,float]]]) -> 'ImageData2DFloat':
		self.__DATA = array(data, dtype=float32)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		return self

	def SetEmptyData(self, width: int, height: int) -> 'ImageData2DFloat':
		self.__DATA = zeros((height, width, 4), dtype=float32)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		return self

	def GetData(self) -> ndarray[Tuple[int,int], dtype[float32]]: return self.__DATA
	def GetWidth(self) -> int: return self.__WIDTH
	def GetHeight(self) -> int: return self.__HEIGHT




class ImageData3D:
	__DATA: ndarray[Tuple[int,int,int], dtype[uint8]]
	__WIDTH: int
	__HEIGHT: int
	__DEPTH: int

	def __init__(self) -> None:
		self.__DATA = zeros((1, 1, 1, 4), dtype=uint8)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		self.__DEPTH = self.__DATA.shape[2]

	def SetNpData(self, data: ndarray[Tuple[int,int,int], dtype[uint8]]) -> 'ImageData3D':
		self.__DATA = data
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		self.__DEPTH = self.__DATA.shape[2]
		return self
	
	def SetData(self, data: List[List[List[Tuple[float,float,float,float]]]]) -> 'ImageData3D':
		self.__DATA = array(data, dtype=uint8)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		self.__DEPTH = self.__DATA.shape[2]
		return self

	def SetEmptyData(self, width: int, height: int, depth: int) -> 'ImageData3D':
		self.__DATA = zeros((height, width, depth, 4), dtype=uint8)
		self.__WIDTH = self.__DATA.shape[0]
		self.__HEIGHT = self.__DATA.shape[1]
		self.__DEPTH = self.__DATA.shape[2]
		return self

	def GetData(self) -> ndarray[Tuple[int,int,int], dtype[uint8]]: return self.__DATA
	def GetWidth(self) -> int: return self.__WIDTH
	def GetHeight(self) -> int: return self.__HEIGHT
	def GetDepth(self) -> int: return self.__DEPTH

class Image2D:
	data: ndarray
	def __init__(self, data: ndarray) -> None:
		self.data = data

def ReadImage2D(path_to_image: str, image_data_2d: Union[ImageData2D, ImageData2DFloat]) -> str:

	error: str = ""


	file_name: str = os.path.splitext(os.path.basename(path_to_image))[0] + ".IMD"
	path_to_cache_file = os.path.join(CACHE_DIR, file_name)



	if(os.path.exists(path_to_cache_file)):

		file1_mtime = os.path.getmtime(path_to_image)
		file2_mtime = os.path.getmtime(path_to_cache_file)

		if(file1_mtime < file2_mtime):
			load = LoadData(path_to_cache_file, Image2D)
			if(load):
				image_data_2d.SetNpData(load.data)
				return error
		del file1_mtime, file2_mtime



	try:
		data: ndarray = zeros((1, 1, 4), dtype=uint8)
		with Image.open(path_to_image).convert('RGBA') as img:
			data = flipud(array(img, dtype=uint8))
		SaveData(Image2D(data), path_to_cache_file)
		image_data_2d.SetNpData(data)
	except Exception as err:
		error = f"{err}"

	return error