FROM debian:testing
WORKDIR /wowless
COPY packages.txt .
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends \
    $(cat packages.txt) \
    cargo \
    pre-commit \
    python3-dev \
    python3-pip \
    ruby \
    zip && \
    apt-get clean
RUN cargo install --root=/usr/local stylua
COPY wowless-scm-0.rockspec .
RUN luarocks build --deps-only
