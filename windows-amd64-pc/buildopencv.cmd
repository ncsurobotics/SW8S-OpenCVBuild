@echo off
setlocal

:: Configuration
set CUDA=NO
set CUDNN=NO
set PYTHON3=YES
set PYTHON2=NO
set JAVA=YES


:: Shared configuration
for /f "delims=" %%L in (..\config.sh) do set %%L


:: Download and unzip sources
if not exist opencv-%VERSION%\ (
    echo https://github.com/opencv/opencv/archive/%VERSION%.zip
    curl -L --output opencv.zip https://github.com/opencv/opencv/archive/%VERSION%.zip
    curl -L --output opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/%VERSION%.zip
    tar -xf opencv.zip
    tar -xf opencv_contrib.zip
)

:: build
IF not DEFINED JAVA_HOME (
    FOR /f "tokens=* delims=" %%A in ('where java') do @set "JAVA_HOME=%%A"
)
rmdir .\build\ /s /q
mkdir build
cd build
cmake -D OPENCV_EXTRA_MODULES_PATH=../opencv_contrib-%VERSION%/modules ^
    -D WITH_CUDA=%CUDA% ^
    -D CUDA_ARCH_BIN=%CUDA_ARCH_BIN% ^
    -D CUDA_ARCH_PTX="" ^
    -D WITH_CUDNN=%CUDNN% ^
    -D OPENCV_DNN_CUDA=%CUDNN% ^
    -D ENABLE_FAST_MATH=ON ^
    -D CUDA_FAST_MATH=%CUDA% ^
    -D WITH_CUBLAS=%CUDA% ^
    -D WITH_GSTREAMER=ON ^
    -D WITH_GSTREAMER_0_10=OFF ^
    -D WITH_FFMPEG=ON ^
    -D WITH_QT=OFF ^
    -D WITH_OPENGL=OFF ^
    -D BUILD_opencv_python2=%PYTHON2% ^
    -D BUILD_opencv_python3=%PYTHON3% ^
    -D OPENCV_PYTHON_INSTALL_PATH=lib/python3.8/site-packages ^
    -D BUILD_TESTS=OFF ^
    -D BUILD_PERF_TESTS=OFF ^
    -D OPENCV_VCSVERSION=%VERSION% ^
    -DINSTALL_CREATE_DISTRIB=ON ^
    -DCMAKE_INSTALL_PREFIX=c:/opencv-%VERSION%/ ^
    -DCPACK_NSIS_INSTALL_ROOT=c:\\opencv-%VERSION% ^
    -DCPACK_PACKAGE_INSTALL_DIRECTORY= ^
    -DPYTHON_DEFAULT_AVAILABLE=ON ^
    -DBUILD_opencv_world=OFF ^
    ../opencv-%VERSION%

cmake --build . --config Release


:: Package
cmake --build . --config Release --target package