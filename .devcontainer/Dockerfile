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
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt install gh
