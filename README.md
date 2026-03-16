# Nusje2000 dots

This repository contains dot files and setup scripts for setting up my
development environment.

## Dockerized IDE

Run the full IDE environment (neovim, tmux, zsh) in Docker without installing anything locally:

```bash
wget -qO /tmp/ide.sh https://raw.githubusercontent.com/nusje2000/dots/main/bin/run_ide.sh && sh /tmp/ide.sh
```

This mounts the current directory into the container at `/ide`, shares the host's Docker daemon, and preserves your SSH keys.

## Updating

To update an existing environment, `bin/update.sh` can be used. This
command will install missing applications and dependencies.

### Applications that are not installed using update.sh

-   Google Chrome
-   Spotify
-   DataGrip
-   1Password

## Components

### TMUX

Custom tmux configuration including:

-   [Statusbar](https://github.com/2KAbhishek/tmux2k)
-   [URL Launcher](https://github.com/wfxr/tmux-fzf-url) (C-a + u)

### Bash

-   [FZF](https://github.com/junegunn/fzf)

## Missing features

-   Automatically clone common projects (otf, syntec, etc.)
-   Setup public/private key using 1password CLI
-   Remove old node version if preset
    -   Remove ~/.npm-global as well

# Pop!OS

## Dual Boot

```bash
# Add to /boot/efi/loader/loader.conf
timeout 10
entries 1
```

### Install OS Prober

```bash
sudo apt update
sudo apt install os-prober -y
```

### Run OS Prober

```bash
sudo os-prober

# Will return something like /dev/somedir@...
# Use everything before the @ as the path for
# the next command
sudo mount <path> /mnt

sudo cp -ax /mnt/EFI/Microsoft /boot/efi/EFI
sudo reboot
```

### Missing driver for ASUS Wifi Adapter

```bash
sudo apt-get install bcmwl-kernel-source
sudo modprobe wl
sudo reboot
```

# LSP

## PHP

#### Different project root

```json
{
    "$schema": "/home/maartenn/.local/share/nvim/mason/packages/phpactor/phpactor.schema.json",
    "symfony.enabled": true,
    "symfony.xml_path": "%project_root%/other-root/var/cache/dev/App_KernelDevDebugContainer.xml",
    "class_to_file.project_root": "%project_root%/other-root",
    "language_server_phpstan.bin": "%project_root%/other-root/vendor/bin/phpstan",
    "composer.autoloader_path": "%project_root%/other-root",
    "indexer.project_root": "%project_root%/other-root"
}
```
