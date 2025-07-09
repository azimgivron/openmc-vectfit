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
    wget \
    libhdf5-dev 

echo "=== Creating and activating Python virtual environment ==="
if [ ! -d ".venv" ]; then
    python3.9 -m venv .venv
    echo "Virtual environment created."
fi
source .venv/bin/activate
echo "Python virtual environment activated."

echo "=== Upgrading pip ==="
pip install --upgrade pip

# === OpenSSL ===
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
    make -j 30
    make install
    cd ..
    echo "OpenSSL installed at /usr/local/openssl-1.1.1h."
    rm -rf  openssl
else
    echo "OpenSSL already installed — skipping build."
fi

echo "=== Updating environment variables for OpenSSL ==="

OPENSSL_LIB_PATH="/usr/local/openssl-1.1.1h/lib"
OPENSSL_BIN_PATH="/usr/local/openssl-1.1.1h/bin"

# Add to LD_LIBRARY_PATH if not already present
if [[ ":$LD_LIBRARY_PATH:" != *":$OPENSSL_LIB_PATH:"* ]]; then
    export LD_LIBRARY_PATH="$OPENSSL_LIB_PATH:$LD_LIBRARY_PATH"
    echo "LD_LIBRARY_PATH updated."
else
    echo "LD_LIBRARY_PATH already contains OpenSSL path — skipping."
fi

# Add to PATH if not already present
if [[ ":$PATH:" != *":$OPENSSL_BIN_PATH:"* ]]; then
    export PATH="$OPENSSL_BIN_PATH:$PATH"
    echo "PATH updated."
else
    echo "PATH already contains OpenSSL path — skipping."
fi

# === CMake ===
if ! cmake --version | grep -q "3.18.4"; then
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
    make -j 30
    make install
    cd ..
    echo "CMake installed successfully."
    rm -rf  CMake
else
    echo "CMake 3.18.4 already installed — skipping build."
fi

# === xtl ===
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
    make -j 30
    make install
    cd ../..
    echo "xtl installed successfully."
    rm -rf  xtl
else
    echo "xtl already installed — skipping build."
fi


# === xtensor ===
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
    make -j 30
    make install
    cd ../..
    echo "xtensor installed successfully."
    rm -rf  xtensor
else
    echo "xtensor already installed — skipping build."
fi

# === numpy ===
echo "=== Ensuring numpy is installed in virtual environment ==="
pip show numpy >/dev/null 2>&1 || pip install numpy

# === pybind11 ===
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
    pip install pytest==6.1.1
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DNUMPY_INCLUDE_DIRS=$(python -c "import numpy; print(numpy.get_include())") \
          ..
    make -j 30
    make install
    cd ..
    pip install .
    cd ..
    echo "pybind11 installed successfully."
    rm -rf  pybind11
else
    echo "pybind11 already installed — skipping build."
fi

# === xtensor-python ===
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
          -DNUMPY_INCLUDE_DIRS=$(python -c "import numpy; print(numpy.get_include())") \
          ..
    make -j 30
    make install
    cd ../..
    echo "xtensor-python installed successfully."
    rm -rf  xtensor-python
else
    echo "xtensor-python already installed — skipping build."
fi

if [ ! -f "/usr/local/include/xtensor-blas/xblas.hpp" ]; then
    if [ ! -d "xtensor-blas" ]; then
        echo "Cloning xtensor-blas..."
        git clone https://github.com/xtensor-stack/xtensor-blas
    else
        echo "xtensor-blas repo already exists — skipping clone."
    fi
    echo "=== Building and installing xtensor-blas ==="
    cd xtensor-blas
    git checkout 0.17.1
    mkdir -p build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
          -DNUMPY_INCLUDE_DIRS=$(python -c "import numpy; print(numpy.get_include())") \
          ..
    make -j 30
    make install
    cd ../..
    echo "xtensor-blas installed successfully."
    rm -rf  xtensor-blas
else
    echo "xtensor-blas already installed — skipping build."
fi

if [ ! -d "vectfit" ]; then
    echo "Cloning vectfit..."
    git clone https://github.com/mit-crpg/vectfit.git
else
    echo "vectfit repo already exists — skipping clone."
fi
cd vectfit
python setup.py build
python setup.py install
cd ..
rm -rf vectfit

if [ ! -f "/usr/local/include/openmc/xsdata.h" ]; then
    if [ ! -d "openmc" ]; then
        echo "Cloning openmc..."
        git clone --recurse-submodules https://github.com/openmc-dev/openmc.git
    else
        echo "openmc repo already exists — skipping clone."
    fi
    echo "=== Building and installing openmc ==="
    cd openmc
    git checkout v0.12.0
    mkdir build && cd build
    cmake -DCMAKE_INSTALL_PREFIX=/usr/local ..
    make -j 30
    make install
    cd ../..
    echo "openmc installed successfully."
    rm -rf openmc
else
    echo "openmc already installed — skipping build."
fi
