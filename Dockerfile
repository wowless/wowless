FROM debian:testing
WORKDIR /wowless
COPY packages.txt .
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    cat packages.txt | xargs apt-get -y install --no-install-recommends && \
    apt-get clean
COPY wowless-scm-0.rockspec .
RUN luarocks build --deps-only
COPY . .
RUN bin/build.sh
