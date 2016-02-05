#!/bin/sh

# MondoDB
# https://docs.mongodb.org/manual/tutorial/install-mongodb-on-ubuntu/
#

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
echo "deb http://repo.mongodb.org/apt/ubuntu `lsb_release -cs`/mongodb-org/3.2 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.2.list
sudo apt-get update
sudo apt-get install -y mongodb-org

# Disable Transparent Huge Pages (THP)
# https://docs.mongodb.org/manual/tutorial/transparent-huge-pages/
#

sudo cp etc/init.d/disable-transparent-hugepages /etc/init.d/disable-transparent-hugepages
sudo chmod 755 /etc/init.d/disable-transparent-hugepages
sudo update-rc.d disable-transparent-hugepages defaults

# Need reboot


# Pin a specific version of MongoDB.
# echo "mongodb-org hold" | sudo dpkg --set-selections
# echo "mongodb-org-server hold" | sudo dpkg --set-selections
# echo "mongodb-org-shell hold" | sudo dpkg --set-selections
# echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
# echo "mongodb-org-tools hold" | sudo dpkg --set-selections

# sudo service mongod start
