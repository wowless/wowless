FROM mcr.microsoft.com/vscode/devcontainers/python:3 AS devcontainer
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        autoconf-archive \
        build-essential \
        ca-certificates \
        git \
        ninja-build \
        ruby-dev \
    && pip install git+https://github.com/luarocks/hererocks cmake jinja2 pre-commit \
    && hererocks -l 5.1 -r 3.8.0 /usr/local \
    && luarocks install luacheck \
    && git config --system --add safe.directory '*'
WORKDIR /wowless
