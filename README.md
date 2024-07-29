# Nusje2000 dots

This repository contains dot files and setup scripts for setting up my
development environment.

## Updating

To update an existing environment, `bin/update.sh` can be used. This
command will install missing applications and dependencies.

### Applications that are not installed using update.sh

- Google Chrome
- Spotify
- DataGrip
- 1Password

## Missing features

- Automatically clone common projects (otf, syntec, etc.)
- Setup public/private key using 1password CLI
- Remove old node version if preset
    - Remove ~/.npm-global as well

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
