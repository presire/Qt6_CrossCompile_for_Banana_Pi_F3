# Qt CrossCompile for Banana Pi F3 (RISC-V)
Revision Date: 2025/11/21<br>
<br><br>

# Overview
This document describes the procedure for cross-compiling general desktop software and embedded/device creation use cases on Banana Pi equipped with RISC-V.<br>
<br>
Embedded/device creation refers to use cases where desktop software runs full-screen on EGL, rather than under X11/Wayland.<br>
<br>
<u>When using EGL, Qt software only operates in full-screen mode.</u><br>
<u>Note that to launch in a typical desktop window, XCB must be used, but XCB does not support OpenGL or Qt Quick.</u><br>
<br>
<u>This guide assumes that Armbian Trixie is installed on the Banana Pi.</u><br>
<br>

### Reference Books
**Introducing Qt 6: Learn to Create Modern GUI Applications Using C++**<br>
https://www.amazon.com/dp/148427489X

**Cross-Platform Development with Qt 6 and Modern C++: Design and build applications with modern graphical user interfaces**<br>
https://www.amazon.com/dp/1800204582

**A Guide to Qt 6: For Beginners**<br>
https://www.amazon.com/dp/B08XLLDZSG

<br><br>

# 1. Host PC Configuration
On the host PC, install the libraries required for cross-compilation.<br>
(It is recommended to install Texinfo from the GNU official website by building from source code)<br>

```bash
sudo zypper install \
     autoconf automake cmake unzip tar git wget pkg-config gperf gcc gcc-c++ \
     gawk bison openssl flex figlet pigz ncurses-devel ncurses5-devel texinfo

     # If installing QtWebEngine
     libicu-devel libopus-devel openjpeg2-devel pciutils-devel libpciaccess-devel libxshmfence-devel \
     libvpx-devel python3-html5lib

     # If installing QtWebEngine (Default packages)
     ffmpeg-4-libavcodec-devel ffmpeg-4-libavdevice-devel ffmpeg-4-libavfilter-devel ffmpeg-4-libavformat-devel    \
     ffmpeg-4-libavresample-devel ffmpeg-4-libavutil-devel ffmpeg-4-libpostproc-devel ffmpeg-4-libswresample-devel \
     ffmpeg-4-libswscale-devel ffmpeg-4-private-devel
     
     # If installing QtWebEngine (Packman packages)
     ffmpeg-6-libavcodec-devel ffmpeg-6-libavdevice-devel ffmpeg-6-libavfilter-devel ffmpeg-6-libavformat-devel    \
     ffmpeg-6-libavresample-devel ffmpeg-6-libavutil-devel ffmpeg-6-libpostproc-devel ffmpeg-6-libswresample-devel \
     ffmpeg-6-libswscale-devel ffmpeg-6-private-devel
```
<br>

<u>GCC 8 or later is required for the GCC RISC-V 64 cross toolchain.</u><br>
<u>Since a GCC RISC-V 64 cross toolchain is not provided, developers need to create it themselves.</u><br>
<br>
<u>To create a GCC RISC-V 64 cross toolchain, please refer to the installation guide for GCC cross-compiler toolchains.</u><br>
<br>
<u>**Note:**</u><br>
<u>For the libstdc++.so.6 file in the cross compiler, you must use a version equal to or older than the libstdc++.so.6 file in Armbian.</u><br>
<u>For example, Armbian Trixie's libstdc++.so.6 file supports up to GLIBCXX_3.4.36, so use the GCC 15 toolchain or earlier.</u><br>
<br>
The GCC RISC-V 64 cross toolchain is built using system-specific LTO (Link Time Optimization) flags, allowing you to easily utilize Armbian's SoC-specific features when compiling software using these toolchains.<br>
<br>

**Table: Banana Pi and LTO (Link Time Optimization) Flags**

| Banana Pi Type | LTO (Link Time Optimization) Flags |
|---|---|
| Banana Pi F3 | -march=rv64gc -mabi=lp64d<br><br># Including vector extensions, if supported<br>-march=rv64gcv -mabi=lp64d |

