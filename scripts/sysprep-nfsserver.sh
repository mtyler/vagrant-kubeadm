#!/bin/bash
# Create an NFS server and share
set -e

echo "****************************************************************"
echo "Begin configuring nfs server"

sudo apt-get update && sudo apt-get install -y nfs-kernel-server

SHARE_NAME="k8s-cluster-pvs"
# /var/nfs$SHARE_NAME - vagrant share, not able to change perms
sudo mkdir -p /var/nfs
sudo mkdir -p /var/nfs/$SHARE_NAME
# /nfs$SHARE_NAME - nfs share 
sudo mkdir -p /nfs
sudo mkdir -p /nfs/$SHARE_NAME
# permissions required for nfs server
sudo chown -R nobody:nogroup /nfs/$SHARE_NAME
sudo chmod 777 /nfs/$SHARE_NAME
# link to make directories available on host machine
sudo ln -s /nfs/$SHARE_NAME

sudo systemctl enable nfs-kernel-server.service

EXPORT="/nfs/$SHARE_NAME 10.0.0.0/24(rw,sync,no_subtree_check,fsid=10)\n\
/nfs/$SHARE_NAME 172.16.1.0/16(rw,sync,no_subtree_check,fsid=16)\n\
/nfs/$SHARE_NAME 172.17.1.0/18(rw,sync,no_subtree_check,fsid=17)"

echo "Apending /etc/exports with the following entries"
echo "${EXPORT}"

sudo grep -xF "${EXPORT}" /etc/exports || sudo sed -i -e "\$a${EXPORT}" /etc/exports

sudo exportfs -a
sudo systemctl restart nfs-kernel-server.service

# lay down a file for the client to test
touch /nfs/$SHARE_NAME/hello.k8s-cluster

