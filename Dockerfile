# syntax=docker/dockerfile:1
###############################################################################
# Build-and-run stage (single stage)
###############################################################################
FROM python:3.9-bookworm

# Non-interactive, reproducible environment
ENV LANG=C.UTF-8 \
    DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LD_LIBRARY_PATH="/usr/local/openssl-1.1.1h/lib" \
    OPENSSL_BIN_PATH="/usr/local/openssl-1.1.1h/bin" \
    NJOY_PATH="/njoy" \
    PATH="/opt/build/.venv/bin:/njoy:/usr/local/openssl-1.1.1h/bin:${PATH}"

# Workspace for build artefacts
WORKDIR /opt/build

# Copy installer once and mark it executable in the same layer
COPY --chmod=0755 install_vectfit.sh .

# Run the full tool-chain install and remove APT cache afterwards
RUN set -eux \
 && ./install_vectfit.sh \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Default working directory for end-users
WORKDIR /workspace

ENTRYPOINT ["bash"]
CMD ["-l"]
