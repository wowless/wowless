FROM python:bullseye AS elune-builder
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libreadline-dev \
        ninja-build && \
    apt-get clean && \
    pip3 install cmake
WORKDIR /build
COPY elune .
RUN cmake --preset linux && \
    cmake --build --preset linux && \
    cmake --install build/linux --prefix /opt/elune

FROM python:bullseye AS wowless-builder
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libexpat-dev \
        libmagickwand-dev \
        libssl-dev \
        libyaml-dev \
        libzip-dev && \
    apt-get clean && \
    pip3 install hererocks && \
    hererocks -l 5.1 -r 3.8.0 /usr/local
WORKDIR /wowless
COPY wowless-scm-0.rockspec .
RUN luarocks build --deps-only
COPY wowless /wowless/wowless
RUN luarocks build --no-install

FROM debian:bullseye-slim AS runtime
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        libexpat1 \
        libmagickwand-6.q16-6 \
        libreadline8 \
        libyaml-0-2 \
        libzip4 && \
    apt-get clean
WORKDIR /wowless
COPY --from=elune-builder /opt/elune /opt/elune
COPY --from=wowless-builder /usr/local/lib/lua /usr/local/lib/lua
COPY --from=wowless-builder /usr/local/share/lua /usr/local/share/lua
COPY --from=wowless-builder /wowless/wowless wowless
COPY data data
COPY tools tools
COPY wowapi wowapi
COPY wowless.lua .
ENTRYPOINT ["/opt/elune/bin/lua5.1", "wowless.lua"]
