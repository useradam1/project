from colorama import init, Fore, Style
init(autoreset=True)

class LogColors:
	RESET = Fore.RESET
	RED = Fore.RED
	GREEN = Fore.GREEN
	YELLOW = Fore.YELLOW
	BLUE = Fore.BLUE

def PrintLog(text: str, color: str = LogColors.RESET) -> None:
	print(f"{color}{text}")