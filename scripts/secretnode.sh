#!/bin/bash

export DEBIAN_FRONTEND=noninteractive

# Aesm service relies on this folder and having write permissions
# shellcheck disable=SC2174
mkdir -p -m 777 /tmp/aesmd
chmod -R -f 777 /tmp/aesmd || sudo chmod -R -f 777 /tmp/aesmd || true

apt update
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -

add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
apt update
apt install docker-ce -y

# systemctl status docker
curl -L https://github.com/docker/compose/releases/download/1.26.0/docker-compose-"$(uname -s)"-"$(uname -m)" -o /usr/local/bin/docker-compose

chmod +x /usr/local/bin/docker-compose

docker-compose --version

mkdir -p /usr/local/bin/secret-node

curl -L https://raw.githubusercontent.com/Cashmaney/secret-node-azure-template/master/scripts/docker-compose.yaml -o /usr/local/bin/secret-node/docker-compose.yaml

usermod -aG docker $(AZUSERNAME)

################################################################
# Configure to auto start at boot					    #
################################################################
file=/etc/init.d/secret-node
if [ ! -e "$file" ]
then
	printf '%s\n%s\n' '#!/bin/sh' 'docker-compose -f /usr/local/bin/secret-node/docker-compose.yaml up -d' | sudo tee /etc/init.d/secret-node
	sudo chmod +x /etc/init.d/secret-node
	sudo update-rc.d secret-node defaults
fi
