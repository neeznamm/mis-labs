from kivy.app import App
from kivy.core.window import Window
from kivy.uix.anchorlayout import AnchorLayout
from kivy.uix.button import Button
from kivy.uix.floatlayout import FloatLayout
from kivy.uix.scatter import Scatter

Window.clearcolor = (.961, .969, .973, 1)


class RootWidget(Scatter):
    pass


class CampusWidget(FloatLayout):
    pass


class BuildingWidget(FloatLayout):
    pass


class RoomWidget(AnchorLayout):
    pass


class RoomNamePill(Button):
    pass


class MapApp(App):
    def build(self):
        return RootWidget()


MapApp().run()