<br><br>

# 2. Banana Pi Configuration
Uncomment the lines starting with deb-src in the /etc/apt/sources.list file.<br>

```bash
sudo vi /etc/apt/sources.list
```
<br>

```bash
# /etc/apt/sources.list file

# For Bullseye
## Before editing
#deb-src http://deb.debian.org/debian unstable main contrib non-free non-free-firmware

## After editing
deb-src http://deb.debian.org/debian unstable main contrib non-free non-free-firmware
```
<br>

Update Armbian software.<br>

```bash
sudo apt update
sudo apt upgrade
sudo reboot
```
<br>

Install Qt libraries on Armbian.<br>
The `build-dep` command installs all packages required for building.<br>
Depending on the build configuration, some unnecessary packages may be included.<br>
<br>

**Armbian Trixie**

```bash
## When using EGL
sudo apt install \
     ccache libicu-dev icu-devtools libb2-dev libsctp1 libsctp-dev libzstd1 libzstd-dev libhidapi-dev \
     libinput-bin libinput-dev libts0 libts-bin libts-dev libmtdev1 libmtdev-dev libevdev2 libevdev-dev \
     libblkid-dev libffi-dev libglib2.0-dev libglib2.0-dev-bin libmount-dev \
     libpcre2-8-0 libpcre2-16-0 libpcre2-32-0 libpcre2-dev libsepol-dev libselinux1-dev libwacom-dev \
     libfontconfig1-dev libdbus-1-dev libxkbcommon-dev libjpeg-dev libasound2-dev libudev-dev           \
     libssl-dev libssl1.0-dev libnss3-dev gdbserver \
     libgles2-mesa-dev libxcb-xinerama0 libxcb-xinerama0-dev libgles2-mesa-dev libgbm-dev
     
     # If using GTK native theme for QtWidget
     libgtk-3-dev 

## When using XCB
sudo apt install \
     ccache libicu-dev icu-devtools libb2-dev libsctp1 libsctp-dev libzstd1 libzstd-dev libhidapi-dev \
     libinput-bin libinput-dev libts0 libts-bin libts-dev libmtdev1 libmtdev-dev libevdev2 libevdev-dev \
     libblkid-dev libffi-dev libglib2.0-dev libglib2.0-dev-bin libmount-dev \
     libpcre2-8-0 libpcre2-16-0 libpcre2-32-0 libpcre2-dev libsepol-dev libselinux1-dev libwacom-dev \
     libfontconfig1-dev libdbus-1-dev libxkbcommon-dev libjpeg-dev libasound2-dev libudev-dev libgles2-mesa-dev \
     libxcb-xinerama0 libxcb-xinerama0-dev libssl-dev libssl1.0-dev libnss3-dev gdbserver \
     libx11-dev libxcb1-dev libxext-dev libxi-dev libxcomposite-dev libxcursor-dev libxtst-dev libxrandr-dev \
     libfreetype6-dev libx11-xcb-dev libxext-dev libxfixes-dev libxi-dev libxrender-dev libxcb1-dev \
     libxcb-glx0-dev libxcb-keysyms1-dev libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev \
     libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev libxcb-render-util0-dev libxcb-util0-dev \
     libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev libfontconfig1-dev libgles2-mesa-dev libgbm-dev

     # If using GTK native theme for QtWidget
     libgtk-3-dev
```
<br>

```bash
# Others
sudo apt build-dep libqt6webengine-data  # If using WebEngine
```
<br>

If you want to use multimedia, Bluetooth, etc., install any of the optional packages shown in the table below.<br>

**Other Libraries (Optional)**

