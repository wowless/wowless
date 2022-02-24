FROM debian:testing
RUN apt update && \
    apt -y install \
    build-essential \
    cmake \
    curl \
    git \
    libexpat-dev \
    libreadline-dev \
    libssl-dev \
    libyaml-dev \
    libzip-dev \
    lua5.1 \
    luarocks \
    ninja-build \
    tar \
    unzip \
    zip && \
    apt clean
RUN echo \
    argparse \
    bitlib \
    busted \
    cluacov \
    json-lua \
    libdeflate \
    luacheck \
    luadbd \
    luaexpat \
    luautf8 \
    lua-path \
    lyaml \
    minheap \
    penlight \
    serpent \
    wowcig \
    | xargs -n1 luarocks install
