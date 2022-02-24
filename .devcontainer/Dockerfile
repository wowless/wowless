FROM lua-wow-tools/wowless:base
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
    dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) \
    signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
    https://cli.github.com/packages stable main" | \
    tee /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt -y install \
    cargo \
    git \
    pre-commit \
    python3-pip \
    ruby \
    zip && \
    apt clean
RUN cargo install --root=/usr/local stylua
