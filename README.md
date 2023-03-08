# OpenCV Build Scripts

## linux-amd64-pc

- Build on a Linux system (assumed to be `amd64` / `x86_64`)
- Setup a chroot (to build on older distro for glibc compatibility)
    ```sh
    # Use different package manager if not debian based system
    sudo apt install schroot debootstrap

    # Make chroot
    sudo debootstrap --variant=buildd --arch=amd64 focal /srv/chroot/focal-amd64 http://archive.ubuntu.com/ubuntu/
    ```
- Write chroot config file `/etc/schroot/chroot.d/focal-amd64.conf`
    ```conf
    [focal-amd64]
    description=Ubuntu 20.04 (amd64)
    type=directory
    directory=/srv/chroot/focal-amd64
    users=[YOUR_USERNAME]
    root-groups=root
    profile=desktop
    personality=linux
    ```
- On more recent Ubuntu / Debian systems, `yescrypt` is used, but this is not supported in older systems (focal included). Thus change `/etc/pam.d/common-password` by modifying `yescrypt` to be `sha512`. Failing to do so will prevent `sudo` from working in the chroot environment.
- Enter chroot with `sudo schroot -c focal-amd64` and run
    ```sh
    sed -i 's/focal main/focal main universe multiverse/g' /etc/apt/sources.list
    apt update
    apt install sudo locales git python3 zip
    exit
    ```
- Enter the chroot without sudo `schroot -c focal-amd64`
- Run the build
    ```sh
    cd linux-amd64-pc
    ./buildopencv.sh | tee build.log
    cd build
    zip -0 linux-amd64-pc.zip OpenCV-*.deb OpenCV-*.tar.gz OpenCV-*.sh
    ```
- Upload the sh file



## linux-arm64-pc

- Build on a Linux system (assumed to be `amd64` / `x86_64`)
- Setup a chroot (to build on older distro for glibc compatibility)
    ```sh
    # Use different package manager if not debian based system
    sudo apt install schroot debootstrap qemu-user-static

    # Make chroot
    sudo debootstrap --variant=buildd --arch=arm64 focal /srv/chroot/focal-arm64 http://ports.ubuntu.com/ubuntu-ports
    ```
- Write chroot config file `/etc/schroot/chroot.d/focal-arm64.conf`
    ```conf
    [focal-arm64]
    description=Ubuntu 20.04 (arm64)
    type=directory
    directory=/srv/chroot/focal-arm64
    users=[YOUR_USERNAME]
    root-groups=root
    profile=desktop
    personality=linux
    ```
- On more recent Ubuntu / Debian systems, `yescrypt` is used, but this is not supported in older systems (focal included). Thus change `/etc/pam.d/common-password` by modifying `yescrypt` to be `sha512`. Failing to do so will prevent `sudo` from working in the chroot environment.
- Enter chroot with `sudo schroot -c focal-arm64` and run
    ```sh
    sed -i 's/focal main/focal main universe multiverse/g' /etc/apt/sources.list
    apt update
    apt install sudo locales git python3 zip
    exit
    ```
- Enter the chroot without sudo `schroot -c focal-arm64`
- Run the build
    ```sh
    cd linux-arm64-pc
    ./buildopencv.sh | tee build.log
    ```
- Upload the sh file


## linux-arm64-jetsonnano

TODO


## windows-amd64-pc

- Install the following
    - [CMake](https://cmake.org/): Make sure cmake is in your `PATH`
    - [Build Tools for Visual Studio](https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022)
    - [GStreamer](https://gstreamer.freedesktop.org/download/): Use the "MSVC development installer" and perform a "complete install"
    - [OpenJDK 11](https://adoptium.net/): Make sure `JAVA_HOME` is set to the directory java is installed in (not the bin, the root directory). Alternatively, you can make sure the desired java is in your `PATH`.
    - [Apache ANT](https://ant.apache.org/bindownload.cgi): Make sure `ant` is in your path
    - [Python 3.8](https://www.python.org/): Make sure `python` or `python3` command is in your `PATH`. Make sure the version you want to use is in the path first (shown first by `where.exe python`)
- Note that the build script requires Windows 10 17063 or later which includes curl and bsdtar
- Run the build
    ```sh
    cd windows-arm64-pc
    .\buildopencv.cmd
    cd build
    ```
- Upload the installer
