from typing import Dict, Callable, Set
import imgui
from imgui.integrations.glfw import GlfwRenderer

from ..WindowSystem import WindowContextSystem


class IUiObject:
	draw: Callable[[], None]
	destroy: Callable[[], None]
	def __init__(self, draw: Callable[[], None], destroy: Callable[[], None]) -> None:
		self.draw = draw
		self.destroy = destroy


class UiSystem:

	__ENABLE_QUEUE_UPDATES: Dict[int, bool] = {}
	__UI_OBJECTS: Dict[int, Set[IUiObject]] = {}

	__UI_LIB: Dict[int, GlfwRenderer] = {}

	
	@classmethod
	def WindowInitialization(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = True
		cls.__UI_OBJECTS[window_id] = set()
		imgui.create_context()
		cls.__UI_LIB[window_id] = GlfwRenderer(WindowContextSystem.GetCurrentWindow().GetWindowObject()) # type: ignore

	@classmethod
	def WindowFlush(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False
		ui_objects = cls.__UI_OBJECTS[window_id]
		for ui_object in ui_objects:
			ui_object.destroy()
		ui_objects.clear()

	@classmethod
	def WindowTerminate(cls, window_id: int) -> None:
		cls.__ENABLE_QUEUE_UPDATES[window_id] = False
		for ui_object in cls.__UI_OBJECTS[window_id]:
			ui_object.destroy()
		cls.__UI_OBJECTS.pop(window_id, None)
		cls.__ENABLE_QUEUE_UPDATES.pop(window_id, None)

		cls.__UI_LIB[window_id].shutdown()
		cls.__UI_LIB.pop(window_id, None)


	@classmethod
	def ShowUi(cls, window_id: int) -> None:
		impl = cls.__UI_LIB[window_id]
		impl.process_inputs()


		imgui.new_frame()
		imgui.begin("Test")
		_, show_panel = imgui.checkbox("Показать панель", False)
		imgui.end()


		imgui.render()
		impl.render(imgui.get_draw_data())