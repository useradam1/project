from ..ApiGraphics import RenderNOW, SetViewport, ClearColor, CheckDrawStatus, ClearDepthBuffer, CopyImageSubDataTexture2DAny
from ..ApiWindow import WindowSwapBuffers, window_type
from ..WindowSystem import WindowContextSystem, WindowInterface
from ..GpuResourceSystem import Mesh, Shader, Texture2D, Texture2DFloat, FrameBuffer, MaterialControllerSystem
from ..AssetsEngineSystem import AssetsEngineSystem

from ..Math import vec2_ptr_static, vec2

from ..WindowSystem.Controllers.KeyBoard import KeyBoard

from numpy import float32, uint8, clip, flipud, power

from typing import Dict, Tuple, Callable

from PIL import Image

def format_time(seconds: float) -> str:
    h, remainder = divmod(seconds, 3600)
    m, s = divmod(remainder, 60)
    return f"{h:.0f}h : {m:.0f}m : {s:.3f}s"

class RenderingPipeline:

	__DRAW_STATUS: Dict[int, CheckDrawStatus] = {}

	__RENDERING_RUN: Dict[int, bool] = {}
	__QUALITY_LIMIT: Dict[int, int] = {}
	__FRAME_ID: Dict[int, int] = {}
	__CURRENT_CHUNK: Dict[int, int] = {}
	__RENDER_CHUNKS_WIDTH: Dict[int, int] = {}
	__RENDER_CHUNKS_HEIGHT: Dict[int, int] = {}
	__RENDER_CHUNKS_SIZE: Dict[int, int] = {}
	__DENOISING_STRENGTH: Dict[int, float] = {}


	__PLANE_MESH: Dict[int, Mesh] = {}
	__FINAL_TEXTURE: Dict[int, Texture2DFloat] = {}
	__DOUBLE_TEXTURE: Dict[int, Texture2DFloat] = {}
	__TEXTURE_DISPLAY_SHADER: Dict[int, Shader] = {}
	__NOISE_SUPPRESSOR_SHADER: Dict[int, Shader] = {}

	__RTX_SHADER: Dict[int, Shader] = {}
	__FRAME_BUFFER_RTX: Dict[int, FrameBuffer] = {}


	__WINDOW_SIZE: Dict[int, vec2_ptr_static] = {}
	__WINDOW: Dict[int, WindowInterface] = {}
	__WINDOW_OBJECT: Dict[int, window_type] = {}

	__AVERAGE_TIME: Dict[int, float] = {}



	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__DRAW_STATUS[window_id] = CheckDrawStatus()

		cls.__RENDERING_RUN[window_id] = False
		cls.__QUALITY_LIMIT[window_id] = 1000
		cls.__FRAME_ID[window_id] = 0
		cls.__CURRENT_CHUNK[window_id] = 0
		chunk_width = 4
		chunk_height = 4
		cls.__RENDER_CHUNKS_WIDTH[window_id] = chunk_width
		cls.__RENDER_CHUNKS_HEIGHT[window_id] = chunk_height
		cls.__RENDER_CHUNKS_SIZE[window_id] = chunk_width*chunk_height
		cls.__DENOISING_STRENGTH[window_id] = 0.5


		cls.__PLANE_MESH[window_id] = AssetsEngineSystem.GetAssets(window_id)['plane_mesh']
		cls.__FINAL_TEXTURE[window_id] = AssetsEngineSystem.GetAssets(window_id)['final_display_texture']
		cls.__DOUBLE_TEXTURE[window_id] = Texture2DFloat()

		cls.__TEXTURE_DISPLAY_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['texture_display_shader']
		cls.__NOISE_SUPPRESSOR_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['noise_suppressor']


		cls.__RTX_SHADER[window_id] = AssetsEngineSystem.GetAssets(window_id)['rtx_shader']
	
	
		cls.__FRAME_BUFFER_RTX[window_id] = FrameBuffer().SetTextures([
			cls.__FINAL_TEXTURE[window_id],
			cls.__DOUBLE_TEXTURE[window_id]
		])


		window = WindowContextSystem.GetCurrentWindow()

		cls.__FRAME_BUFFER_RTX[window_id].UpdateSize(
			int(1000), int(1000))

		cls.__WINDOW[window_id] = window # type: ignore
		cls.__WINDOW_SIZE[window_id] = window.GetSize() # type: ignore
		cls.__WINDOW_OBJECT[window_id] = window.GetWindowObject() # type: ignore

		cls.__AVERAGE_TIME[window_id] = 0.0

		cls.debug = vec2(15,60)


	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__RENDERING_RUN.pop(window_id, None)
		cls.__QUALITY_LIMIT.pop(window_id, None)
		cls.__FRAME_ID.pop(window_id, None)
		cls.__CURRENT_CHUNK.pop(window_id, None)
		cls.__RENDER_CHUNKS_WIDTH.pop(window_id, None)
		cls.__RENDER_CHUNKS_HEIGHT.pop(window_id, None)
		cls.__RENDER_CHUNKS_SIZE.pop(window_id, None)
		cls.__DRAW_STATUS.pop(window_id, None)

		cls.__PLANE_MESH.pop(window_id, None)
		cls.__FINAL_TEXTURE.pop(window_id, None)
		texture = cls.__DOUBLE_TEXTURE.pop(window_id, None)
		if(texture is not None): texture.Destroy()

		cls.__TEXTURE_DISPLAY_SHADER.pop(window_id, None)
		cls.__NOISE_SUPPRESSOR_SHADER.pop(window_id, None)

		cls.__RTX_SHADER.pop(window_id, None)
		cls.__FRAME_BUFFER_RTX.pop(window_id, None)

		cls.__WINDOW.pop(window_id, None)
		cls.__WINDOW_SIZE.pop(window_id, None)
		cls.__WINDOW_OBJECT.pop(window_id, None)

		cls.__AVERAGE_TIME.pop(window_id, None)





	@classmethod
	def StartRender(cls, window_id: int,
				width: int,
				height: int,
				quality_limit: int,
				chunk_width: int,
				chunk_height: int,
				denoising_strength: float
			) -> None:
		cls.__RENDERING_RUN[window_id] = True
		cls.__QUALITY_LIMIT[window_id] = quality_limit
		cls.__FRAME_ID[window_id] = 1
		cls.__CURRENT_CHUNK[window_id] = 0
		cls.__RENDER_CHUNKS_WIDTH[window_id] = chunk_width
		cls.__RENDER_CHUNKS_HEIGHT[window_id] = chunk_height
		cls.__RENDER_CHUNKS_SIZE[window_id] = chunk_width*chunk_height
		cls.__DENOISING_STRENGTH[window_id] = denoising_strength
		cls.__FRAME_BUFFER_RTX[window_id].UpdateSize(
			width, height)
		cls.__AVERAGE_TIME[window_id] = 0.0
		print("RENDER START")

	@classmethod
	def StopRender(cls, window_id: int) -> None:
		cls.__RENDERING_RUN[window_id] = False
		cls.__FRAME_ID[window_id] = 0
		cls.__CURRENT_CHUNK[window_id] = 0
		print("RENDER STOP")

	@classmethod
	def SaveRenderAsImage(cls, window_id: int, path: str) -> None:
		data = cls.__FINAL_TEXTURE[window_id].GetActualData()

		if data.dtype == float32:
			data = clip(data, 0.0, 1.0)  # Ограничиваем в диапазоне [0, 1]
			data = power(data, 1.0/2.0)  # Гамма коррекция с гаммой 2.0
			data = (data * 255).astype(uint8)

		data = flipud(data)  
		image = Image.fromarray(data[:, :, :3])  

		# Получаем расширение файла корректно
		if '.' in path:
			image_format = path.rsplit('.', 1)[-1].upper()
			if image_format == 'JPG':
				image_format = 'JPEG'
		else:
			raise ValueError("Файл должен иметь расширение (например, 'output.png')")

		image.save(path, format=image_format)


	@classmethod
	def ShowScene(cls,
			window_id: int, 
			ssbo_callbacks: Tuple[
				Callable[[int], None], 
				Callable[[int], int],
				Callable[[int], int],

				Callable[[int], None],

				Callable[[int], int],
				Callable[[int], int],
			]
		) -> None:

		#drawstatus = cls.__DRAW_STATUS[window_id]
		#if(not drawstatus.GetStatusSync()): return

		# отправка данных в gpu
		MaterialControllerSystem.CheckQueueChange(window_id)

		ssbo_callbacks[0](window_id) #transfroms
		cameras_count = ssbo_callbacks[1](window_id)
		procedurals_count = ssbo_callbacks[2](window_id)

		ssbo_callbacks[3](window_id) #meshes
		procedurals_meshes_count = ssbo_callbacks[4](window_id)
		procedurals_sdf_count = ssbo_callbacks[5](window_id)



		rendering_run = cls.__RENDERING_RUN[window_id]
		plane = cls.__PLANE_MESH[window_id]
		frame_id = cls.__FRAME_ID[window_id]
		current_chunk = cls.__CURRENT_CHUNK[window_id]


		size = cls.__WINDOW_SIZE[window_id]
		SetViewport(int(size.x),int(size.y))
	
		# вывод результата на экран
		ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
		ClearDepthBuffer()
		cls.__TEXTURE_DISPLAY_SHADER[window_id].StartUseProgram()
		plane.DrawMesh()




		# рендер, запись в текстуру
		if(frame_id < cls.__QUALITY_LIMIT[window_id]):
			rtx_fb = cls.__FRAME_BUFFER_RTX[window_id]
			rtx_fb.Bind()

			final_texture = cls.__FINAL_TEXTURE[window_id]
			SetViewport(final_texture.GetHeight(), final_texture.GetWidth())

			#ClearColor( 0.0 , 0.0 , 0.0 , 1.0 )
			#ClearDepthBuffer()
			#final_texture.FillWithColor(( 0.0 , 0.0 , 0.0 , 0.0 ))

			shader = cls.__RTX_SHADER[window_id].StartUseProgram().GetShaderData()
			shader.SetUniformBool_one("RENDERING_RUN", rendering_run)
			shader.SetUniformInt_one("CURRENT_CHUNK", current_chunk)
			shader.SetUniformInt_one("CHUNK_WIDTH", cls.__RENDER_CHUNKS_WIDTH[window_id])
			shader.SetUniformInt_one("CHUNK_HEIGHT", cls.__RENDER_CHUNKS_HEIGHT[window_id])
			shader.SetUniformInt_one("FRAME_ID", frame_id)
			shader.SetUniformInt_one("CAMERAS_COUNT", cameras_count)
			shader.SetUniformInt_one("PROCEDURALS_COUNT", procedurals_count)
			shader.SetUniformInt_one("PROCEDURALS_MESHES_COUNT", procedurals_meshes_count)
			shader.SetUniformInt_one("PROCEDURALS_SDF_COUNT", procedurals_sdf_count)

			# if(KeyBoard.GetKey("m")): cls.debug.x+=0.01
			# if(KeyBoard.GetKey("n")): cls.debug.x=max(1,cls.debug.x-0.01)
			# if(KeyBoard.GetKey("b")): cls.debug.y+=0.01
			# if(KeyBoard.GetKey("v")): cls.debug.y=max(1,cls.debug.y-0.01)
			# print(cls.debug, end="\r")
			# shader.SetUniformFloat_one("TRIANGLE_HIT", cls.debug.x)
			# shader.SetUniformFloat_one("BOX_HIT", cls.debug.y)

			plane.DrawMesh()


			# shader = cls.__NOISE_SUPPRESSOR_SHADER[window_id].StartUseProgram().GetShaderData()
			# shader.SetUniformFloat_one("DENOISING_STRENGTH", cls.__DENOISING_STRENGTH[window_id])
			
			# src = cls.__DOUBLE_TEXTURE[window_id]
			# dst = cls.__FINAL_TEXTURE[window_id]
			# shader.SetUniformBool_one("MOD", True)
			# plane.DrawMesh()
			# CopyImageSubDataTexture2DAny(
			# 	src.GetObject(), dst.GetObject(), src.GetWidth(), src.GetHeight()
			# )
			# shader.SetUniformBool_one("MOD", False)
			# plane.DrawMesh()
			# CopyImageSubDataTexture2DAny(
			# 	src.GetObject(), dst.GetObject(), src.GetWidth(), src.GetHeight()
			# )


			rtx_fb.Unbind()





		#drawstatus.SetSync()
		#RenderNOW()
		WindowSwapBuffers(cls.__WINDOW_OBJECT[window_id])

		quality_limit = cls.__QUALITY_LIMIT[window_id]
		render_chunks = cls.__RENDER_CHUNKS_SIZE[window_id]

		# if(current_chunk >= render_chunks and rendering_run):
		# 	cls.__RENDERING_RUN[window_id] = False
		# 	print("RENDER END")
		# elif(rendering_run):
		# 	frame_id+=1
		# 	if(frame_id>quality_limit):
		# 		cls.__CURRENT_CHUNK[window_id] = current_chunk+1
		# 		cls.__FRAME_ID[window_id] = 0
		# 	else:
		# 		cls.__FRAME_ID[window_id] = frame_id
		# 	chunk_progress = (current_chunk / render_chunks) * 100.0
		# 	frame_progress = (frame_id / quality_limit) * (100.0 / render_chunks)
		# 	remaining_frames = (quality_limit - frame_id) + (render_chunks - current_chunk - 1) * quality_limit
		# 	total_time = cls.__WINDOW[window_id].GetCurrentFrameRate() * remaining_frames
		# 	print(f"RENDER {chunk_progress+frame_progress:.3f}, total time {total_time:.3f}", end='\r')

		if(frame_id > quality_limit and rendering_run):
			cls.__RENDERING_RUN[window_id] = False
			print("RENDER END")
		elif(rendering_run):
			average_time = cls.__AVERAGE_TIME[window_id]


			current_chunk+=1
			if(current_chunk>=render_chunks):
				cls.__FRAME_ID[window_id] = frame_id+1
				cls.__CURRENT_CHUNK[window_id] = 0
			else:
				cls.__CURRENT_CHUNK[window_id] = current_chunk
			print(f"RENDER {100*(frame_id / quality_limit):.2f}%, total time {format_time((render_chunks*average_time)*(quality_limit - frame_id))}", end='\r')


			cls.__AVERAGE_TIME[window_id] += (cls.__WINDOW[window_id].GetCurrentFrameRate()-average_time)/(frame_id+1)
			#cls.__AVERAGE_TIME[window_id] = (average_time+cls.__WINDOW[window_id].GetCurrentFrameRate())*0.5



class RenderSettings:

	@classmethod
	def StartRender(cls,
				width: int,
				height: int,
				quality_limit: int,
				chunk_width: int,
				chunk_height: int,
				denoising_strength: float
			) -> None:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return
		RenderingPipeline.StartRender(window_id, width, height, quality_limit, chunk_width, chunk_height, denoising_strength)
	
	@classmethod
	def StopRender(cls) -> None:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return
		RenderingPipeline.StopRender(window_id)

	@classmethod
	def SaveRenderAsImage(cls, path: str) -> None:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return
		RenderingPipeline.SaveRenderAsImage(window_id, path)