#!/bin/sh

# As root

useradd -m baden -d /home/baden -s /bin/bash
usermod -aG sudo baden
passwd baden

echo "baden soft nofile 9192"  > /etc/security/limits.d/erlnavicc.conf
echo "baden hard nofile 9192" >> /etc/security/limits.d/erlnavicc.conf

# С рабочей машины скопируем ключи
# ssh-keygen -q (один раз)
# ssh-copy-id baden@my.baden.work
# После этого можно заходить:
# ssh baden@my.baden.work
