FROM debian:testing
RUN apt-get update && \
    apt-get -y install \
    build-essential \
    cargo \
    cmake \
    curl \
    git \
    libreadline-dev \
    libssl-dev \
    libyaml-dev \
    libzip-dev \
    lua5.1 \
    luarocks \
    ninja-build \
    pre-commit \
    python3-pip \
    ruby \
    tar \
    unzip \
    zip && \
    apt-get clean
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
RUN cargo install --root=/usr/local stylua
