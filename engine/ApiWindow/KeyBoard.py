import glfw
import glfw.GLFW as GLFW_CONSTANTS
import ctypes
from typing import Type, Optional, Callable, Tuple, Literal, Dict

window_type = Type[ctypes.POINTER(glfw._GLFWwindow)]



NUMButtonKeyBoard: Dict[int, str] = {
	GLFW_CONSTANTS.GLFW_KEY_ESCAPE: "esc",
	GLFW_CONSTANTS.GLFW_KEY_TAB: "tab",
	GLFW_CONSTANTS.GLFW_KEY_CAPS_LOCK: "capslock",
	GLFW_CONSTANTS.GLFW_KEY_LEFT_SHIFT: "left_shift",
	GLFW_CONSTANTS.GLFW_KEY_LEFT_CONTROL: "left_ctrl",
	GLFW_CONSTANTS.GLFW_KEY_LEFT_ALT: "left_alt",
	GLFW_CONSTANTS.GLFW_KEY_SPACE: "space",
	GLFW_CONSTANTS.GLFW_KEY_RIGHT_ALT: "right_alt",
	GLFW_CONSTANTS.GLFW_KEY_RIGHT_CONTROL: "right_ctrl",
	GLFW_CONSTANTS.GLFW_KEY_RIGHT_SHIFT: "right_shift",
	GLFW_CONSTANTS.GLFW_KEY_ENTER: "enter",
	GLFW_CONSTANTS.GLFW_KEY_BACKSPACE: "backspace",
	GLFW_CONSTANTS.GLFW_KEY_LEFT: "left",
	GLFW_CONSTANTS.GLFW_KEY_RIGHT: "right",
	GLFW_CONSTANTS.GLFW_KEY_UP: "up",
	GLFW_CONSTANTS.GLFW_KEY_DOWN: "down",
	GLFW_CONSTANTS.GLFW_KEY_LEFT_BRACKET: "left_bracket",
	GLFW_CONSTANTS.GLFW_KEY_RIGHT_BRACKET: "right_bracket",
	GLFW_CONSTANTS.GLFW_KEY_SEMICOLON: "semicolon",
	GLFW_CONSTANTS.GLFW_KEY_APOSTROPHE: "apostrophe",
	GLFW_CONSTANTS.GLFW_KEY_GRAVE_ACCENT: "grave_accent",
	GLFW_CONSTANTS.GLFW_KEY_COMMA: "comma",
	GLFW_CONSTANTS.GLFW_KEY_PERIOD: "period",
	GLFW_CONSTANTS.GLFW_KEY_SLASH: "slash",
	GLFW_CONSTANTS.GLFW_KEY_BACKSLASH: "backslash",
	GLFW_CONSTANTS.GLFW_KEY_EQUAL: "equal",
	GLFW_CONSTANTS.GLFW_KEY_MINUS: "minus",
	GLFW_CONSTANTS.GLFW_KEY_LEFT_SUPER: "left_super",
	GLFW_CONSTANTS.GLFW_KEY_RIGHT_SUPER: "right_super",
	GLFW_CONSTANTS.GLFW_KEY_MENU: "menu",

	# Function keys
	GLFW_CONSTANTS.GLFW_KEY_F1: "f1",
	GLFW_CONSTANTS.GLFW_KEY_F2: "f2",
	GLFW_CONSTANTS.GLFW_KEY_F3: "f3",
	GLFW_CONSTANTS.GLFW_KEY_F4: "f4",
	GLFW_CONSTANTS.GLFW_KEY_F5: "f5",
	GLFW_CONSTANTS.GLFW_KEY_F6: "f6",
	GLFW_CONSTANTS.GLFW_KEY_F7: "f7",
	GLFW_CONSTANTS.GLFW_KEY_F8: "f8",
	GLFW_CONSTANTS.GLFW_KEY_F9: "f9",
	GLFW_CONSTANTS.GLFW_KEY_F10: "f10",
	GLFW_CONSTANTS.GLFW_KEY_F11: "f11",
	GLFW_CONSTANTS.GLFW_KEY_F12: "f12",

	# Keypad keys
	GLFW_CONSTANTS.GLFW_KEY_KP_0: "keypad_0",
	GLFW_CONSTANTS.GLFW_KEY_KP_1: "keypad_1",
	GLFW_CONSTANTS.GLFW_KEY_KP_2: "keypad_2",
	GLFW_CONSTANTS.GLFW_KEY_KP_3: "keypad_3",
	GLFW_CONSTANTS.GLFW_KEY_KP_4: "keypad_4",
	GLFW_CONSTANTS.GLFW_KEY_KP_5: "keypad_5",
	GLFW_CONSTANTS.GLFW_KEY_KP_6: "keypad_6",
	GLFW_CONSTANTS.GLFW_KEY_KP_7: "keypad_7",
	GLFW_CONSTANTS.GLFW_KEY_KP_8: "keypad_8",
	GLFW_CONSTANTS.GLFW_KEY_KP_9: "keypad_9",
	GLFW_CONSTANTS.GLFW_KEY_KP_DECIMAL: "keypad_decimal",
	GLFW_CONSTANTS.GLFW_KEY_KP_DIVIDE: "keypad_divide",
	GLFW_CONSTANTS.GLFW_KEY_KP_MULTIPLY: "keypad_multiply",
	GLFW_CONSTANTS.GLFW_KEY_KP_SUBTRACT: "keypad_subtract",
	GLFW_CONSTANTS.GLFW_KEY_KP_ADD: "keypad_add",
	GLFW_CONSTANTS.GLFW_KEY_KP_ENTER: "keypad_enter",
	GLFW_CONSTANTS.GLFW_KEY_KP_EQUAL: "keypad_equal",

	GLFW_CONSTANTS.GLFW_KEY_PRINT_SCREEN: "printscreen",
	GLFW_CONSTANTS.GLFW_KEY_PAUSE: "pause",
	GLFW_CONSTANTS.GLFW_KEY_INSERT: "insert",
	GLFW_CONSTANTS.GLFW_KEY_DELETE: "delete",
	GLFW_CONSTANTS.GLFW_KEY_HOME: "home",
	GLFW_CONSTANTS.GLFW_KEY_END: "end",
	GLFW_CONSTANTS.GLFW_KEY_PAGE_UP: "pageup",
	GLFW_CONSTANTS.GLFW_KEY_PAGE_DOWN: "pagedown",
	GLFW_CONSTANTS.GLFW_KEY_NUM_LOCK: "numlock",
	GLFW_CONSTANTS.GLFW_KEY_SCROLL_LOCK: "scrolllock",
}
funcyionalKeyBoardKeys=Literal[
	'esc', 'tab', 'capslock', 'right_shift', 'right_ctrl', 'right_alt', 'left_shift', 'left_ctrl', 'left_alt', 'space', 'enter', 'backspace', 
	'left', 'right', 'up', 'down', 'left_bracket', 'right_bracket', 
	'semicolon', 'apostrophe', 'grave_accent', 'comma', 'period', 'slash', 'backslash', 'equal', 'minus', 
	'left_super', 'right_super', 'menu', 'printscreen', 'pause', 'insert', 'delete', 'home', 'end', 'pageup', 'pagedown', 'numlock', 'scrolllock',

	'f1', 'f2', 'f3', 'f4', 'f5', 'f6', 'f7', 'f8', 'f9', 'f10', 'f11', 'f12',  # Function keys
	'keypad_0', 'keypad_1', 'keypad_2', 'keypad_3', 'keypad_4', 'keypad_5', 'keypad_6', 'keypad_7', 'keypad_8', 'keypad_9',  # Keypad number keys
	'keypad_decimal', 'keypad_divide', 'keypad_multiply', 'keypad_subtract', 'keypad_add', 'keypad_enter', 'keypad_equal',  # Keypad other keys 
]
def GetKeyButtonName(key: int) -> str:
	name = glfw.get_key_name(key, 0)
	if(name): return name
	del name
	out = NUMButtonKeyBoard.get(key)
	if(out): return out
	del out
	return f"key_{key}"

def SetCallbackKeyBoardButton(window: window_type, method: Optional[Callable[[window_type,int,int,int,int],None]]):
	GLFW_CONSTANTS.glfwSetKeyCallback(window, method)
	del window, method