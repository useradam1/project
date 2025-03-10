from ..ApiGraphics import RenderNOW, SetViewport, ClearColor, CheckDrawStatus, ClearDepthBuffer
from ..WindowSystem import WindowContextSystem
from ..GpuResourceSystem import Mesh, Shader, Texture2D, FrameBuffer, MaterialControllerSystem
from ..AssetsEngineSystem import AssetsEngineSystem
from ..Math import *
from typing import Dict



class RenderingPipeline:

	__DRAW_STATUS: Dict[int, CheckDrawStatus] = {}

	__RTX_SHADER: Dict[int, Shader] = {}
	__TEXTURE_DESPLAY_SHADER: Dict[int, Shader] = {}
	__PLANE_MESH: Dict[int, Mesh] = {}

	__FRAME_BUFFER_TEXTURE: Dict[int, Texture2D] = {}
	__FRAME_BUFFER: Dict[int, FrameBuffer] = {}


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__DRAW_STATUS[window_id] = CheckDrawStatus()
	
		cls.__RTX_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['rtx_shader']
		cls.__TEXTURE_DESPLAY_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['texture_desplay_shader']
		cls.__PLANE_MESH[window_id] = AssetsEngineSystem.GetAssets(window_id)['plane_mesh']

		cls.__FRAME_BUFFER_TEXTURE[window_id] = Texture2D()
		cls.__FRAME_BUFFER[window_id] = FrameBuffer().SetTextures([cls.__FRAME_BUFFER_TEXTURE[window_id]])

		def CallbackSize(width: int, height: int) -> None:
			SetViewport(width, height)
			cls.__FRAME_BUFFER_TEXTURE[window_id].SetEmptyData(width, height).LoadToGpu()
			cls.__FRAME_BUFFER[window_id].UpdateSize(width, height)

		window = WindowContextSystem.GetCurrentWindow()
		window.AppendCallbackSize(CallbackSize) # type: ignore
		CallbackSize(int(window.GetSize().x), int(window.GetSize().y)) # type: ignore


	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__DRAW_STATUS.pop(window_id, None)

		cls.__RTX_SHADER.pop(window_id, None)
		cls.__TEXTURE_DESPLAY_SHADER.pop(window_id, None)
		cls.__PLANE_MESH.pop(window_id, None)

		cls.__FRAME_BUFFER[window_id].Destroy()
		cls.__FRAME_BUFFER_TEXTURE[window_id].Destroy()





	@classmethod
	def RenderScene(cls, window_id: int) -> None:

		drawstatus = cls.__DRAW_STATUS[window_id]

		if(not drawstatus.GetStatusSync()): return

		MaterialControllerSystem.CheckQueueChange(window_id)

		fb = cls.__FRAME_BUFFER[window_id]
		plane = cls.__PLANE_MESH[window_id]
		fb_texture = cls.__FRAME_BUFFER_TEXTURE[window_id]
		ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
		ClearDepthBuffer()



		shader = cls.__TEXTURE_DESPLAY_SHADER[window_id].StartUseProgram().GetShaderData()
		shader.SetUniformTexture2D_one("MainTexture", fb_texture.GetObject())
		#shader.SetUniformTexture2D_one("MainTexture", AssetsEngineSystem.GetAssets(window_id)['UV_1k_texture'].GetObject())
		shader.ClearTextureId()

		plane.DrawMesh()



		fb.Bind()

		shader = cls.__RTX_SHADER[window_id].StartUseProgram().GetShaderData()
		ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
		ClearDepthBuffer()
		#fb_texture.FillWithColor(( 0.0 , 0.0 , 0.0 , 0.0 ))

		plane.DrawMesh()
		fb.Unbind()



		drawstatus.SetSync()
		RenderNOW()