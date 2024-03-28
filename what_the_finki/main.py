from kivy.app import App
from kivy.core.window import Window
from kivy.factory import Factory
from what_the_finki.widgets.py.BuildingWidget import BuildingWidget
from what_the_finki.widgets.py.CampusWidget import CampusWidget
from what_the_finki.widgets.py.RoomNamePill import RoomNamePill
from what_the_finki.widgets.py.RoomWidget import RoomWidget
from what_the_finki.widgets.py.RootWidget import RootWidget

Window.clearcolor = (.961, .969, .973, 1)


class MapApp(App):
    def build(self):
        Factory.register('RootWidget', cls=RootWidget)
        Factory.register('RoomWidget', cls=RoomWidget)
        Factory.register('RoomNamePill', cls=RoomNamePill)
        Factory.register('CampusWidget', cls=CampusWidget)
        Factory.register('BuildingWidget', cls=BuildingWidget)
        return Factory.RootWidget()


MapApp().run()
