#!/usr/bin/env bash
set -e

readonly linux_pkgs=(
    python3
    python3-dev
    python3-pip
    python3-venv
    build-essential
    cmake
    git
    udev
)

readonly ubuntu_pkgs=(
    ${linux_pkgs[@]}
    # gfortran
    libatlas-base-dev
    libavcodec-dev
    libavformat-dev
    libavresample-dev
    libcanberra-gtk3-module
    libdc1394-22-dev
    libeigen3-dev
    libglew-dev
    libgstreamer1.0-dev
    libgstreamer-plugins-base1.0-dev
    libgstreamer-plugins-good1.0-dev
    libgtk-3-dev
    libjpeg-dev
    libjpeg8-dev
    libjpeg-turbo8-dev
    liblapack-dev
    liblapacke-dev
    libopenblas-dev
    libpng-dev
    libpostproc-dev
    libswscale-dev
    libtbb-dev
    libtbb2
    libtesseract-dev
    libtiff-dev
    libv4l-dev
    libxine2-dev
    libxvidcore-dev
    libx264-dev
    libgtkglext1
    libgtkglext1-dev
    pkg-config
    qv4l2
    v4l-utils
    zlib1g-dev
)

readonly ubuntu1804_pkgs=(
    ${ubuntu_pkgs[@]}
    python3.8
    python3.8-dev
    python3.8-venv
)

# Docker version doesn't require sudo
if [[ -f /.dockerenv ]] || grep -Eq '(lxc|docker|containerd)' /proc/1/cgroup; then
    echo "Installing Docker packages"
    source /etc/os-release

    case "$ID" in
    ubuntu)
        apt purge libopencv*
        apt update

        if [[ $VERSION_ID == "20.04" ]]; then
            echo -e "Installing Ubuntu 20.04 packages\n"
            apt install -y --no-install-recommends "${ubuntu_pkgs[@]}"
            python3 -m pip install -U pip setuptools wheel
        elif [[ $VERSION_ID == "18.04" ]]; then
            echo -e "Installing Ubuntu 18.04 packages\n"
             apt install -y --no-install-recommends "${ubuntu1804_pkgs[@]}"
            python3.8 -m pip install -U pip setuptools wheel
        fi
        ;;
    *)
        echo "ERROR: Distribution not supported"
        exit 99
        ;;
    esac
elif [[ ! $(uname -m) =~ ^arm* && -f /etc/os-release ]]; then
    echo -e "Installing desktop packages\n"
    source /etc/os-release

    case "$ID" in
    ubuntu|debian)
        sudo apt purge libopencv-dev libopencv-python libopencv-samples libopencv*

        if [[ $VERSION_ID == "20.04" ]]; then
            echo -e "Installing Ubuntu 20.04 packages\n"
            sudo apt install -y --no-install-recommends "${ubuntu_pkgs[@]}"
            python3 -m pip install -U pip setuptools wheel
        elif [[ $VERSION_ID == "18.04" ]]; then
            echo -e "Installing Ubuntu 18.04 packages\n"
            sudo apt install -y --no-install-recommends "${ubuntu1804_pkgs[@]}"
            python3.8 -m pip install -U pip setuptools wheel
        fi
        ;;
    *)
        echo "ERROR: Distribution not supported"
        exit 99
        ;;
    esac
else
    echo "ERROR: Host not supported"
    exit 99
fi