| Feature | Libraries to Install | configure Script Options |
|---|---|---|
| Bluetooth | bluez bluez-tools libbluetooth-dev | |
| Images | libjpeg-dev libpng-dev libtiff-dev libwebp-dev libmng-dev libjasper-dev | |
| Codecs | libavcodec-dev libavformat-dev libswscale-dev libv4l-dev libxvidcore-dev libx264-dev libx265-dev | |
| Multimedia | libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev gstreamer1.0-plugins-base gstreamer1.0-plugins-good<br>gstreamer1.0-plugins-ugly gstreamer1.0-plugins-bad gstreamer1.0-pulseaudio<br>gstreamer1.0-tools gstreamer1.0-alsa<br>libwayland-dev (Wayland development package is required for gstreamer headers)<br><br><u>**Note:**</u><br><u>When installing the library shown below, the Qt D-Bus library is also installed as a dependency.</u><br><u>However, if the Qt D-Bus library exists, cross-building the Qt library may fail.</u><br>libgstreamer-plugins-bad1.0-dev | |
| ALSA Audio | libasound2-dev | |
| Pulse Audio | pulseaudio libpulse-dev | |
| OpenAL Audio | libopenal-data libopenal1 libopenal-dev libsndio7.0 libsndio-dev | |
| FFmpeg | * libavcodec-dev : Audio/video codec functionality<br>* libavformat-dev : Media container format processing<br>* libavutil-dev : FFmpeg common utility functions<br>* libswscale-dev : Image scaling and color space conversion<br>* libswresample-dev : Audio resampling functionality<br>* libavdevice-dev : Media input/output device support<br><br>To enable VAAPI support (hardware acceleration):<br>libva-dev libdrm-dev | |
| Database | unixodbc-dev (ODBC)<br>libsqlite3-dev (SQLite)<br>libpq-dev(PostgreSQL)<br>libmariadb-dev(MariaDB / MySQL) | |
| Printer | libcups2-dev | |
| Qt Speech | flite1-dev | |
| Qt GamePad | libsdl2-dev | |
| Wayland | libwayland-dev libwayland-dev waylandpp-dev libwayland-egl-backend-dev | |
| Vulkan | libvulkan-dev | |
| Double Conversion (Double precision floating point) | libdouble-conversion-dev | |
| Harfbuzz (Text rendering engine) | libharfbuzz-dev | |

<br><br>

# 3. Qt Source Code Download (Host PC)
Download the Qt source code on the host PC.<br>

```bash
# Enter the download directory
cd ~

# Download Qt source code
wget https://download.qt.io/archive/qt/6.9/6.9.1/single/qt-everywhere-src-6.9.1.tar.xz

# Extract Qt source code
tar xf qt-everywhere-src-6.9.1.tar.xz
```
<br>

When cross-compiling with Qt 6, the Qt library for x86_64 is also required.<br>
Therefore, install the Qt libraries for x86_64 using the Qt online installer.<br>
<br>
**You can also build and install the Qt 6 library for x86_64 from Qt 6 source code, but this is not recommended due to complexity.**<br>
**Here, the Qt library for host PC (x86_64) is installed from the Qt online installer.**<br>
<br>

```bash
wget http://download.qt.io/official_releases/online_installers/qt-unified-linux-x64-online.run
```
<br>

Add execute permission to the downloaded file.<br>

```bash
chmod +x qt-unified-linux-x64-online.run
```
<br>

Run the Qt online installer.<br>

```bash
./qt-unified-linux-x64-online.run
```
<br>

Follow the Qt installation screen to install Qt 6.<br>
<u>*Be sure to match the version of Qt 6 you are cross-compiling.*</u><br>
<br><br>

# 4. Create Banana Pi System Root Directory (Host PC)
On the host PC, create a system root directory.<br>

```bash
sudo mkdir -p /BananaPi
```
<br>

Install rsync on both the host PC and Banana Pi.<br>

```bash
# Host PC (openSUSE example)
sudo zypper install rsync

# Banana Pi
sudo apt install rsync
```
<br>

On the host PC, synchronize the Banana Pi's /lib and /usr directories to the system root directory.<br>
*This may take about 30 to 60 minutes.*<br>

