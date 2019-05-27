FROM python:latest

LABEL maintainer="minsiansu@gmail.com"

RUN apt-get update && \ 
    apt-get install -y libjpeg-dev zlib1g-dev python-pip && \ 
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY . /bokeh_app

RUN pip install --upgrade pip \
    && pip install -r bokeh_app/requirements.txt \
    && rm -rf ~/.cache/pip

ENV ORIGIN="127.0.0.1:5006" PORT="5006" PREFIX="" LOG_LEVEL="info"

CMD bokeh serve --show bokeh_app