from os.path import dirname, join

import pandas as pd
from bokeh.models import ColumnDataSource, Panel, CustomJS
from bokeh.models.widgets import TableColumn, DataTable, Paragraph, Button, Select
from bokeh.layouts import column, row, WidgetBox


class TableGenerator:
    def __init__(self, data):
        self.source = None
        self.carrier_table = None
        self.title = None
        self.df = data
        self.js_path = './bokeh_app/utils/download.js'

    def fetch_data(self, species):
        current = self.df[self.df['vernacularName'] == species]
        return current

    def make_table(self, current):
        table_columns = [TableColumn(field='eventID', title='eventID'),
                         TableColumn(field='id', title='id'),
                         TableColumn(field='時段', title='時段'),
                         TableColumn(field='距離', title='距離'),
                         TableColumn(field='Year', title='Year'),
                         TableColumn(field='Month', title='Month'),
                         TableColumn(field='locationID', title='locationID'),
                         TableColumn(field='Count', title='Count'),
                         TableColumn(field='vernacularName',
                                     title='vernacularName')
                         ]
        self.source = ColumnDataSource(data=current)
        self.title = Paragraph(text='Table')
        self.carrier_table = DataTable(source=self.source,
                                       columns=table_columns,
                                       fit_columns=True,
                                       selectable=True,
                                       sortable=False,
                                       width=1000
                                       )
        return column(self.title, self.carrier_table)

    def update(self, attrname, old, new):
        results = self.fetch_data(new)
        self.source.data.update(results)

    def species_select(self, species):
        options = pd.unique(self.df['vernacularName']).tolist()
        species_select = Select(title='Select a species:',
                                value=species, options=options)
        species_select.on_change('value', self.update)
        return species_select

    def readCustomJS(self):
        with open(self.js_path, 'r', encoding='UTF-8') as file:
            return file.read()

    def download_data_btn(self, current):
        source = ColumnDataSource(data=current)
        callback = CustomJS(args=dict(source=source), code=self.readCustomJS())
        button = Button(label='Download',
                        button_type='success', callback=callback)
        return button


def create_data_preview_tab(exp_data):
    t = TableGenerator(exp_data)

    species = '白頭翁'
    species_select = t.species_select(species)

    df = t.fetch_data(species)
    table = t.make_table(df)
    btn = t.download_data_btn(df)

    controls = WidgetBox(species_select, btn)
    layout = column(row(controls, table))

    tab = Panel(child=layout, title='Data Preview')
    return tab
