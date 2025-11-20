# =============================================================================
# RISC-V64 Vector Extension 1.0 Toolchain File
# Cross-Compilation Environment Configuration for Banana Pi F3
# =============================================================================
#
# This file configures a cross-compilation environment to use the
# RISC-V64 architecture with vector extension instruction set (RVV 1.0).
# It is used when building binaries for Banana Pi F3 on a host machine
# during Qt application development, etc.

cmake_minimum_required(VERSION 3.18)
include_guard(GLOBAL)

# =============================================================================
# Target System Basic Information
# =============================================================================
# These settings make CMake recognize that it operates in cross-compilation mode.
# These settings are essential when host and target systems differ.

# Set target OS to Linux
# This enables searching for Linux system-specific libraries and header files
set(CMAKE_SYSTEM_NAME Linux)

# Set target processor architecture to riscv64
# CMake applies architecture-specific compiler options based on this information
set(CMAKE_SYSTEM_PROCESSOR riscv64)

# =============================================================================
# Target System Root Filesystem (Sysroot) Configuration
# =============================================================================
# Sysroot is a copy of the target device's filesystem on the host, from which
# header files and libraries are searched. This enables development without
# having the actual hardware.

# Path to Banana Pi F3's root filesystem
# ※ Modify this path according to your environment
set(TARGET_SYSROOT  /path/to/your/Banana Pi F3 System Root directory)

# CMake sysroot setting
# All library and header searches are performed relative to this directory
set(CMAKE_SYSROOT ${TARGET_SYSROOT})

# =============================================================================
# PKG-CONFIG Environment Variable Settings
# =============================================================================
# pkg-config is a tool that automatically detects library dependencies and
# compilation flags. During cross-compilation, it needs to reference .pc files
# from the target system.

# Add existing path and target system's pkgconfig directory to PKG_CONFIG_PATH
# This ensures proper detection of Qt and X11-related library configuration files
set(ENV{PKG_CONFIG_PATH}   $PKG_CONFIG_PATH:${TARGET_SYSROOT}/usr/lib/pkgconfig:${TARGET_SYSROOT}/usr/lib/riscv64-linux-gnu/pkgconfig)

# PKG_CONFIG_LIBDIR is a standard directory list for searching pkgconfig files
# Including both host and target directories enables flexible searching
set(ENV{PKG_CONFIG_LIBDIR} /usr/lib64/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig/:${TARGET_SYSROOT}/usr/lib/pkgconfig:${TARGET_SYSROOT}/usr/lib/riscv64-linux-gnu/pkgconfig:${TARGET_SYSROOT}/usr/share/pkgconfig)

# Setting PKG_CONFIG_SYSROOT_DIR specifies the root directory for pkgconfig
# to resolve paths. This ensures correct reference to target libraries
set(ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

# =============================================================================
# Cross-Compiler Specification
# =============================================================================
# Specify GCC cross-compiler for RISC-V64.
# These compilers run on the host machine (x86_64, etc.) and generate
# RISC-V64 binaries.

# C language compiler path
# ※ Modify the GCC toolchain installation path according to your environment
set(CMAKE_C_COMPILER    /path/to/your/toolchain/bin/riscv64-linux-gnu-gcc)

# C++ language compiler path
set(CMAKE_CXX_COMPILER  /path/to/your/toolchain/bin/riscv64-linux-gnu-g++)

# =============================================================================
# Compiler Flags and Include Path Configuration
# =============================================================================
# Settings to correctly reference target system's header files.

# Add include paths to C compiler flags
# Explicitly specify header file search paths with -I option
# This enables reference to system headers and architecture-specific headers
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -I${TARGET_SYSROOT}/usr/include -I${TARGET_SYSROOT}/usr/include/riscv64-linux-gnu")

# Configure C++ compiler flags similarly
# C++-specific headers (iostream, etc.) are also searched from these paths
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS}")

# =============================================================================
# Linker Flags Initial Settings
# =============================================================================
# Settings to correctly load dynamic libraries at runtime.
# The -rpath-link option is used to resolve library dependencies during linking.

# Flags for linking executable files
# Specifying target system's library directory correctly resolves
# shared library dependencies
set(CMAKE_EXE_LINKER_FLAGS_INIT     "-Wl,-rpath-link,${TARGET_SYSROOT}/usr/lib/riscv64-linux-gnu")

# Flags for linking modules (plugins)
set(CMAKE_MODULE_LINKER_FLAGS_INIT  "-Wl,-rpath-link,${TARGET_SYSROOT}/usr/lib/riscv64-linux-gnu")

