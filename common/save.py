import sqlite3


def to_csv(df):
    df.to_csv('bbs_data', index=False, mode='a', header=False)


def to_sqlite(df):
    con = sqlite3.connect('bbs_data.sqlite')
    df.to_sql("bbs", con, if_exists="append")
