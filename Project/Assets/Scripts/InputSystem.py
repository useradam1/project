from engine import *

class InputSystem:
    __prev_keys: dict[str, bool] = {}
    __current_keys: dict[str, bool] = {}
    
    @classmethod
    def Update(cls) -> None:
        """Обновляет состояние клавиш и определяет события нажатия/отпускания"""
        cls.__prev_keys = cls.__current_keys.copy()
        cls.__current_keys = {key: KeyBoard.GetKey(key) for key in cls.__current_keys.keys()}
        #print(cls.__prev_keys, cls.__current_keys, end="\r")
    
    @classmethod
    def IsKeyDown(cls, key: str) -> bool:
        """Возвращает True, если клавиша была нажата в текущем кадре"""
        return cls.__current_keys.get(key, False) and not cls.__prev_keys.get(key, False)
    
    @classmethod
    def IsKeyUp(cls, key: str) -> bool:
        """Возвращает True, если клавиша была отпущена в текущем кадре"""
        return not cls.__current_keys.get(key, False) and cls.__prev_keys.get(key, False)
    
    @classmethod
    def IsKeyHeld(cls, key: str) -> bool:
        """Возвращает True, если клавиша удерживается"""
        return cls.__current_keys.get(key, False)

    @classmethod
    def RegisterKey(cls, key: str) -> None:
        """Добавляет клавишу в список отслеживаемых"""
        if key not in cls.__current_keys:
            cls.__current_keys[key] = KeyBoard.GetKey(key)
            cls.__prev_keys[key] = False