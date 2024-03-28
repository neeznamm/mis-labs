import os

from kivy.uix.button import Button
from kivy.lang import Builder

Builder.load_file(os.path.join(os.path.dirname(__file__), '../kv/RoomNamePill.kv'))


class RoomNamePill(Button):
    pass
