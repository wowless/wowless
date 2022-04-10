FROM rust:slim-bullseye AS stylua-builder
RUN cargo install --root=/opt/stylua --version=0.12.4 stylua

FROM debian:testing AS devcontainer
WORKDIR /wowless
COPY packages.txt .
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install --no-install-recommends \
    $(cat packages.txt) \
    pre-commit \
    python3-dev \
    python3-pip \
    ruby \
    zip && \
    apt-get clean
COPY --from=stylua-builder /opt/stylua /usr/local
COPY wowless-scm-0.rockspec .
RUN luarocks build --deps-only
