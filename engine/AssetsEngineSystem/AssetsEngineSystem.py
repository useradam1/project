from ..GpuResourceSystem import Shader, Mesh
from ..Loader import Vertex, MeshData
from ..WindowSystem import WindowContextSystem

from typing import Optional

import os
ASSETS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Assets')
if not os.path.exists(ASSETS_PATH):
	os.makedirs(ASSETS_PATH)

from typing import TypedDict, Dict

class Assets(TypedDict):
	standart_shader: Shader
	plane_mdl: Mesh
	error_mdl: Mesh

class AssetsEngineSystem:

	__ASSETS: Dict[int, Assets] = {}

	@classmethod
	def GetAssets(cls, window_id: int) -> Assets:
		return cls.__ASSETS[window_id]

	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		plane = MeshData()
		plane.AppendEdge([
			Vertex(
				point= ( -1.0 , 1.0 , 0.0 ),
				normal= ( 0.0 , 0.0 , -1.0 ),
				uv= ( 0.0 , 1.0 )),
			Vertex(
				point= ( 1.0 , 1.0 , 0.0 ),
				normal= ( 0.0 , 0.0 , -1.0 ),
				uv= ( 1.0 , 1.0 )),
			Vertex(
				point= ( 1.0 , -1.0 , 0.0 ),
				normal= ( 0.0 , 0.0 , -1.0 ),
				uv= ( 1.0 , 0.0 )),
			Vertex(
				point= ( -1.0 , -1.0 , 0.0 ),
				normal= ( 0.0 , 0.0 , -1.0 ),
				uv= ( 0.0 , 0.0 ))
		])
		plane.DecodeData()
		cls.__ASSETS[window_id] = {
			'standart_shader': Shader().LoadToGpu({
				rf"{ASSETS_PATH}\Shaders\Standart\shader.frag": 'FRAGMENT_SHADER',
				rf"{ASSETS_PATH}\Shaders\Standart\shader.vert": 'VERTEX_SHADER'
			}),
			'plane_mdl': Mesh().LoadToRamFromMeshData([plane]).LoadToGpu().UnloadRam(),
			'error_mdl': Mesh().LoadToRamFromPath(rf"{ASSETS_PATH}\Models\ERROR.obj", False).LoadToGpu().UnloadRam(),
		}

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ASSETS.pop(window_id, None)




class AssetsEngine:
	
	@classmethod
	def GetAssets(cls) -> Assets:
		return AssetsEngineSystem.GetAssets(WindowContextSystem.GetCurrentWindowId())