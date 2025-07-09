# openmc-vectfit

This repository provides a Docker build environment and installation script for compiling and installing
[vectfit](https://github.com/mit-crpg/vectfit) and its dependencies along with
[openmc](https://github.com/openmc-dev/openmc). The `Dockerfile` creates an image
based on Python 3.9 that runs `install_vectfit.sh` to build and install the
required toolchain and libraries.

The installation script performs the following tasks:

- Installs system packages such as `build-essential`, `cmake`, OpenSSL, and others.
- Creates a Python virtual environment and upgrades `pip`.
- Builds several third-party libraries (OpenSSL, CMake, xtl, xtensor, pybind11,
  xtensor-python, xtensor-blas) from source.
- Clones, builds and installs `vectfit` and `openmc`.

To build the Docker image:

```bash
docker build -t openmc-vectfit .
```

Once built, you can start a container using:

```bash
docker run -it openmc-vectfit
```

This will drop you into a shell within the container with the necessary tools
installed.

The project is licensed under the MIT License. See [LICENSE](LICENSE) for
details.
