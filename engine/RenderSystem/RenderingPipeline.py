from ..ApiGraphics import RenderNOW, SetViewport, ClearColor, CheckDrawStatus, ClearDepthBuffer
from ..WindowSystem import WindowContextSystem
from ..GpuResourceSystem import Mesh, Shader, Texture2D, Texture2DFoat, FrameBuffer, MaterialControllerSystem
from ..AssetsEngineSystem import AssetsEngineSystem



from typing import Dict, Tuple, Callable





class RenderingPipeline:

	__RENDERING_RUN: Dict[int, bool] = {}
	__QUALITY_LIMIT: Dict[int, int] = {}
	__FRAME_ID: Dict[int, int] = {}
	__DRAW_STATUS: Dict[int, CheckDrawStatus] = {}


	__PLANE_MESH: Dict[int, Mesh] = {}
	__FINAL_TEXTURE: Dict[int, Texture2D] = {}
	__TEXTURE_DISPLAY_SHADER: Dict[int, Shader] = {}

	__RTX_SHADER: Dict[int, Shader] = {}
	__FRAME_BUFFER_RTX: Dict[int, FrameBuffer] = {}





	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__RENDERING_RUN[window_id] = False
		cls.__QUALITY_LIMIT[window_id] = 1000
		cls.__FRAME_ID[window_id] = 0
		cls.__DRAW_STATUS[window_id] = CheckDrawStatus()

		cls.__PLANE_MESH[window_id] = AssetsEngineSystem.GetAssets(window_id)['plane_mesh']
		cls.__FINAL_TEXTURE[window_id] = AssetsEngineSystem.GetAssets(window_id)['final_display_texture']
		cls.__TEXTURE_DISPLAY_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['texture_display_shader']


		cls.__RTX_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['rtx_shader']
	
	
		cls.__FRAME_BUFFER_RTX[window_id] = FrameBuffer().SetTextures([
			cls.__FINAL_TEXTURE[window_id],
		])



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

		cls.__RTX_SHADER.pop(window_id, None)
		cls.__FRAME_BUFFER_RTX.pop(window_id, None)



	@classmethod
	def StartRender(cls, window_id: int, quality_limit: int) -> None:
		cls.__RENDERING_RUN[window_id] = True
		cls.__QUALITY_LIMIT[window_id] = quality_limit
		cls.__FRAME_ID[window_id] = 0
		print("RENDER START")
	
	@classmethod
	def StopRender(cls, window_id: int) -> None:
		cls.__RENDERING_RUN[window_id] = False
		cls.__FRAME_ID[window_id] = 0


	@classmethod
	def ShowScene(cls,
			window_id: int, 
			ssbo_callbacks: Tuple[
				Callable[[int], None], 
				Callable[[int], int], 
				Callable[[int], int]
			]
		) -> None:

		drawstatus = cls.__DRAW_STATUS[window_id]
		if(not drawstatus.GetStatusSync()): return

		#a = GetCurrentTime()

		# отправка данных в gpu
		transfroms_count = ssbo_callbacks[0](window_id)
		cameras_count = ssbo_callbacks[1](window_id)
		procedurals_count = ssbo_callbacks[2](window_id)
		MaterialControllerSystem.CheckQueueChange(window_id)

		# b = GetCurrentTime()
		# Profiler.AppendData(
		# 	data_name= f"{window_id} ssbo Update",
		# 	data_value= b-a)


		plane = cls.__PLANE_MESH[window_id]
		frame_id = cls.__FRAME_ID[window_id]


		# вывод результата на экран
		ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
		ClearDepthBuffer()
		cls.__TEXTURE_DISPLAY_SHADER[window_id].StartUseProgram()
		plane.DrawMesh()




		if(frame_id < cls.__QUALITY_LIMIT[window_id]):
			# рендер, запись в текстуру
			rtx_fb = cls.__FRAME_BUFFER_RTX[window_id]
			rtx_fb.Bind()

			#ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
			#ClearDepthBuffer()
			#final_texture.FillWithColor(( 0.0 , 0.0 , 0.0 , 0.0 ))

			shader = cls.__RTX_SHADER[window_id].StartUseProgram().GetShaderData()
			shader.SetUniformInt_one("FRAME_ID", frame_id)
			shader.SetUniformInt_one("CAMERAS_COUNT", cameras_count)
			shader.SetUniformInt_one("PROCEDURALS_COUNT", procedurals_count)
			plane.DrawMesh()

			rtx_fb.Unbind()







		drawstatus.SetSync()
		RenderNOW()


		if(frame_id > cls.__QUALITY_LIMIT[window_id] and cls.__RENDERING_RUN[window_id]):
			cls.__RENDERING_RUN[window_id] = False
			print("RENDER END")
		elif(cls.__RENDERING_RUN[window_id]):
			cls.__FRAME_ID[window_id] = frame_id+1
			print(f"RENDER {frame_id}", end='\r')

		# b = GetCurrentTime()
		# Profiler.AppendData(
		# 	data_name= f"{window_id} Render",
		# 	data_value= b-cls.__UPDATE_TIME)
		# cls.__UPDATE_TIME = b




class RenderSettings:

	@classmethod
	def StartRender(cls, quality_limit: int) -> None:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return
		RenderingPipeline.StartRender(window_id, quality_limit)
	
	@classmethod
	def StopRender(cls) -> None:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return
		RenderingPipeline.StopRender(window_id)