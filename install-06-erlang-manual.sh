#!/bin/sh

# As user
#

sudo apt-get install -y curl build-essential libncurses5-dev libssl-dev unixodbc-dev

curl -O https://raw.githubusercontent.com/yrashk/kerl/master/kerl
chmod a+x kerl
./kerl list releases

./kerl build R16B02 r16b02
# KERL_CONFIGURE_OPTIONS=--enable-hipe kerl build R16B02 r16b02_hipe

./kerl list builds
mkdir -p ~/.kerl/installs/r16b02
./kerl install r16b02 ~/.kerl/installs/r16b02
./kerl list installations


# Activate
. ~/.kerl/installs/r16b02/activate
erl -version
erl +B -noshell -noinput -eval 'io:format("~s~n", [erlang:system_info(otp_release)]),halt(0).'
./kerl active
./kerl status

# Install for ssh://git@bitbucket.org/badeniua/erl.navi.cc.git

sudo apt-get install git

# One time:
# ssh-keygen -f ~/.ssh/id_rsa
# ssh-keygen -f ~/.ssh/id_rsa -P "" &> /dev/null
cat ~/.ssh/id_rsa.pub
# Copy key to bitbucket (and github)
#
mkdir -p ~/SDK
cd ~/SDK
git clone git@bitbucket.org:badeniua/erl.navi.cc.git
cd erl.navi.cc
git checkout mss
make deps
make compile
make run
