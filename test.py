import win32gui
import win32con
import win32api

class Win32Window:
    def __init__(self):
        self.hInstance = win32api.GetModuleHandle(None)
        self.className = "SimpleWin32Window"

        wndClass = win32gui.WNDCLASS()
        wndClass.style = win32con.CS_HREDRAW | win32con.CS_VREDRAW
        wndClass.lpfnWndProc = self.wndProc
        wndClass.hInstance = self.hInstance
        wndClass.hCursor = win32gui.LoadCursor(None, win32con.IDC_ARROW)
        wndClass.hbrBackground = win32con.COLOR_WINDOW + 1
        wndClass.lpszClassName = self.className

        win32gui.RegisterClass(wndClass)

        self.hwnd = win32gui.CreateWindow(
            self.className,
            "Простое окно Win32",
            win32con.WS_OVERLAPPEDWINDOW,
            100, 100, 500, 400,
            0, 0, self.hInstance, None
        )

        win32gui.ShowWindow(self.hwnd, win32con.SW_SHOWNORMAL)
        win32gui.UpdateWindow(self.hwnd)

    def wndProc(self, hwnd, msg, wParam, lParam):
        if msg == win32con.WM_DESTROY:
            win32gui.PostQuitMessage(0)
            return 0
        return win32gui.DefWindowProc(hwnd, msg, wParam, lParam)

    def run(self):
        while True:
            msg = win32gui.PumpWaitingMessages()
            if msg is None:
                break

if __name__ == "__main__":
    app = Win32Window()
    app.run()
