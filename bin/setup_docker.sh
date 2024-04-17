set -e

source $(dirname "$0")/functions.sh

if [ ! -f /etc/apt/keyrings/docker.asc ]; then
    loading "Adding docker apt repository..."

    sudo apt-get update
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    success "Added docker apt repository"
else
    success "docker apt repository was already present"
fi

install_if_missing "docker-ce"
install_if_missing "docker-ce-cli"
install_if_missing "containerd.io"
install_if_missing "docker-buildx-plugin"
install_if_missing "docker-compose-plugin"
