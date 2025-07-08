#!/bin/bash
set -e  # Exit on any error

echo "=== Updating package list and installing required system packages ==="
apt update
apt install -y \
    git \
    build-essential \
    python3-pip \
    python3-venv \
    cmake \
    libssl-dev \
    curl \
    liblapack-dev \
    libclblast-dev \
    wget

echo "=== Creating and activating Python virtual environment ==="
if [ ! -d ".venv" ]; then
    python3.9 -m venv .venv
    echo "Virtual environment created."
fi
source .venv/bin/activate
echo "Python virtual environment activated."

echo "=== Upgrading pip ==="
pip install --upgrade pip

# ----------------------------------------------------------------------
# OpenSSL 1.1.1h
# ----------------------------------------------------------------------
if [ ! -f "/usr/local/openssl-1.1.1h/lib/libssl.a" ]; then
    if [ ! -d "openssl" ]; then
        echo "Cloning OpenSSL..."
        git clone https://github.com/openssl/openssl.git
    else
        echo "OpenSSL repo already exists — skipping clone."
    fi
    echo "=== Building and installing OpenSSL (version 1.1.1h) ==="
    cd openssl
    git checkout OpenSSL_1_1_1h
    ./config --prefix=/usr/local/openssl-1.1.1h
    make -j"$(nproc)"
    make install
    cd ..
    echo "OpenSSL installed at /usr/local/openssl-1.1.1h."
else
    echo "OpenSSL already installed — skipping build."
fi

echo "=== Updating environment variables for OpenSSL ==="
OPENSSL_LIB_PATH="/usr/local/openssl-1.1.1h/lib"
OPENSSL_BIN_PATH="/usr/local/openssl-1.1.1h/bin"

if [[ ":${LD_LIBRARY_PATH}:" != *":${OPENSSL_LIB_PATH}:"* ]]; then
    export LD_LIBRARY_PATH="${OPENSSL_LIB_PATH}:${LD_LIBRARY_PATH}"
    echo "LD_LIBRARY_PATH updated."
fi
if [[ ":${PATH}:" != *":${OPENSSL_BIN_PATH}:"* ]]; then
    export PATH="${OPENSSL_BIN_PATH}:${PATH}"
    echo "PATH updated."
fi

# ----------------------------------------------------------------------
# CMake 3.18.4
# ----------------------------------------------------------------------
if ! cmake --version 2>/dev/null | grep -q "3.18.4"; then
    if [ ! -d "CMake" ]; then
        echo "Cloning CMake..."
        git clone https://github.com/Kitware/CMake.git
    else
        echo "CMake repo already exists — skipping clone."
    fi
    echo "=== Building and installing CMake (version 3.18.4) ==="
    cd CMake
    git checkout v3.18.4
    ./bootstrap --prefix=/usr/local
    make -j"$(nproc)"
    make install
    cd ..
    echo "CMake installed successfully."
else
    echo "CMake 3.18.4 already installed — skipping build."
fi

# ----------------------------------------------------------------------
# xtl
# ----------------------------------------------------------------------
if [ ! -f "/usr/local/include/xtl/xtl_config.hpp" ]; then
    if [ ! -d "xtl" ]; then
        echo "Cloning xtl..."
        git clone https://github.com/xtensor-stack/xtl.git
    else
        echo "xtl repo already exists — skipping clone."
    fi
    echo "=== Building and installing xtl ==="
    cd xtl
    git checkout 0.6.19
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
    make -j"$(nproc)"
    make install
    cd ../..
    echo "xtl installed successfully."
else
    echo "xtl already installed — skipping build."
fi

# ----------------------------------------------------------------------
# xtensor
# ----------------------------------------------------------------------
if [ ! -f "/usr/local/include/xtensor/xarray.hpp" ]; then
    if [ ! -d "xtensor" ]; then
        echo "Cloning xtensor..."
        git clone https://github.com/xtensor-stack/xtensor.git
    else
        echo "xtensor repo already exists — skipping clone."
    fi
    echo "=== Building and installing xtensor ==="
    cd xtensor
    git checkout 0.21.2
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
    make -j"$(nproc)"
    make install
    cd ../..
    echo "xtensor installed successfully."
else
    echo "xtensor already installed — skipping build."
fi

