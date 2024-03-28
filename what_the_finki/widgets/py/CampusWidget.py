import os

from kivy.uix.floatlayout import FloatLayout
from kivy.lang import Builder

Builder.load_file(os.path.join(os.path.dirname(__file__), '../kv/CampusWidget.kv'))


class CampusWidget(FloatLayout):
    pass
