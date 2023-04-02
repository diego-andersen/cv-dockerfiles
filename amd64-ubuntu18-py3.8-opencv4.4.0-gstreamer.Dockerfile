FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ARG APPDIR=/app
ARG VIRTUAL_ENV=${APPDIR}/.venv
ARG OPENCV_VERSION="4.4.0"
ARG N_PROC=8

WORKDIR /tmp

# System-level dependencies
COPY ./provisioning/install_dependencies.sh ./install_dependencies.sh
RUN DEBIAN_FRONTEND=noninteractive ./install_dependencies.sh \
    && rm -rf /var/lib/apt/lists/* \
    && apt clean

# Python env
RUN mkdir ${APPDIR} && python3.8 -m venv $VIRTUAL_ENV
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN pip install -U pip setuptools wheel numpy

COPY ./provisioning/install_opencv.sh ./install_opencv.sh
RUN ./install_opencv.sh -j ${N_PROC} --gstreamer \
    && rm -rf /tmp/*

WORKDIR /app
