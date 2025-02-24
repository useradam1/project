from ..WindowSystem import WindowContextSystem
from .SceneSystem import SceneManagerSystem
from .SceneInterface import SceneInterface
from ..WindowEvents import WindowFlush
from typing import List, Optional


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
	def DestroyScene(cls) -> None:
		SceneManagerSystem.DestroyScene(WindowContextSystem.GetCurrentWindowId())
		WindowFlush(WindowContextSystem.GetCurrentWindowId())

	@classmethod
	def GetRegistryScenes(cls) -> List[str]:
		return SceneManagerSystem.GetRegistryScenes()

	@classmethod
	def GetActiveScene(cls) -> Optional[SceneInterface]:
		return SceneManagerSystem.GetActiveScene(WindowContextSystem.GetCurrentWindowId())