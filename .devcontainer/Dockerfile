FROM rust:slim-bullseye AS stylua-builder
RUN cargo install --root=/opt/stylua --version=0.12.4 stylua

FROM debian:testing AS devcontainer
WORKDIR /wowless
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        git \
        libexpat-dev \
        libreadline-dev \
        libssl-dev \
        libyaml-dev \
        libzip-dev \
        ninja-build \
        python3-dev \
        python3-pip \
        ruby \
        tar \
        unzip \
        zip \
    && pip install git+https://github.com/luarocks/hererocks pre-commit \
    && hererocks -l 5.1 -r 3.8.0 /usr/local
COPY --from=stylua-builder /opt/stylua /usr/local
COPY wowless-scm-0.rockspec .
RUN luarocks build --deps-only
