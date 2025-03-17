from ..ApiGraphics import RenderNOW, SetViewport, ClearColor, CheckDrawStatus, ClearDepthBuffer
from ..WindowSystem import WindowContextSystem
from ..GpuResourceSystem import Mesh, Shader, Texture2D, FrameBuffer, MaterialControllerSystem
from ..AssetsEngineSystem import AssetsEngineSystem

from typing import Dict, Tuple, Callable

from ..ApiWindow import GetCurrentTime
from ..ApiGraphics import GetVersion
from ..Profiler import Profiler

class RenderingPipeline:

	__FRAME_ID: Dict[int, int] = {}
	__DRAW_STATUS: Dict[int, CheckDrawStatus] = {}

	__PLANE_MESH: Dict[int, Mesh] = {}
	__FINAL_TEXTURE: Dict[int, Texture2D] = {}
	__TEXTURE_DISPLAY_SHADER: Dict[int, Shader] = {}


	__RTX_SHADER: Dict[int, Shader] = {}
	__FRAME_BUFFER_RTX: Dict[int, FrameBuffer] = {}


	__UPDATE_TIME: float = 0.0


	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__FRAME_ID[window_id] = 0
		cls.__DRAW_STATUS[window_id] = CheckDrawStatus()

		cls.__PLANE_MESH[window_id] = AssetsEngineSystem.GetAssets(window_id)['plane_mesh']
		cls.__FINAL_TEXTURE[window_id] = AssetsEngineSystem.GetAssets(window_id)['final_display_texture']
		cls.__TEXTURE_DISPLAY_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['texture_display_shader']


		cls.__RTX_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['rtx_shader']
		cls.__FRAME_BUFFER_RTX[window_id] = FrameBuffer().SetTextures([cls.__FINAL_TEXTURE[window_id]])


		def CallbackSize(width: int, height: int) -> None:
			SetViewport(width, height)
			#cls.__FINAL_TEXTURE[window_id].SetEmptyData(width, height).LoadToGpu()
			cls.__FRAME_BUFFER_RTX[window_id].UpdateSize(width, height)


		window = WindowContextSystem.GetCurrentWindow()
		window.AppendCallbackSize(CallbackSize) # type: ignore
		window_size = window.GetSize() # type: ignore
		CallbackSize(int(window_size.x), int(window_size.y)) 






	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__FRAME_ID.pop(window_id, None)
		cls.__DRAW_STATUS.pop(window_id, None)

		cls.__PLANE_MESH.pop(window_id, None)
		cls.__FINAL_TEXTURE.pop(window_id, None)
		cls.__TEXTURE_DISPLAY_SHADER.pop(window_id, None)

		cls.__RTX_SHADER.pop(window_id, None)
		cls.__FRAME_BUFFER_RTX.pop(window_id, None)




	@classmethod
	def RenderScene(cls,
			window_id: int, 
			ssbo_callbacks: Tuple[
				Callable[[int], int], 
				Callable[[int], int], 
				Callable[[int], int]
			]
		) -> None:

		drawstatus = cls.__DRAW_STATUS[window_id]
		if(not drawstatus.GetStatusSync()): return

		#a = GetCurrentTime()

		(
			transfroms_count,
			cameras_count,
			procedurals_count

		) = (callback(window_id) for callback in ssbo_callbacks)
		MaterialControllerSystem.CheckQueueChange(window_id)

		# b = GetCurrentTime()
		# Profiler.AppendData(
		# 	data_name= f"{window_id} ssbo Update",
		# 	data_value= b-a)


		frame_id = cls.__FRAME_ID[window_id]
		plane = cls.__PLANE_MESH[window_id]
		#final_texture = cls.__FINAL_TEXTURE[window_id]



		# вывод результата на экран
		ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
		ClearDepthBuffer()
		cls.__TEXTURE_DISPLAY_SHADER[window_id].StartUseProgram()
		plane.DrawMesh()




		# рендер, запись в текстуру
		rtx_fb = cls.__FRAME_BUFFER_RTX[window_id]
		rtx_fb.Bind()


		ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
		ClearDepthBuffer()
		#final_texture.FillWithColor(( 0.0 , 0.0 , 0.0 , 0.0 ))

		shader = cls.__RTX_SHADER[window_id].StartUseProgram().GetShaderData()
		shader.SetUniformInt_one("FRAME_ID", frame_id)
		shader.SetUniformInt_one("TRANSFORMS_COUNT", transfroms_count)
		shader.SetUniformInt_one("CAMERAS_COUNT", cameras_count)
		shader.SetUniformInt_one("PROCEDURALS_COUNT", procedurals_count)
		shader.SetUniformInt_one("MAX_BOUNCE_COUNT", 8)
		plane.DrawMesh()


		rtx_fb.Unbind()




		drawstatus.SetSync()
		RenderNOW()
		frame_id += 1
		cls.__FRAME_ID[window_id] = frame_id

		# b = GetCurrentTime()
		# Profiler.AppendData(
		# 	data_name= f"{window_id} Render",
		# 	data_value= b-cls.__UPDATE_TIME)
		# cls.__UPDATE_TIME = b