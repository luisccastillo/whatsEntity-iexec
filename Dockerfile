FROM ubuntu:20.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    libatlas-base-dev \
    && rm -rf /var/lib/apt/lists/* && \
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /root/miniconda

ENV PATH=/root/miniconda/bin:$PATH
ENV CONDA_AUTO_UPDATE_CONDA="false"

#ENV LD_LIBRARY_PATH=/lib:/lib/x86_64-linux-gnu:/lib64:/usr/lib/x86_64-linux-gnu/
RUN conda install -c conda-forge conda-forge::spacy
RUN python -m spacy download en_core_web_trf

COPY ./src /app

ENTRYPOINT ["/root/miniconda/bin/python3.9", "/app/app.py"]
