# Nusje2000 dots

This repository contains dot files and setup scripts for setting up my
development environment.

## Updating

To update an existing environment, `bin/update.sh` can be used. This
command will install missing applications and dependencies.

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

