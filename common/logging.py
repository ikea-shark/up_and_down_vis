from logging import (
    basicConfig,
    info,
    error,
    INFO,
)

class Logger:
    def __init__(self):
        basicConfig(format='%(asctime)s [%(levelname)s]: %(message)s',
                        datefmt='%m/%d/%Y %I:%M:%S %p',
                        filename='log',
                        level=INFO)
    def error(self, msg):
        error(msg)

    def info(self, msg):
        info(msg)
