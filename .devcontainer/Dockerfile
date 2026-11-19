FROM mcr.microsoft.com/devcontainers/base:trixie AS devcontainer
# Single-user Nix install owned by the devcontainer user, with no daemon.
# The build sandbox is off since it needs privileges containers lack.
RUN mkdir -m 0755 /nix /etc/nix \
    && chown vscode:vscode /nix \
    && printf '%s\n' 'experimental-features = nix-command flakes' 'sandbox = false' > /etc/nix/nix.conf \
    && git config --system --add safe.directory '*'
USER vscode
RUN curl -sSfL https://releases.nixos.org/nix/nix-2.34.6/install \
        | sh -s -- --no-daemon --no-channel-add --no-modify-profile
# Development tools come from the flake's devcontainer package, so they match
# what `nix develop` provides outside the container.
COPY flake.nix flake.lock /tmp/wowless-flake/
RUN /home/vscode/.nix-profile/bin/nix profile add path:/tmp/wowless-flake#devcontainer \
    && /home/vscode/.nix-profile/bin/nix store gc
ENV PATH=/home/vscode/.nix-profile/bin:$PATH
USER root
RUN rm -rf /tmp/wowless-flake
WORKDIR /wowless
