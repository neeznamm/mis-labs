import os

from kivy.uix.scatter import Scatter
from kivy.lang import Builder

Builder.load_file(os.path.join(os.path.dirname(__file__), '../kv/RootWidget.kv'))


class RootWidget(Scatter):
    pass
