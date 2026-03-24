FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

# Install core dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    wget \
    unzip \
    ripgrep \
    fd-find \
    fzf \
    tmux \
    zsh \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    nodejs \
    npm \
    luarocks \
    luajit \
    libluajit-5.1-dev \
    ca-certificates \
    gnupg \
    xclip \
    sudo \
    gosu \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Generate UTF-8 locale (required for nerd font icons in tmux)
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Install Rust (needed by CopilotChat tiktoken)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Docker CLI (uses the host's Docker daemon via socket mount)
RUN install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu noble stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update && apt-get install -y docker-ce-cli docker-compose-plugin \
    && rm -rf /var/lib/apt/lists/*

# Install latest Neovim from GitHub releases
RUN curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz \
    && tar -xzf nvim-linux-x86_64.tar.gz -C /opt \
    && ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim \
    && rm nvim-linux-x86_64.tar.gz

# Create ide user with sudo access
RUN useradd -m -s /bin/zsh ide \
    && echo 'ide ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

# Move rust to shared location
RUN mv /root/.cargo /home/ide/.cargo && mv /root/.rustup /home/ide/.rustup \
    && chown -R ide:ide /home/ide/.cargo /home/ide/.rustup
ENV PATH="/home/ide/.cargo/bin:${PATH}"

# Switch to ide user for remaining setup
USER ide
WORKDIR /home/ide

# Install Oh My Zsh
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

# Install TPM (Tmux Plugin Manager) and plugins
RUN git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
COPY --chown=ide:ide tmux/.tmux.conf /home/ide/.tmux.conf
RUN TMUX_PLUGIN_MANAGER_PATH="/home/ide/.tmux/plugins/" /home/ide/.tmux/plugins/tpm/bin/install_plugins

# Install packer.nvim
RUN git clone --depth 1 https://github.com/wbthomason/packer.nvim \
    ~/.local/share/nvim/site/pack/packer/start/packer.nvim

# Copy configurations
COPY --chown=ide:ide nvim/ /home/ide/.config/nvim/
COPY --chown=ide:ide shell/.aliases /home/ide/.zsh_aliases

# Create a minimal .zshrc adapted for the container
RUN printf '%s\n' \
    'export ZSH="$HOME/.oh-my-zsh"' \
    'ZSH_THEME="robbyrussell"' \
    'export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"' \
    'plugins=(git)' \
    'source $ZSH/oh-my-zsh.sh' \
    'source $HOME/.zsh_aliases' \
    '[ -f "$HOME/.secrets" ] || touch "$HOME/.secrets"' \
    'alias v="nvim"' \
    > /home/ide/.zshrc

# Create empty secrets file
RUN touch /home/ide/.secrets

# Install neovim plugins headlessly
RUN nvim --headless -c 'autocmd User PackerComplete quitall' -c 'PackerSync' 2>/dev/null || true

# Build LuaSnip jsregexp module
RUN cd /home/ide/.local/share/nvim/site/pack/packer/start/LuaSnip \
    && make install_jsregexp 2>/dev/null || true

# Install treesitter parsers
RUN nvim --headless -c 'TSInstallSync c lua vim vimdoc query typescript javascript html css php json yaml bash go python rust markdown markdown_inline' -c 'quitall' 2>/dev/null || true

# Pre-install common Mason LSP servers
RUN nvim --headless -c 'MasonInstall lua-language-server typescript-language-server css-lsp html-lsp json-lsp yaml-language-server bash-language-server pyright phpactor' -c 'quitall' 2>/dev/null || true

WORKDIR /ide

ENV SHELL=/bin/zsh
ENV TERM=xterm-256color

# Make home contents accessible to any UID (container-only, not a security concern)
USER root
RUN chmod -R a+rwX /home/ide

COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
