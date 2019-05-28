from os.path import dirname, join

import pandas as pd
from bokeh.io import curdoc
from bokeh.models.widgets import Tabs
from bokeh.models.widgets import Select
from scripts.table_preview import create_data_preview_tab


def main():
    exp_data = pd.read_csv(join(dirname(__file__), 'data/exp_data.csv'))
    exp_data.dropna(inplace=True)

    tab1 = create_data_preview_tab(exp_data)

    tabs = Tabs(tabs=[tab1])
    curdoc().add_root(tabs)


main()
