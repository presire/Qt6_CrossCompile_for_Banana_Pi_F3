# Building RISC-V64 GCC Toolchain

This guide describes the procedure for building a RISC-V64 cross-compilation toolchain (Binutils, GCC, and GDB) on an x86_64 Linux host system.

## Table of Contents
- [Building RISC-V64 GCC Cross-Compiler (with Sysroot)](#building-risc-v64-gcc-cross-compiler-with-sysroot)
- [Installing GDB for RISC-V64](#installing-gdb-for-risc-v64)

---

## Building RISC-V64 GCC Cross-Compiler (with System Root)

### Prerequisites

Ensure you have the following packages installed on your host system:

**For RHEL-based distributions:**
```bash
sudo dnf install bison m4 flex gawk wget make texinfo gcc gcc-c++ python3-devel \
                 xz-devel xxhash-devel gmp-devel mpfr-devel mpc-devel isl-devel
```

**For SUSE-based distributions:**
```bash
sudo zypper install bison m4 flex gawk wget texinfo make gcc gcc-c++ python3-devel \
                    xz-devel xxhash-devel gmp-devel mpfr-devel mpc-devel isl-devel
```

### Step 1: Build and Install Binutils

Download Binutils from the [GNU official website](https://ftp.gnu.org/gnu/binutils/).

Extract the downloaded file:
```bash
tar xf binutils-<version>.tar.xz
cd binutils-<version>
```

Create a build directory:
```bash
mkdir build && cd build
```

<br>

Configure, build, and install Binutils for the RISC-V64 cross-compiler:

> **Important:**  
> The installation directory must be the same as the GCC cross-compiler installation directory.

```bash
../configure --prefix=<GCC_cross_compiler_install_directory> \
             --build=x86_64-pc-linux-gnu        \
             --host=x86_64-pc-linux-gnu         \
             --target=riscv64-linux-gnu         \
             --disable-nls                      \
             --disable-werror                   \
             --with-sysroot=<target_sysroot_directory>

make -j $(nproc)
make install
```

Verify the Binutils installation:
```bash
<GCC_cross_compiler_install_directory>/bin/riscv64-linux-gnu-ld --version
```

### Step 2: Build and Install GCC

Access the [GCC official website](https://gcc.gnu.org) to download the GCC source code, or use the following command:

```bash
wget http://ftp.tsukuba.wide.ad.jp/software/gcc/releases/gcc-<version>/gcc-<version>.tar.xz
tar xf gcc-<version>.tar.xz
cd gcc-<version>
```

Add the Binutils installation directory to your PATH:
```bash
export PATH="<Binutils_install_directory>/bin:$PATH"
```

Create a build directory:
```bash
mkdir build && cd build
```

Configure, build, and install GCC:
```bash
../configure --prefix=<GCC_cross_compiler_install_directory> \
             --build=x86_64-pc-linux-gnu        \
             --host=x86_64-pc-linux-gnu         \
             --target=riscv64-linux-gnu         \
             --enable-languages=c,c++           \
             --disable-multilib                 \
             --disable-nls                      \
             --with-sysroot=<target_sysroot_directory>

make -j $(nproc)
make install-strip
```

## Installing GDB for RISC-V64

### Overview

GDB (GNU Debugger) is a standard debugger used on UNIX-like operating systems.

When launched with an executable file,  
GDB can start program execution and allows monitoring and intervention of the execution state.  

Features include:
- Displaying and modifying variable values at specific points
- Setting breakpoints to stop execution at specific locations
- Step-by-step execution (one instruction at a time)
- Interactive command-line interface

GDB can also attach to processes already running on the OS,  
and supports remote debugging mode for debugging programs running on different computers.  

This makes it useful for embedded software development and Linux kernel development.

### Step 1: Install Dependencies

Install the required libraries for building GDB:

**For RHEL-based distributions:**
```bash
sudo dnf install bison m4 flex gawk wget make texinfo gcc gcc-c++ python3-devel \
                 xz-devel xxhash-devel gmp-devel mpfr-devel mpc-devel isl-devel
```

**For SUSE-based distributions:**
```bash
sudo zypper install bison m4 flex gawk wget texinfo make gcc gcc-c++ python3-devel \
                    xz-devel xxhash-devel gmp-devel mpfr-devel mpc-devel isl-devel
```

> **Note:**  
> Installing Texinfo via package management systems can take a considerable amount of time. Manual installation is recommended.

#### Manual Texinfo Installation (Recommended)

1. Download Texinfo from the [official website](https://ftp.gnu.org/gnu/texinfo/)
2. Extract the archive and create a build directory:
   ```bash
   tar xf texinfo-<version>.tar.xz
   cd texinfo-<version>
   mkdir build && cd build
   ```
3. Build and install Texinfo:
   ```bash
   ../configure --prefix=<Texinfo_install_directory>
   make -j $(nproc)
   make TEXMF=<Texinfo_install_directory>/texmf install-tex
   make install
   ```
4. Add environment variables to your `.profile` or `.bashrc` file:
   ```bash
   export PATH="<Texinfo_install_directory>/bin:$PATH"
   export LD_LIBRARY_PATH="<Texinfo_install_directory>/lib64:$LD_LIBRARY_PATH"
   ```

### Step 2: Download and Extract GDB

Download GDB from the [official website](https://ftp.gnu.org/gnu/gdb/), or use the following command:

```bash
wget https://ftp.gnu.org/gnu/gdb/gdb-<version>.tar.xz
tar xf gdb-<version>.tar.xz
cd gdb-<version>
```

Create a build directory:
```bash
mkdir build && cd build
```

### Step 3: Configure Python Support (Important for Qt Creator)

> **Critical Note:**  
> When using custom-installed GDB with Qt Creator, you must specify the Python executable and library paths during GDB compilation.

Set the Python environment variables:
```bash
[ -z "$PYTHON" ] && export PYTHON=<Python3_executable_full_path>
export PYTHON_LIBDIR=$("$PYTHON" -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
```

Example:
```bash
[ -z "$PYTHON" ] && export PYTHON=$HOME/Python/bin/python3.8
export PYTHON_LIBDIR=$("$PYTHON" -c "import sysconfig; print(sysconfig.get_config_var('LIBDIR'))")
```

### Step 4: Build and Install GDB

For RISC-V64 cross-compiler GDB:

```bash
export PATH="<RISC-V64_Binutils_and_GCC_install_directory>/bin:$PATH"

../configure --prefix=<RISC-V64_cross_compiler_install_directory> \
             --build=x86_64-pc-linux-gnu \
             --host=x86_64-pc-linux-gnu \
             --target=riscv64-linux-gnu \
             --with-python="$PYTHON" \
             LDFLAGS="-L$PYTHON_LIBDIR -static-libstdc++" \
             --disable-multilib \
             --disable-nls \
             --with-sysroot=<target_sysroot_directory>

make -j $(nproc)
make install
```

> **Note:**  
> The `--with-sysroot` option may not be necessary in some cases, but it's included for compatibility.

### Verification

Verify the GDB installation:
```bash
<RISC-V64_cross_compiler_install_directory>/bin/riscv64-linux-gnu-gdb --version
```

<br>

## Important Notes

1. **Installation Directory Consistency**: Ensure that Binutils, GCC, and GDB are all installed to the same directory for proper operation.

2. **Sysroot Directory**: The sysroot should point to the root filesystem of your target RISC-V64 system (e.g., Banana Pi).

3. **Python Support**: Python support is essential for GDB pretty-printers and Qt Creator integration.

4. **Library Compatibility**: Ensure the `libstdc++.so.6` version in your cross-compiler is equal to or older than the version on your target system.

---

## Example Directory Structure

```
/home/user/cross-tools/riscv64/
├── bin/
│   ├── riscv64-linux-gnu-gcc
│   ├── riscv64-linux-gnu-g++
│   ├── riscv64-linux-gnu-ld
│   ├── riscv64-linux-gnu-gdb
│   └── ...
├── lib/
├── libexec/
└── riscv64-linux-gnu/
    └── ...
```

---

## Troubleshooting

### Issue: "configure: error: C compiler cannot create executables"
**Solution:** Ensure GCC and development tools are properly installed on your host system.

### Issue: Python support not detected
**Solution:** Verify that Python development headers are installed:
```bash
# RHEL/Fedora
sudo dnf install python3-devel

# SUSE
sudo zypper install python3-devel
```

### Issue: GDB crashes when debugging
**Solution:**  
Ensure the sysroot path is correctly configured and accessible.  
Also verify that the GDB version is compatible with your target system's glibc version.
<br>


## Additional Resources

- [GNU Binutils Documentation](https://www.gnu.org/software/binutils/)
- [GCC Documentation](https://gcc.gnu.org/onlinedocs/)
- [GDB Documentation](https://www.gnu.org/software/gdb/documentation/)
- [RISC-V Toolchain Repository](https://github.com/riscv-collab/riscv-gnu-toolchain)
