FROM mcr.microsoft.com/vscode/devcontainers/python:0-bullseye AS devcontainer
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        git \
        libexpat-dev \
        libmagickwand-dev \
        libreadline-dev \
        libssl-dev \
        libyaml-dev \
        libzip-dev \
        ninja-build \
        ruby \
        tar \
        unzip \
        zip \
    && pip install git+https://github.com/luarocks/hererocks cmake pre-commit \
    && hererocks -l 5.1 -r 3.8.0 /usr/local \
    && git config --system --add safe.directory '*'
WORKDIR /wowless
COPY wowless-scm-0.rockspec .
RUN luarocks build
RUN delgroup npm
