FROM mcr.microsoft.com/vscode/devcontainers/python:3 AS devcontainer
RUN apt-get update \
    && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
        autoconf-archive \
        build-essential \
        ca-certificates \
        git \
        luacheck \
        ninja-build \
        ruby-dev \
    && pip install cmake jinja2 pre-commit \
    && git config --system --add safe.directory '*'
WORKDIR /wowless