# Flags for linking shared libraries
set(CMAKE_SHARED_LINKER_FLAGS_INIT  "-Wl,-rpath-link,${TARGET_SYSROOT}/usr/lib/riscv64-linux-gnu")

# =============================================================================
# RISC-V64 Vector Extension Compatible Compiler Flags
# =============================================================================
# This is the important setting to support vector extension 1.0.

# Architecture and ABI specification:
# -march=rv64gcv details:
#   rv64   : 64-bit RISC-V base instruction set
#   g      : Shorthand for IMAFD extensions (general-purpose instruction set)
#     I    : Base integer instruction set
#     M    : Multiplication/division instructions
#     A    : Atomic instructions (important for multithreading/multicore)
#     F    : Single precision floating point instructions
#     D    : Double precision floating point instructions
#   c      : Compressed instructions (reduce code size with 16-bit instructions)
#   v      : Vector extension 1.0 (RVV 1.0) ← This is the important part added this time
#
# -mabi=lp64d meaning:
#   lp64   : long and pointer are 64-bit
#   d      : ABI using double precision floating point registers
#
# Vector extensions are designed to be added to the existing ABI,
# so no special ABI specification for vector registers is needed.
set(QT_COMPILER_FLAGS "-march=rv64gcv -mabi=lp64d")

# Optimization flags for release builds:
# -O2              : General optimization level (balance of code size and performance)
# -pipe            : Process through pipes without creating intermediate files (faster builds)
# -ftree-vectorize : Explicitly enable loop vectorization (leverage vector extensions)
#
# Note: -ftree-vectorize is usually automatically enabled with -O2, but explicitly
#       specifying ensures vectorization. Fully utilizes Banana Pi F3's vector unit.
set(QT_COMPILER_FLAGS_RELEASE "-O2 -pipe -ftree-vectorize")

# Linker flags:
# -Wl,-O1              : Enable linker-level optimization
# -Wl,--hash-style=gnu : Use GNU-style symbol hash table (faster startup)
# -Wl,--as-needed      : Link only actually used libraries (reduce binary size)
set(QT_LINKER_FLAGS "-Wl,-O1 -Wl,--hash-style=gnu -Wl,--as-needed")

# =============================================================================
# [Supplementary] Configuration Example for More Aggressive Vectorization
# =============================================================================
# More aggressive optimization is possible by changing flags as follows:
#
# set(QT_COMPILER_FLAGS_RELEASE "-O3 -pipe -ftree-vectorize -fno-vect-cost-model")
#
# -O3                  : Maximum optimization (code size may increase)
# -fno-vect-cost-model : Disable vectorization cost calculation for more aggressive vectorization
#
# However, recommend taking benchmarks in actual applications to verify
# performance and binary size trade-offs.

# =============================================================================
# CMake Search Path Configuration
# =============================================================================
# In cross-compilation environments, search modes must be properly configured
# to avoid mixing host and target files.

# Don't search for programs (executables)
# Build tools themselves use those from the host machine,
# so no need to search from target system
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries only from target system
# Libraries to link must always be for the target
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

# Search for header files only from target system
# Headers referenced during compilation use those from target environment
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Search for CMake package configuration files from target system
# Search mode for library configuration files detected by find_package()
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# =============================================================================
# Runtime Path (RPATH) Configuration
# =============================================================================
# Settings to enable generated binaries to find shared libraries at runtime.

# Include link-time paths in RPATH
# This records paths of libraries linked in development environment in executable
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

# Set build-time RPATH to target system root
# Enables executable immediately after build to correctly reference libraries
set(CMAKE_BUILD_RPATH ${TARGET_SYSROOT})

# =============================================================================
# Method to Integrate Qt-Specific Settings into CMake Standard Flags (Commented Version)
# =============================================================================
# The following code is a mechanism to automatically integrate QT_COMPILER_FLAGS
# and QT_LINKER_FLAGS into CMake's standard CMAKE_C_FLAGS, CMAKE_CXX_FLAGS, etc.
# Currently commented out, but can be enabled as needed.
#
# Using this mechanism automatically applies appropriate flags for each
# build type (Debug, Release, etc.).
#
# include(CMakeInitializeConfigs)
#
# function(cmake_initialize_per_config_variable _PREFIX _DOCSTRING)
#   # Process C/C++/Assembly compiler flags
#   if (_PREFIX MATCHES "CMAKE_(C|CXX|ASM)_FLAGS")
#     # Set basic compiler flags
#     set(CMAKE_${CMAKE_MATCH_1}_FLAGS_INIT "${QT_COMPILER_FLAGS}")
#
#     # Set flags for each build type (DEBUG, RELEASE, MINSIZEREL, RELWITHDEBINFO)
#     foreach (config DEBUG RELEASE MINSIZEREL RELWITHDEBINFO)
#       if (DEFINED QT_COMPILER_FLAGS_${config})
#         set(CMAKE_${CMAKE_MATCH_1}_FLAGS_${config}_INIT "${QT_COMPILER_FLAGS_${config}}")
#       endif()
#     endforeach()
#   endif()
#
#   # Process linker flags
#   if (_PREFIX MATCHES "CMAKE_(SHARED|MODULE|EXE)_LINKER_FLAGS")
#     # Set flags for each linker type (shared library, module, executable)
#     foreach (config SHARED MODULE EXE)
#       set(CMAKE_${config}_LINKER_FLAGS_INIT "${QT_LINKER_FLAGS}")
#     endforeach()
#   endif()
#
#   # Call CMake's standard initialization function
#   _cmake_initialize_per_config_variable(${ARGV})
# endfunction()

