FROM debian:testing AS tainted-lua-builder
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        build-essential \
        cmake \
        libreadline-dev \
        ninja-build && \
    apt-get clean
WORKDIR /build
COPY tainted-lua .
RUN cmake --preset linux && \
    cmake --build --preset linux && \
    cmake --install build/linux --prefix /opt/tainted-lua

FROM debian:testing AS wowless-builder
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        build-essential \
        ca-certificates \
        git \
        libexpat-dev \
        libssl-dev \
        libyaml-dev \
        libzip-dev \
        lua5.1 \
        luarocks && \
    apt-get clean
WORKDIR /wowless
COPY wowless-scm-0.rockspec .
RUN luarocks build --deps-only
COPY wowless /wowless/wowless
RUN luarocks build --no-install

FROM debian:testing-slim AS runtime
RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        libexpat1 \
        libreadline8 \
        libyaml-0-2 \
        libzip4 && \
    apt-get clean
WORKDIR /wowless
COPY --from=tainted-lua-builder /opt/tainted-lua /opt/tainted-lua
COPY --from=wowless-builder /usr/local/lib/lua /usr/local/lib/lua
COPY --from=wowless-builder /usr/local/share/lua /usr/local/share/lua
COPY --from=wowless-builder /wowless/wowless wowless
COPY data data
COPY tools tools
COPY wowapi wowapi
COPY wowless.lua .
ENTRYPOINT ["/opt/tainted-lua/bin/lua5.1", "wowless.lua"]
