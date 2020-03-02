from math import floor
from json import loads

import pandas as pd
from requests import get

from common import logging
from common import Api
from common.save import to_csv, to_sqlite


class FetchApi:
    def __init__(self, year, limit, get_all, save):
        self.log = logging.Logger()
        self.year = year
        self.limit = limit
        self.get_all = get_all
        self.save = str(save)
        self.max_records = 200000  # maximum records = limit + offset (see: https://www.gbif.org/developer/occurrence#search)
        self.url = Api.BBS['GBIF_V1'] + Api.BBS['OCCURRENCE'] + Api.BBS['DATASET_KEY']

    def _get_url(self):
        try:
            with_year = self.url + Api.PARAMETERS['YEAR'] + str(self.year)
            json = loads(get(with_year).text)
            if self.get_all:
                self.total_counts = json['count']
                self.max_offset = floor(self.total_counts / self.limit)
                if self.max_offset > self.max_records:
                    msg = 'Data are larger than max_records: {}'.format(self.max_records)
                    self.log.error(msg)
                    raise ValueError(msg)
                occurrence_all = list()
                for offset in range(self.max_offset):
                    occurrence_api = self.url + \
                                     Api.PARAMETERS['YEAR'] + str(self.year) + \
                                     Api.PARAMETERS['LIMIT'] + str(self.limit) + \
                                     Api.PARAMETERS['OFFSET'] + str(offset)
                    occurrence_all.append(occurrence_api)
            else:
                occurrence_all = self.url + \
                                 Api.PARAMETERS['YEAR'] + str(self.year) + \
                                 Api.PARAMETERS['LIMIT'] + str(self.limit)

        except Exception as e:
            self.log.error('Cannot get urls')
            return e
        return occurrence_all

    @staticmethod
    def fetch(url):
        try:
            json = loads(get(url, '{}').text)['results']
        except Exception as e:
            print(e)
        return json

    @staticmethod
    def df_clean(df):
        copied = df.copy()
        copied = df[
            ['individualCount',
             'decimalLongitude',
             'decimalLatitude',
             'year',
             'month',
             'day',
             'class',
             'eventID',
             'recordedBy',
             'vernacularName',
             'locationID',
             ]
        ].dropna(how='all')
        return copied

    def get_records(self):
        try:
            url_list = self._get_url()
            if self.get_all:
                result = []
                for i, item in enumerate(url_list):
                    msg = 'nowProcessing: {0}, ' \
                          'year: {1}, ' \
                          'limit: {2}, ' \
                          'maxOffset: {3}, ' \
                          'totalCounts: {4}'.format(i, self.year, self.limit, self.max_offset, self.total_counts)
                    print(msg)
                    self.log.info(msg)
                    json = self.fetch(item)
                    df = pd.DataFrame.from_dict(json)
                    cleaned = self.df_clean(df)
                    if self.save is 'txt':
                        to_csv(cleaned)
                    if self.save is 'sql':
                        to_sqlite(cleaned)
            else:
                msg = 'year: {0}, limit: {1}'.format(self.year, self.limit)
                print(msg)
                self.log.info(msg)
                json = self.fetch(url_list)
                df = pd.DataFrame.from_dict(json)
                cleaned = self.df_clean(df)
                if 'txt' in self.save:
                    to_csv(cleaned)
                if 'sql' in self.save:
                    to_sqlite(cleaned)
        except Exception as e:
            self.log.error('Cannot get records')
            return e
        return cleaned