```bash
sudo rsync -avz --rsync-path="sudo rsync" --delete \
<Banana Pi User Name>@<Banana Pi IP Address or Host Name>:/lib/ /BananaPi/lib

sudo rsync -avz --rsync-path="sudo rsync" --delete \
<Banana Pi User Name>@<Banana Pi IP Address or Host Name>:/usr/ /BananaPi/usr
```
<br>

Convert absolute symbolic links in the system root directory to relative symbolic links.<br>
*This is very important.*<br>

```bash
wget https://raw.githubusercontent.com/abhiTronix/rpi_rootfs/master/scripts/sysroot-relativelinks.py

sudo chmod +x sysroot-relativelinks.py

sudo ./sysroot-relativelinks.py /BananaPi
```
<br><br>

# 5. Create qmake.conf and qplatformdefs.h Files for Cross-Compilation (Host PC)
On the host PC, go to the Qt source code directory and create a new device directory.<br>

```bash
cd ~/qt-everywhere-src-6.9.1/qtbase/mkspecs/devices
sudo mkdir linux-bananapi-g++
cd linux-bananapi-g++
```
<br>

**Please refer to the attached files for the contents of qmake.conf and qplatformdefs.h:**
* **qmake.conf** - Configuration file for RISC-V64 with vector extension support
* **qplatformdefs.h** - Platform definitions header file

Copy these files to the linux-bananapi-g++ directory you just created.

```bash
# Copy the attached files to the device directory
sudo cp /path/to/qmake.conf ./
sudo cp /path/to/qplatformdefs.h ./
```
<br>

**Note:** The attached qmake.conf file includes RISC-V64 vector extension 1.0 support (`-march=rv64gcv`), which enables SIMD vector operations for improved performance. If your hardware or toolchain doesn't support vector extensions, you can modify the COMPILER_FLAGS in qmake.conf to use `-march=rv64gc` instead.

<br><br>

# 6. Build Qt Libraries (Host PC)
On the host PC, create a directory for installing Qt libraries for Banana Pi.<br>

```bash
mkdir -p ~/InstallSoftware/BananaPi_Qt6
```
<br>

Create a build directory and go to it.<br>

```bash
cd ~/qt-everywhere-src-6.9.1
mkdir build_bananapi
cd build_bananapi
```
<br>

Set environment variables.<br>

```bash
export QT6DIR=/path/to/your/Qt/Install_directory
export QT6DEPLOYDIR=/path/to/your/Qt/deploy_directory
export SYSROOT=/path/to/your/Banana Pi F3 System Root directory
export CROSS_COMPILER=/path/to/your/toolchain/bin/riscv64-linux-gnu-
```
<br>

Run CMake configure.<br>
Modify the following CMake options according to your environment:<br>
* CMAKE_C_COMPILER
* CMAKE_CXX_COMPILER
* QT_HOST_PATH
* CMAKE_STAGING_PREFIX
* CMAKE_INSTALL_PREFIX
* CMAKE_PREFIX_PATH

```bash
    cmake                       \
    ../qt-everywhere-src-6.9.1  \
    -GNinja                     \
    -DCMAKE_BUILD_TYPE=Release  \
    -DINPUT_opengl=es2          \
    -DQT_FEATURE_opengles2=ON   \
    -DQT_FEATURE_opengles3=ON   \
    -DQT_FORCE_BUILD_TOOLS=ON   \
    -DCMAKE_TOOLCHAIN_FILE="$CROSSDIR/ToolChain_for_Banana_Pi_F3.cmake" \
    -DQT_QMAKE_TARGET_MKSPEC=devices/linux-bananapi-g++     \
    -DQT_QMAKE_DEVICE_OPTIONS=CROSS_COMPILE=$CROSS_COMPILER \
    -DQT_BUILD_EXAMPLES=OFF         \
    -DQT_BUILD_TESTS=OFF            \
    -DQT_BUILD_TESTS_BY_DEFAULT=OFF \
    -DBUILD_qtdoc=OFF               \
    -DBUILD_qtlocation=OFF          \
    -DBUILD_qtwebengine=OFF         \
    -DBUILD_qtwebview=OFF           \
    -DBUILD_qtwebchannel=OFF        \
    -DBUILD_qtopcua=OFF             \
    -DBUILD_qtquick3dphysics=OFF    \
    -DCMAKE_SYSROOT=$SYSROOT        \
    -DQT_HOST_PATH=$QT6DIR/6.9.1/gcc_64                     \
    -DQT_HOST_PATH_CMAKE_DIR=$QT6DIR/6.9.1/gcc_64/lib/cmake \
    -DCMAKE_STAGING_PREFIX=$QT6DEPLOYDIR                    \
    -DCMAKE_INSTALL_PREFIX=$QT6DEPLOYDIR                    \
    -DCMAKE_PREFIX_PATH=$SYSROOT/usr/lib/riscv64-linux-gnu  \
```
<br>

