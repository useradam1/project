from ..GpuResourceSystem import Shader, Mesh, Texture2D
from ..Loader import Vertex, MeshData
from ..WindowSystem import WindowContextSystem

from typing import Optional

import os
ASSETS_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Assets')
if not os.path.exists(ASSETS_PATH):
	os.makedirs(ASSETS_PATH)

from typing import TypedDict, Dict

class Assets(TypedDict):
	rtx_shader: Shader
	standart_shader: Shader
	texture_desplay_shader: Shader
	white_texture2d: Texture2D
	missing_texture2d: Texture2D
	UV_1k_texture: Texture2D
	plane_mesh: Mesh
	error_mesh: Mesh

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
			'rtx_shader': Shader().LoadToGpu({
				rf"{ASSETS_PATH}\Shaders\Rtx\shader.frag": 'FRAGMENT_SHADER',
				rf"{ASSETS_PATH}\Shaders\Rtx\shader.vert": 'VERTEX_SHADER'
			}),
			'standart_shader': Shader().LoadToGpu({
				rf"{ASSETS_PATH}\Shaders\Standart\shader.frag": 'FRAGMENT_SHADER',
				rf"{ASSETS_PATH}\Shaders\Standart\shader.vert": 'VERTEX_SHADER'
			}),
			'texture_desplay_shader': Shader().LoadToGpu({
				rf"{ASSETS_PATH}\Shaders\TextureShow\shader.frag": 'FRAGMENT_SHADER',
				rf"{ASSETS_PATH}\Shaders\TextureShow\shader.vert": 'VERTEX_SHADER'
			}),
			'white_texture2d': Texture2D().LoadToRamFromData([
				[(255,255,255,255)]
			]).LoadToGpu().UnloadRam(),
			'missing_texture2d': Texture2D().LoadToRamFromData([
				[(255,0,255,255),(0,0,0,255)],
				[(0,0,0,255),(255,0,255,255)]
			]).LoadToGpu().UnloadRam(),
			'UV_1k_texture': Texture2D().LoadToRamFromPath(rf"{ASSETS_PATH}\Images\UV_1k.jpg").LoadToGpu().UnloadRam(),
			'plane_mesh': Mesh().LoadToRamFromMeshesData([plane]).LoadToGpu().UnloadRam(),
			'error_mesh': Mesh().LoadToRamFromPath(rf"{ASSETS_PATH}\Models\ERROR.obj", False).LoadToGpu().UnloadRam(),
		}

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ASSETS.pop(window_id, None)




class AssetsEngine:
	
	@classmethod
	def GetAssets(cls) -> Assets:
		return AssetsEngineSystem.GetAssets(WindowContextSystem.GetCurrentWindowId())