#!/usr/bin/env bash
set -e

usage()
{
cat << EOF
Usage: $0 [--gpu|--gstreamer|--contrib]

Build OpenCV from source and install it to /usr/local.

OPTIONS:
    -h|--help    Print help and exit
    -j|--jobs    Number of make jobs (same as make -j)
    --gpu        Include GPU support (CUDA)
    --gstreamer  Include gstreamer support
    --contrib    Include opencv-contrib
EOF
}

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --gpu) add_gpu=1 ;;
        --gstreamer) add_gstreamer=1 ;;
        --contrib) add_contrib=1 ;;
        -j|--jobs) n_make_jobs=$2; shift ;;
        -h|--help) usage; exit ;;
        *) echo "Unknown parameter: $1"; usage; exit 1 ;;
    esac
    shift
done

git clone --depth 1 -b $OPENCV_VERSION https://github.com/opencv/opencv.git

# Ignore spaces inside array values
IFS=""

cmake_flags=(
    # General config
    "-D CMAKE_BUILD_TYPE=RELEASE"
    "-D CMAKE_INSTALL_PREFIX=/usr/local"
    "-D OPENCV_GENERATE_PKGCONFIG=ON"
    "-D CPACK_BINARY_DEB=ON"
    "-D BUILD_PERF_TESTS=OFF"
    "-D BUILD_TESTS=OFF"
    "-D BUILD_EXAMPLES=OFF"
    "-D INSTALL_PYTHON_EXAMPLES=OFF"
    "-D INSTALL_C_EXAMPLES=OFF"
    "-D BUILD_OPENCV_JAVA=OFF"

    # Python config
    "-D BUILD_opencv_python2=OFF"
    "-D BUILD_opencv_python3=ON"
    "-D PYTHON3_EXECUTABLE=$(command -v python)"
    "-D PYTHON3_INCLUDE_DIR=$(python -c 'from distutils.sysconfig import get_python_inc; print(get_python_inc())')"
    "-D PYTHON3_PACKAGES_PATH=$(python -c 'from distutils.sysconfig import get_python_lib; print(get_python_lib())')"

    # Optional modules
    "-D WITH_EIGEN=ON"
    "-D EIGEN_INCLUDE_PATH=/usr/include/eigen3"
    "-D ENABLE_NEON=OFF"
    "-D WITH_GSTREAMER=ON"
    "-D WITH_V4L=ON"
    "-D WITH_OPENGL=ON"
    "-D WITH_OPENCL=OFF"
    "-D WITH_IPP=OFF"
    "-D WITH_TBB=ON"
    "-D WITH_QT=OFf"
    "-D BUILD_TIFF=ON"
)

# Check for CUDA
if [ -v add_gpu ]
then
cmake_flags=(
    ${cmake_flags[@]}
    "-D WITH_CUDA=ON"
)
else
cmake_flags=(
    ${cmake_flags[@]}
    "-D WITH_CUDA=OFF"
)
fi

# Check for gstreamer
if [ -v add_gstreamer ]
then
cmake_flags=(
    ${cmake_flags[@]}
    "-D WITH_GSTREAMER=ON"
)
else
cmake_flags=(
    ${cmake_flags[@]}
    "-D WITH_GSTREAMER=OFF"
)
fi

# Check for non-free modules
if [ -v add_contrib ]
then
git clone --depth 1 -b ${OPENCV_VERSION} https://github.com/opencv/opencv_contrib.git

cmake_flags=(
    ${cmake_flags[@]}
    "-D OPENCV_ENABLE_NONFREE=ON"
    "-D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib/modules"
)
else
cmake_flags=(
    ${cmake_flags[@]}
    "-D OPENCV_ENABLE_NONFREE=OFF"
)
fi

cd opencv
mkdir build
cd build

cmake "${cmake_flags[@]}" ..
make -j ${n_make_jobs:-8}
make install
ldconfig
