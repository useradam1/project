from ..WindowSystem import WindowContextSystem
from .SceneSystem import SceneManagerSystem
from ..WindowEvents import WindowFlush
from typing import List


emptyset = set()


class SceneManager:

	@classmethod
	def GetGameObjectsByName(cls, name: str) -> set:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return emptyset
		return SceneManagerSystem.GetGameObjectsByName(name, window_id)
	@classmethod
	def GetGameObjectsByTag(cls, tag: str) -> set:
		window_id = WindowContextSystem.GetCurrentWindowId()
		if(not window_id): return emptyset
		return SceneManagerSystem.GetGameObjectsByTag(tag, window_id)

	@classmethod
	def RunScene(cls, name_scene: str) -> None:
		SceneManagerSystem.RunScene(WindowContextSystem.GetCurrentWindowId(), name_scene)

	@classmethod
	def EndScene(cls) -> None:
		WindowFlush(WindowContextSystem.GetCurrentWindowId())
		#SceneManagerSystem.EndScene(WindowContextSystem.GetCurrentWindowId())

	@classmethod
	def GetScenes(cls) -> List[str]:
		return SceneManagerSystem.GetScenes()

	@classmethod
	def GetActiveScene(cls) -> str:
		return SceneManagerSystem.GetActiveScene(WindowContextSystem.GetCurrentWindowId())