# ----------------------------------------------------------------------
# numpy (inside the venv)
# ----------------------------------------------------------------------
echo "=== Ensuring numpy is installed in virtual environment ==="
pip show numpy >/dev/null 2>&1 || pip install numpy

# ----------------------------------------------------------------------
# pybind11
# ----------------------------------------------------------------------
if [ ! -f "/usr/local/include/pybind11/pybind11.h" ]; then
    if [ ! -d "pybind11" ]; then
        echo "Cloning pybind11..."
        git clone https://github.com/pybind/pybind11.git
    else
        echo "pybind11 repo already exists — skipping clone."
    fi
    echo "=== Building and installing pybind11 ==="
    cd pybind11
    git checkout v2.5.0
    # pytest pin avoids incompatible versions when running pybind11's tests
    pip install pytest==6.1.1
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DNUMPY_INCLUDE_DIRS=$(python -c "import numpy, sys; sys.stdout.write(numpy.get_include())") \
          ..
    make -j"$(nproc)"
    make install
    cd ../..
    echo "pybind11 installed successfully."
else
    echo "pybind11 already installed — skipping build."
fi

# ----------------------------------------------------------------------
# xtensor-python
# ----------------------------------------------------------------------
if [ ! -f "/usr/local/include/xtensor-python/pyarray.hpp" ]; then
    if [ ! -d "xtensor-python" ]; then
        echo "Cloning xtensor-python..."
        git clone https://github.com/xtensor-stack/xtensor-python.git
    else
        echo "xtensor-python repo already exists — skipping clone."
    fi
    echo "=== Building and installing xtensor-python ==="
    cd xtensor-python
    git checkout 0.24.1
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DNUMPY_INCLUDE_DIRS=$(python -c "import numpy, sys; sys.stdout.write(numpy.get_include())") \
          ..
    make -j"$(nproc)"
    make install
    cd ../..
    echo "xtensor-python installed successfully."
else
    echo "xtensor-python already installed — skipping build."
fi

# ----------------------------------------------------------------------
# xtensor-blas
# ----------------------------------------------------------------------
if [ ! -f "/usr/local/include/xtensor-blas/xblas.hpp" ]; then
    if [ ! -d "xtensor-blas" ]; then
        echo "Cloning xtensor-blas..."
        git clone https://github.com/xtensor-stack/xtensor-blas.git
    else
        echo "xtensor-blas repo already exists — skipping clone."
    fi
    echo "=== Building and installing xtensor-blas ==="
    cd xtensor-blas
    git checkout 0.17.1
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DNUMPY_INCLUDE_DIRS=$(python -c "import numpy, sys; sys.stdout.write(numpy.get_include())") \
          ..
    make -j"$(nproc)"
    make install
    cd ../..
    echo "xtensor-blas installed successfully."
else
    echo "xtensor-blas already installed — skipping build."
fi

# ----------------------------------------------------------------------
# Vectfit (needed later by OpenMC’s build system)
# ----------------------------------------------------------------------
VECTFIT_INSTALL_MARKER="/usr/local/share/vectfit_installed"
if [ ! -f "${VECTFIT_INSTALL_MARKER}" ]; then
    if [ ! -d "vectfit" ]; then
        echo "Cloning vectfit..."
        git clone https://github.com/mit-crpg/vectfit.git
    else
        echo "vectfit repo already exists — skipping clone."
    fi

    echo "=== Building and installing vectfit ==="
    cd vectfit
    mkdir -p build && cd build
    make -j"$(nproc)"
    make install
    cd ..
    pip install .
    cd ..
    touch "${VECTFIT_INSTALL_MARKER}"
    echo "vectfit installed successfully."
else
    echo "vectfit already installed — skipping build."
fi

# ----------------------------------------------------------------------
# OpenMC
# ----------------------------------------------------------------------
if ! command -v openmc >/dev/null 2>&1; then
    if [ ! -d "openmc" ]; then
        echo "Cloning OpenMC..."
        git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
    else
        echo "OpenMC repo already exists — skipping clone."
    fi
    echo "=== Building and installing OpenMC (v0.12.0) ==="
    cd openmc
    git checkout v0.12.0
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
    make -j"$(nproc)"
    make install
    cd ..
    pip install .
    cd ..
    echo "OpenMC installed successfully."
else
    echo "OpenMC already installed — skipping build."
fi

echo "=== All steps completed successfully ==="
