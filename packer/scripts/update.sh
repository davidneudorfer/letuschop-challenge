#!/bin/bash -eux

UBUNTU_VERSION=`lsb_release -r | awk '{print $2}'`
# on 12.04 work around bad cached lists
if [[ "$UBUNTU_VERSION" == '12.04' ]]; then
  apt-get clean
  rm -rf /var/lib/apt/lists
fi

# Update the list of keys used by apt to verify packages
apt-key update

# Update the package list
apt-get update

# Upgrade all installed packages
apt-get -y upgrade

# Upgrade to 16.04.1 LTS
do-release-upgrade

# update package index on boot
cat <<EOF > /etc/init/refresh-apt.conf
description "update package index"
start on networking
task
exec /usr/bin/apt-get update
EOF

shutdown -r now
