class Api:
    BBS = dict(
        GBIF_V1='http://api.gbif.org/v1',
        DATASET_KEY='datasetKey=f170f056-3f8a-4ef3-ac9f-4503cc854ce0',
        OCCURRENCE='/occurrence/search?',
        YEAR_RANGE=range(2009, 2016)
    )

    PARAMETERS = dict(
        YEAR='&year=',
        LIMIT='&limit=',
        OFFSET='&offset=',
    )
