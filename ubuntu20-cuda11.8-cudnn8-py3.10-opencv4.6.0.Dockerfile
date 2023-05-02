FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu20.04

ENV DEBIAN_FRONTEND=noninteractive
ARG OPENCV_VERSION=4.6.0
ARG NPROC=1

# Dependencies - software-properties-common required for PPAs
RUN apt update \
    && apt upgrade -y \
    && apt install -y --no-install-recommends \
    # System dependencies
    build-essential \
    gfortran \
    cmake \
    git \
    udev \
    pkg-config \
    software-properties-common \
    # OpenCV dependencies
    ffmpeg \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libavresample-dev \
    libcanberra-gtk3-module \
    libdc1394-22-dev \
    libeigen3-dev \
    libglew-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-good1.0-dev \
    libgtk-3-dev \
    libgtkglext1 \
    libgtkglext1-dev \
    libjpeg-dev \
    libjpeg8-dev \
    libjpeg-turbo8-dev \
    liblapack-dev \
    liblapacke-dev \
    libopenblas-dev \
    libpng-dev \
    libpostproc-dev \
    libswscale-dev \
    libtbb2 \
    libtbb-dev \
    libtesseract-dev \
    libtiff-dev \
    libva-dev \
    libv4l-dev \
    libxine2-dev \
    libxvidcore-dev \
    libx264-dev \
    qv4l2 \
    v4l-utils \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt clean

# Python venv and dependencies
WORKDIR /app
ENV PATH="/app/.venv/bin:$PATH"

RUN add-apt-repository -y ppa:deadsnakes/ppa \
    && apt install -y python3.10 python3.10-venv python3.10-dev \
    && python3.10 -m venv /app/.venv \
    && pip install -U pip setuptools wheel "numpy>=1.22" pycuda

# Clone, build, install, clean up OpenCV
WORKDIR /tmp

RUN git clone --depth 1 -b ${OPENCV_VERSION} https://github.com/opencv/opencv.git \
    && git clone --depth 1 -b ${OPENCV_VERSION} https://github.com/opencv/opencv_contrib.git

WORKDIR /tmp/opencv/build

RUN cmake \
    -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D CPACK_BINARY_DEB=ON \
    -D OPENCV_ENABLE_NONFREE=ON \
    -D OPENCV_EXTRA_MODULES_PATH=/tmp/opencv_contrib/modules \
    -D OPENCV_GENERATE_PKGCONFIG=ON \
    -D OPENCV_DNN_CUDA=ON \
    -D BUILD_EXAMPLES=OFF \
    -D BUILD_JAVA=OFF \
    -D BUILD_opencv_python2=OFF \
    -D BUILD_opencv_python3=ON \
    -D BUILD_PERF_TESTS=OFF \
    -D BUILD_TESTS=OFF \
    -D BUILD_TIFF=ON \
    -D ENABLE_NEON=OFF \
    -D PYTHON3_EXECUTABLE=$(command -v python) \
    -D PYTHON3_INCLUDE_DIR=$(python -c 'from distutils.sysconfig import get_python_inc; print(get_python_inc())') \
    -D PYTHON3_PACKAGES_PATH=$(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())') \
    -D WITH_CUDA=ON \
    -D WITH_CUDNN=ON \
    -D WITH_CUBLAS=ON \
    -D WITH_EIGEN=ON \
    -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
    -D WITH_GSTREAMER=ON \
    -D WITH_IPP=OFF \
    -D WITH_LAPACK=ON \
    -D WITH_OPENGL=OFF \
    -D WITH_OPENCL=OFF \
    -D WITH_QT=OFF \
    -D WITH_TBB=ON \
    -D WITH_VA=ON \
    -D WITH_V4L=ON \
    .. \
    && make -j ${NPROC} \
    && make install \
    && ldconfig \
    && cd / \
    && rm -rf /tmp/opencv*

WORKDIR /app
