#!/usr/bin/env bash

# Exit on any error
function exit_trap(){
    ec=$?
    if [ $ec -ne 0 ]; then
        echo "\"${last_command}\" command failed with exit code $ec."
    fi
}
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap exit_trap EXIT

# Dependencies
sudo apt install -y cmake build-essential openjdk-11-jdk python3 libpython3.8-dev python3-numpy ant ffmpeg libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev wget unzip pkg-config libavutil-dev libavcodec-dev libavformat-dev libswscale-dev libavresample-dev

# Configuration
BUILD_THREADS=4
CC=$(which gcc)                 # Use gcc-7 on jetson nano
CXX=$(which g++)                # Use g++-7 on jetson nano
CUDA=NO
CUDA_ARCH_BIN=5.3               # 5.3 for jetson nano0
CUDNN=NO
PYTHON3=YES
PYTHON2=NO
JAVA=YES
DEB_PKG=NO

# Shared configuration
source ../config.sh

# Download and unzip sources

if [ ! -d opencv-${VERSION}/ ];then
    wget -O opencv.zip https://github.com/opencv/opencv/archive/${VERSION}.zip
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${VERSION}.zip
    unzip opencv.zip
    unzip opencv_contrib.zip
fi

# Build
if [[ ! -v JAVA_HOME ]]; then
    JAVA_HOME=$(dirname $(dirname $(realpath $(which java))))
fi
rm -rf build/
mkdir -p build
cd build
cmake -D CMAKE_BUILD_TYPE=Release \
    -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-${VERSION}/modules \
    -D WITH_CUDA=$CUDA \
    -D CUDA_ARCH_BIN=$CUDA_ARCH_BIN \
    -D CUDA_ARCH_PTX="" \
    -D WITH_CUDNN=$CUDNN \
    -D OPENCV_DNN_CUDA=$CUDNN \
    -D ENABLE_FAST_MATH=ON \
    -D CUDA_FAST_MATH=$CUDA \
    -D WITH_CUBLAS=$CUDA \
    -D WITH_LIBV4L=ON \
    -D WITH_V4L=ON \
    -D WITH_GSTREAMER=ON \
    -D WITH_GSTREAMER_0_10=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_QT=OFF \
    -D WITH_OPENGL=OFF \
    -D BUILD_opencv_python2=$PYTHON2 \
    -D BUILD_opencv_python3=$PYTHON3 \
    -D BUILD_TESTS=OFF \
    -D BUILD_PERF_TESTS=OFF \
    -D CMAKE_C_COMPILER=$CC \
    -D CMAKE_CXX_COMPILER=$CXX \
    -D CPACK_BINARY_DEB=$DEB_PKG \
    -D OPENCV_VCSVERSION=$VERSION \
    -D ANT_EXECUTABLE:FILEPATH=$(realpath $(which ant)) \
    -D CPACK_PACKAGING_INSTALL_PREFIX=/opt/opencv-${VERSION}/ \
    ../opencv-${VERSION}
make -j ${BUILD_THREADS}


# Pacakge
ORIG_LD_LIB=$(echo $LD_LIBRARY_PATH)
export LD_LIBRARY_PATH=$(pwd)/lib
cmake --build . --target package
export LD_LIBRARY_PATH=$ORIG_LD_LIB