Build and install Qt libraries.<br>

```bash
cmake --build . --parallel $(nproc)
cmake --install .
```
<br>

Go to the cross-compiled Qt 6 installation directory and create a symbolic link.<br>

```bash
cd ~/InstallSoftware/BananaPi_Qt6/bin
ln -s host-qmake qmake-host
```
<br><br>

# 7. Upload Qt Library to Banana Pi (Host PC)
Create a directory on Banana Pi for installing Qt libraries.<br>

```bash
# On Banana Pi
mkdir -p ~/InstallSoftware/Qt6
```
<br>

Deploy the built Qt library to Banana Pi from the host PC.<br>

```bash
# On Host PC
rsync -avz --rsh="ssh" --delete ~/InstallSoftware/BananaPi_Qt6/* \
<Banana Pi User Name>@<Banana Pi IP Address or Host Name>:/home/<Banana Pi User Name>/InstallSoftware/Qt6
```
<br><br>

# 8. JetBrains CLion Configuration
## 8.1 Creating Toolchain
Launch CLion and select [File] menu - [Settings].<br>
Select [Build, Execution, Deployment] - [Toolchains] in the left pane of the [Settings] screen.<br>
Click the [+] icon in the right pane of the [Settings] screen and select [System].<br>
<br>

**Toolchain Configuration Items:**

* **Name:**
  * Enter an arbitrary name. (e.g., BananaPi_GCC)

* **Credentials:** Pull-down
  * Local (System) (do not change)

* **CMake:** Pull-down
  * Select Bundled or the path to cmake command

* **Build Tool:** Pull-down
  * Select the path to make/ninja command

* **C Compiler:**
  * Enter the path to the GCC file used to build the Qt library for Banana Pi.
  * Example: /path/to/toolchain/bin/riscv64-linux-gnu-gcc

* **C++ Compiler:**
  * Enter the path to the G++ file used to build the Qt library for Banana Pi.
  * Example: /path/to/toolchain/bin/riscv64-linux-gnu-g++

* **Debugger:** Pull-down
  * Select [Custom GDB Executable] and enter the path to the GDB file
  * Example: /path/to/toolchain/bin/riscv64-linux-gnu-gdb

<br>

Press the [Apply] button at the bottom right of the [Settings] screen.<br>
<br>

## 8.2 CMake Configuration
Select [Build, Execution, Deployment] - [CMake] in the left pane of the [Settings] screen.<br>
Click the [+] icon in the right pane of the [Settings] screen.<br>
<br>

**CMake Configuration Items:**

* **Name:**
  * Enter an arbitrary name. (e.g., Debug-BananaPi)

* **Build Type:** Pull-down
  * Select Debug or Release

* **Toolchain:** Pull-down
  * Select the toolchain created in the above section

* **CMake Options:**
  * Enter the CMake options shown below:

```
-DCMAKE_BUILD_TYPE:STRING=Debug
-DCMAKE_C_COMPILER:STRING=/path/to/toolchain/bin/riscv64-linux-gnu-gcc
-DCMAKE_CXX_COMPILER:STRING=/path/to/toolchain/bin/riscv64-linux-gnu-g++
-DCMAKE_PREFIX_PATH:STRING=/home/user/InstallSoftware/BananaPi_Qt6
-DCMAKE_TOOLCHAIN_FILE:UNINITIALIZED=/home/user/InstallSoftware/BananaPi_Qt6/lib/cmake/Qt6/qt.toolchain.cmake
-DQT_QMAKE_EXECUTABLE:STRING=/home/user/InstallSoftware/BananaPi_Qt6/bin/qmake-host
```

