class MyComponent:
    def __init__(self, parent=None):
        self.parent = parent
        if self.parent:
            self.parent.handle_component_initialization(self)

    def do_something(self):
        print("MyComponent делает что-то полезное")

class MyClass:
    def __init__(self, component):
        self.component = component
        self.component.parent = self

    def handle_component_initialization(self, component):
        print(f"MyClass узнал, что компонент {component} был инициализирован")
        component.do_something()

# Использование
test = MyClass(
    component=MyComponent()
)