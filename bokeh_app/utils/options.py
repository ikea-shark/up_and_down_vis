import pandas as pd

exp_data = pd.read_csv(join(dirname(__file__), 'data/exp_data.csv'))
exp_data.dropna(inplace=True)

options = pd.unique(exp_data['vernacularName']).tolist()