**Explanation of CMake Options:**

* **CMAKE_BUILD_TYPE**
  * Enter Debug or Release

* **CMAKE_C_COMPILER**
  * Enter the path to the GCC file used to build the Qt library for Banana Pi.
  * Example: /path/to/toolchain/bin/riscv64-linux-gnu-gcc

* **CMAKE_CXX_COMPILER**
  * Enter the path to the G++ file used to build the Qt library for Banana Pi.
  * Example: /path/to/toolchain/bin/riscv64-linux-gnu-g++

* **CMAKE_PREFIX_PATH**
  * Enter the path to the Qt library installation directory for Banana Pi.
  * Example: /home/user/InstallSoftware/BananaPi_Qt6

* **CMAKE_TOOLCHAIN_FILE**
  * Enter the path to the build toolchain file in the Qt library installation directory for Banana Pi.
  * Example: /home/user/InstallSoftware/BananaPi_Qt6/lib/cmake/Qt6/qt.toolchain.cmake

* **QT_QMAKE_EXECUTABLE**
  * Enter the path to the qmake file in the Qt library installation directory for Banana Pi.
  * Example: /home/user/InstallSoftware/BananaPi_Qt6/bin/qmake-host

<br>

Press the [Apply] button at the bottom right of the [Settings] screen.<br>
<br>

## 8.3 SSH Configuration
Select [File] menu - [Settings].<br>
Select [Tools] - [SSH Configurations] in the left pane of the [Settings] screen.<br>
Click the [+] icon in the right pane of the [Settings] screen.<br>
<br>

**SSH Configuration Items:**

* **Host:**
  * Enter the IP address or hostname of the Banana Pi.

* **Username:**
  * Enter the username of the Banana Pi.

* **Authentication Type:** Pull-down
  * Select [Password] or [Key Pair].

* **Private Key File:** (If Key Pair is selected)
  * Enter the path to the private key file.

* **Passphrase:** (If Key Pair is selected and passphrase is set)
  * Enter the passphrase for the private key.

* **Parse config file ~/.ssh/config** checkbox
  * Optional

<br>

Press the [Test Connection] button to connect to Banana Pi via SSH.<br>
<br>

Press the [Apply] button at the bottom right of the [Settings] screen.<br>
<br>

## 8.4 Project Configuration
Launch CLion and select [File] menu - [New] - [Project...].<br>
From the [New Project] screen, select [Qt Console Application] or [Qt Widgets Application].<br>
<br>

After creating the new project, select [Run] menu - [Edit Configurations...].<br>
The [Run/Debug Configurations] screen opens. Press the [+] button at the top left of the screen and select [Remote GDB Server].<br>
[Remote GDB Server] is added to the left pane.<br>
Select [Remote GDB Server] in the left pane and configure the settings.<br>
<br>

**Remote GDB Server Configuration:**

* **Target:** Pull-down
  * Select the project name.

* **Executable:** Pull-down
  * Select the project name.

* **GDB:** Pull-down
  * Select the GDB configured in the toolchain creation section above.

* **Credentials:** Pull-down
  * Select the SSH configured in the SSH configuration section above.

* **Executable...** Radio button
  * Optional

* **Upload Path:**
  * Enter the directory on the Banana Pi where the executable binary will be placed.
  * Example: /home/<Banana Pi Username>/CLion/Sample1/debug

* **'target remote' ...**
  * Automatically entered.
  * Example: <IP Address or Hostname>:1234

* **GDB Server Args:**
  * For projects using Qt Widgets or QML, you need to add the `-platform wayland` option to the executable binary when debugging or running.
  * Example: `:<GDB Server Port Number e.g., 1234> /<Directory on Banana Pi where executable binary is placed>/debug/<Executable Binary Filename> -platform wayland`

