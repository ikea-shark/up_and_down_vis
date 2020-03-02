FROM python:3.6-slim AS base-image

WORKDIR root

ENV PATH=$PATH:/root

COPY requirements.txt ./

RUN \
  mkdir -p ./data && \
  apt-get update && \
  pip install --no-cache-dir  --upgrade pip && \
  pip install --no-cache-dir --user -r ./requirements.txt

COPY . ./

VOLUME ./data ./data

CMD ['python3', 'data.py', '--help']
