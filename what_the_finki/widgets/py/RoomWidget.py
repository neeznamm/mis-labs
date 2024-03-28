import os

from kivy.uix.anchorlayout import AnchorLayout
from kivy.lang import Builder

Builder.load_file(os.path.join(os.path.dirname(__file__), '../kv/RoomWidget.kv'))


class RoomWidget(AnchorLayout):
    pass
