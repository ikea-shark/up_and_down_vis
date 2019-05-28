FROM python:latest

LABEL maintainer="minsiansu@gmail.com"

RUN apt-get update &&  apt-get install libjpeg-dev zlib1g-dev \
    && apt-get -yq autoremove \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --upgrade pip \
    && pip install -r requirements.txt \
    && rm -rf ~/.cache/pip

COPY . ./home/bokeh_app

WORKDIR /home

CMD bokeh serve --show bokeh_app

EXPOSE 5006