<br>

Next, configure the [Extended GDB Server Options].<br>
This setting configures the Qt library uploaded to Banana Pi for debugging or execution.<br>

* **Working Directory:**
  * Leave blank.

* **Environment Variables:**<br>Click the text icon to the right of [Environment Variables:].<br>The [Environment Variables] screen opens. Press the [+] button at the top left of the screen and enter the settings.

  * **DISPLAY**
    * :0

  * **QT_QPA_PLATFORMTHEME**
    * For Qt 6: Qt6ct

  * **PATH**
    * Enter the path to the bin directory where Qt6 library was uploaded on Banana Pi.
    * Example: /home/<Username>/InstallSoftware/Qt6/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games

  * **LD_LIBRARY_PATH**
    * Enter the path to the lib directory where Qt6 library was uploaded on Banana Pi.
    * Example: /home/<Username>/InstallSoftware/Qt6/lib:/home/<Username>/InstallSoftware/Qt6/plugins/qmltooling

  * **QT_PLUGIN_PATH**
    * /home/<Username>/InstallSoftware/Qt6/plugins

  * **QT_QPA_PLATFORM_PLUGIN_PATH**
    * /home/<Username>/InstallSoftware/Qt6/plugins/platforms

  * **QML_IMPORT_PATH**
    * /home/<Username>/InstallSoftware/Qt6/qml

  * **QML2_IMPORT_PATH**
    * /home/<Username>/InstallSoftware/Qt6/qml

  * **QT_DEBUG_PLUGINS**
    * Enter 0 or 1.

  * **LANG**
    * To set Japanese, enter `ja_JP.UTF-8`.

<br>

The settings in the [Extended GDB Server Options] section are saved in the <u>.idea/runConfigurations/\<Project Name\>.xml</u> file in the project directory.<br>
You can also perform the above settings by directly editing this file.<br>
<br>

Since configuring the above settings in CLion is cumbersome, it is recommended to directly edit the file.<br>

```bash
cd <Project Directory>
vi .idea/runConfigurations/<Project Name>.xml
```
<br>

```xml
<!-- .idea/runConfigurations/<Project Name>.xml -->

<component name="ProjectRunConfigurationManager">
  <configuration ...>
    <envs>
      <env name="DISPLAY" value=":0" />
      <env name="LANG" value="ja_JP.UTF-8" />
      <env name="QML2_IMPORT_PATH" value="/home/<Username>/InstallSoftware/Qt6/qml" />
      <env name="QML_IMPORT_PATH" value="/home/<Username>/InstallSoftware/Qt6/qml" />
      <env name="QT_DEBUG_PLUGINS" value="0" />
      <env name="QT_PLUGIN_PATH" value="/home/<Username>/InstallSoftware/Qt6/plugins" />
      <env name="QT_QPA_PLATFORM_PLUGIN_PATH" value="/home/<Username>/InstallSoftware/Qt6/plugins/platforms" />
      <env name="QT_QPA_PLATFORMTHEME" value="Qt6ct" />
      <env name="LD_LIBRARY_PATH" value="/home/<Username>/InstallSoftware/Qt6/lib:/home/<Username>/InstallSoftware/Qt6/plugins/qmltooling" />
            <env name="PATH" value="/home/<Username>/InstallSoftware/Qt6/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games" />
    </envs>

    <!-- Additional configuration... -->

  </configuration>
</component>
```
<br>

## 8.5 GDB Configuration
If your project requires more debugging configuration, create a debugger initialization file (.gdbinit for GDB or .lldbinit for LLDB) directly in the project directory.<br>
This file can also be shared with other projects via VCS.<br>
<br>

In general, GDB/LLDB loads initialization files in a certain order at startup.<br>
First, the debugger looks for an initialization file in the user's home directory, then looks for an initialization file directly under the current project directory.<br>
<br>

However, by default, commands from project-specific initialization files are not executed for security reasons.<br>
Therefore, edit the initialization file in the home directory, <u>~/.gdbinit</u> or <u>~/.lldbinit</u>, as shown below.<br>

