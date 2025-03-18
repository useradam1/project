import glfw
import OpenGL.GL as gl
import imgui
from imgui.integrations.glfw import GlfwRenderer

# Инициализация GLFW
if not glfw.init():
    raise RuntimeError("GLFW initialization failed")

# Создание окон
window1 = glfw.create_window(800, 600, "Window 1", None, None)
window2 = glfw.create_window(800, 600, "Window 2", None, None)

if not window1 or not window2:
    glfw.terminate()
    raise RuntimeError("Window creation failed")

# Настройка контекстов ImGui
context1 = imgui.create_context()
context2 = imgui.create_context()

# Инициализация рендереров для каждого окна
imgui.set_current_context(context1)
impl1 = GlfwRenderer(window1)

imgui.set_current_context(context2)
impl2 = GlfwRenderer(window2)

# Основной цикл
while not glfw.window_should_close(window1) or not glfw.window_should_close(window2):
    # Обработка первого окна
    if not glfw.window_should_close(window1):
        glfw.make_context_current(window1)
        imgui.set_current_context(context1)
        impl1.process_inputs()
        
        imgui.new_frame()
        
        # Интерфейс для первого окна
        imgui.begin("Window 1", True)
        _, value1 = imgui.slider_float("Slider 1", 0.5, 0.0, 1.0)
        if imgui.button("Button 1"):
            print("Button 1 clicked!")
        imgui.text(f"Value: {value1:.2f}")
        imgui.end()
        
        gl.glClearColor(0.1, 0.1, 0.1, 1)
        gl.glClear(gl.GL_COLOR_BUFFER_BIT)
        
        imgui.render()
        impl1.render(imgui.get_draw_data())
        glfw.swap_buffers(window1)

    # Обработка второго окна
    if not glfw.window_should_close(window2):
        glfw.make_context_current(window2)
        imgui.set_current_context(context2)
        impl2.process_inputs()
        
        imgui.new_frame()
        
        # Интерфейс для второго окна
        imgui.begin("Window 2", True)
        _, value2 = imgui.slider_int("Progress", 50, 0, 100)
        if imgui.button("Button 2"):
            print("Button 2 pressed!")
        imgui.progress_bar(value2/100, (200, 20))
        imgui.end()
        
        gl.glClearColor(0.1, 0.1, 0.1, 1)
        gl.glClear(gl.GL_COLOR_BUFFER_BIT)
        
        imgui.render()
        impl2.render(imgui.get_draw_data())
        glfw.swap_buffers(window2)

    glfw.poll_events()

# Завершение работы
impl1.shutdown()
impl2.shutdown()
glfw.terminate()