# =============================================================================
# Graphics Library Related Settings
# =============================================================================
# Explicitly specify paths for graphics libraries needed when using
# Qt GUI applications or OpenGL. This enables find_package() and
# find_library() to correctly detect libraries.

# XCB base path
# XCB is a library used for communication with X Window System
set(XCB_PATH_VARIABLE ${TARGET_SYSROOT})

# Common settings for OpenGL/EGL related include and library directories
set(GL_INC_DIR ${TARGET_SYSROOT}/usr/include)
set(GL_LIB_DIR ${TARGET_SYSROOT}:${TARGET_SYSROOT}/usr/lib/riscv64-linux-gnu/:${TARGET_SYSROOT}/usr:${TARGET_SYSROOT}/usr/lib)

# =============================================================================
# EGL (Embedded-System Graphics Library) Configuration
# =============================================================================
# EGL is an API that bridges OpenGL ES and window systems.
# Widely used for graphics drawing in embedded systems.

set(EGL_INCLUDE_DIR ${GL_INC_DIR})
set(EGL_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/riscv64-linux-gnu/libEGL.so)

# =============================================================================
# OpenGL Configuration
# =============================================================================
# Configuration for desktop OpenGL library.
# Used in 3D graphics applications.

set(OPENGL_INCLUDE_DIR ${GL_INC_DIR})
set(OPENGL_opengl_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/riscv64-linux-gnu/libOpenGL.so)

# =============================================================================
# OpenGL ES 2.0 Configuration
# =============================================================================
# OpenGL ES 2.0 is a subset of OpenGL optimized for embedded systems.
# Widely used in mobile devices and SBCs (single board computers).
# Banana Pi F3's GPU likely supports OpenGL ES.

set(GLESv2_INCLUDE_DIR ${GL_INC_DIR})

# GLIB_LIBRARY name may be a typo, but kept to respect original file
# Should normally be GLESv2_LIBRARY, but both are configured for compatibility
set(GLIB_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/riscv64-linux-gnu/libGLESv2.so)
set(GLESv2_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/riscv64-linux-gnu/libGLESv2.so)

# =============================================================================
# GBM (Generic Buffer Management) Configuration
# =============================================================================
# GBM is an API for allocating graphics buffers.
# Used in combination with DRM (Direct Rendering Manager) for
# direct rendering without X Window System.

set(gbm_INCLUDE_DIR ${GL_INC_DIR})
set(gbm_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/riscv64-linux-gnu/libgbm.so)

# =============================================================================
# DRM (Direct Rendering Manager) Configuration
# =============================================================================
# DRM is Linux kernel's graphics subsystem.
# Provides direct access to GPU, manages display mode settings and framebuffers.

set(Libdrm_INCLUDE_DIR ${GL_INC_DIR})
set(Libdrm_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/riscv64-linux-gnu/libdrm.so)

# =============================================================================
# XCB (X C Binding) Configuration
# =============================================================================
# XCB is a low-level library for communication with X Window System.
# Used in X11-based GUI applications.
# Qt's X11 backend depends on this library.

set(XCB_XCB_INCLUDE_DIR ${GL_INC_DIR})
set(XCB_XCB_LIBRARY ${XCB_PATH_VARIABLE}/usr/lib/riscv64-linux-gnu/libxcb.so)

# =============================================================================
# End of Configuration File
# =============================================================================
# To use this toolchain file, specify it when running CMake as follows:
#
# cmake -DCMAKE_TOOLCHAIN_FILE=/path/to/ToolChain_for_Banana_Pi_F3.cmake ..
#
# This generates optimized binaries leveraging RISC-V64 vector extensions.
