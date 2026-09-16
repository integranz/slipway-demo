FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        build-essential \
    && rm -rf /var/lib/apt/lists/*

# Node.js 22 (matches CI and package.json engines)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# .NET 8 SDK (matches CI and apps/api)
ENV DOTNET_ROOT=/usr/share/dotnet
RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh \
    && bash /tmp/dotnet-install.sh --channel 8.0 --install-dir "${DOTNET_ROOT}" \
    && ln -s "${DOTNET_ROOT}/dotnet" /usr/local/bin/dotnet \
    && rm /tmp/dotnet-install.sh

RUN useradd -m -s /bin/bash ubuntu || true
USER ubuntu
WORKDIR /home/ubuntu
