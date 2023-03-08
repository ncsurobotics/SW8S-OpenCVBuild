@echo off

@rem Configuration
set BUILD_THREADS=4
set CUDA=NO
set CUDNN=NO
set PYTHON3=YES
set PYTHON2=NO
set JAVA=YES


@rem Shared configuration
for /f "delims=" %%L in (..\config.sh) do set %%L


@rem Download and unzip sources
if not exist opencv-%VERSION%\ (
    echo https://github.com/opencv/opencv/archive/%VERSION%.zip
    curl -L --output opencv.zip https://github.com/opencv/opencv/archive/%VERSION%.zip
    curl -L --output opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/%VERSION%.zip
) 