```bash
vi ~/.gdbinit  # or  vi ~/.lldbinit
```
<br>

```bash
# ~/.gdbinit file  or  ~/.lldbinit file

set auto-load safe-path /

# or

set auto-load local-gdbinit on
add-auto-load-safe-path /
```
<br>

Next, create a .gdbinit file directly under the project directory.<br>

```bash
cd <Project Directory>
vi .gdbinit  # or  vi .lldbinit
```
<br>

```bash
# /<Project Directory>/.gdbinit file  or  /<Project Directory>/.lldbinit file

set sysroot <Banana Pi System Root Directory>
```
<br>

Launch CLion and open any project.<br>
Check if the .gdbinit or .lldbinit file has been added to the project on the left side of the CLion main screen.<br>
<br><br>

# 9. Alternative: Using CMake Toolchain File
In addition to the qmake-based approach described above, you can also use a CMake toolchain file for cross-compilation.<br>
<br>

**An example CMake toolchain file (ToolChain_for_Banana_Pi_F3.cmake) is attached to this document.**<br>
<br>

This toolchain file includes:
* RISC-V64 vector extension 1.0 support (`-march=rv64gcv`)
* Optimized compiler flags for Banana Pi F3
* Proper sysroot configuration
* Graphics library paths (EGL, OpenGL ES, XCB, etc.)
* PKG-CONFIG environment settings

<br>

To use the CMake toolchain file:

```bash
cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/ToolChain_for_Banana_Pi_F3.cmake \
      -DCMAKE_PREFIX_PATH=/home/user/InstallSoftware/BananaPi_Qt6 \
      -DCMAKE_INSTALL_PREFIX=/home/user/InstallSoftware/BananaPi_Qt6 \
      ..

cmake --build . --parallel $(nproc)
cmake --install .
```
<br>

**Note:** Remember to modify the paths in the toolchain file according to your environment:
* `TARGET_SYSROOT` - Path to your Banana Pi sysroot
* `CMAKE_C_COMPILER` - Path to your RISC-V64 GCC
* `CMAKE_CXX_COMPILER` - Path to your RISC-V64 G++

<br><br>

# 10. Notes and Troubleshooting
## 10.1 Vector Extension Support
The attached configuration files include RISC-V vector extension 1.0 support, which can significantly improve performance for:
* Image processing
* Audio processing
* Scientific computing
* SIMD-capable algorithms

If your GCC toolchain or hardware doesn't support vector extensions, modify the `-march` flag from `rv64gcv` to `rv64gc`.

## 10.2 Verifying Vector Extension
To check if vector instructions are being generated:

```bash
riscv64-linux-gnu-objdump -d your_binary | grep -E "vl|vs|vadd|vmul"
```

These instructions indicate vector operations (vl=vector load, vs=vector store, vadd/vmul=vector arithmetic).

## 10.3 Common Issues
**Issue: "Could not load the Qt platform plugin"**
* Solution: Ensure the QT_QPA_PLATFORM_PLUGIN_PATH environment variable is set correctly
* Add `-platform wayland` or `-platform eglfs` to the GDB Server Args

**Issue: Library version mismatch**
* Solution: Ensure the libstdc++.so.6 version in your cross-compiler matches or is older than the version on Banana Pi
* Check with: `strings /usr/lib/riscv64-linux-gnu/libstdc++.so.6 | grep GLIBCXX`

**Issue: Slow debug startup**
* Solution: Use the sysroot symbolic link method described in section 8.5
* Set `set sysroot /path/to/sysroot` instead of `set sysroot target:/`

<br><br>

# 11. Attached Files
This document references the following attached files:

1. **qmake.conf** - RISC-V64 qmake configuration with vector extension support
2. **qplatformdefs.h** - Platform definitions header file
3. **ToolChain_for_Banana_Pi_F3.cmake** - CMake toolchain file with comprehensive configuration

Please download these files and modify the paths according to your environment before use.
