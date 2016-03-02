#!/bin/sh

# As user
# Tested on 14.04 (LTS)

sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
echo "deb https://apt.dockerproject.org/repo ubuntu-`lsb_release -cs` main" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update
# Purge old install if it present
# apt-get purge lxc-docker
apt-cache policy docker-engine
sudo apt-get install linux-image-extra-$(uname -r)
sudo apt-get install apparmor

# !!! Require reboot if kernel is installed

sudo apt-get install docker-engine

# Add users who can run docker cli:

sudo usermod -aG docker baden

# For remote cli (unsecured):

echo 'DOCKER_OPTS="-H tcp://0.0.0.0:2375 ${DOCKER_OPTS}"' >> /etc/default/docker

docker_opts='DOCKER_OPTS="$DOCKER_OPTS -D -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"'
sudo sh -c "echo '$docker_opts' >> /etc/default/docker"
cat /etc/default/docker

echo "On remote client, set"
echo "export DOCKER_HOST=148.251.183.85:2375"

# For remote cli (secured):

# Generate certificates on server (as a root):

echo 'Generating pseudo random ca-password, use it as input when asked'
mkdir -p /etc/docker/certs
cd /etc/docker/certs
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1 | tee ./ca-password.txt

echo 'Generating ca-key, use ca-password as input'
openssl genrsa -aes256 -out ca-key.pem 4096

# C - Country name
# ST - State or province
# L - Locality
# O - Organization
# OU - Organization Unit
# CN - Common Name
#

# Актуальную инструкцию см в Create_Server_Certificate
#
# subject='/C=UA/ST=UA/L=Dnieprodzerzhinsk/O=BadenWork/OU=Erlnavi/CN=my.baden.work'
# openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -subj $subject -out ca.pem -passin file:./ca-password.txt
# openssl genrsa -out key.pem 4096
# openssl req -subj '/CN=client' -new -key key.pem -out client.csr
# echo extendedKeyUsage = clientAuth > extfile.cnf
# openssl x509 -req -days 365 -sha256 -in client.csr \
#   -CA ca.pem -CAkey ca-key.pem -CAcreateserial -extfile extfile.cnf \
#   -out cert.pem -passin file:./ca-password.txt
#
# chmod 0400 ca-key.pem key.pem ca-password.txt
# chmod 0444 ca.pem cert.pem
# rm client.csr extfile.cnf

docker_opts='DOCKER_OPTS="$DOCKER_OPTS -D -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --tlsverify --tlscacert=/etc/docker/certs/ca.pem --tlscert=/etc/docker/certs/server-cert.pem --tlskey=/etc/docker/certs/server-key.pem --label provider=herzner"'
sudo sh -c "echo '$docker_opts' >> /etc/default/docker"
cat /etc/default/docker


sudo service docker restart

## Testing

docker run --name hello --rm hello-world
#docker rm hello

# Or on remote client
#wget https://get.docker.com/builds/Linux/i386/docker-latest
#wget https://get.docker.com/builds/Linux/x86_64/docker-latest
#chmod a+x ./docker-latest
DOCKER_HOST=148.251.183.85:2375 docker run --rm hello-world
