FROM rust:slim-bullseye AS stylua-builder
RUN cargo install --root=/opt/stylua --version=0.12.4 stylua

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
        zip
COPY --from=stylua-builder /opt/stylua /usr/local
