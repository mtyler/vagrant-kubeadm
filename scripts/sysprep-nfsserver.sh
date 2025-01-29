#!/bin/bash
# Create an NFS server and share

sudo apt-get update && sudo apt-get install -y nfs-kernel-server

sudo mkdir -p /var/nfs
sudo mkdir -p /var/nfs/k8s-cluster
sudo chown -R nobody:nogroup /var/nfs/k8s-cluster
sudo chmod 777 /var/nfs/k8s-cluster

sudo systemctl enable nfs-kernel-server.service

EXPORT="/var/nfs/k8s-cluster 10.0.0.0/24(rw,sync,no_subtree_check,fsid=10)\n\
/var/nfs/k8s-cluster 172.16.1.0/16(rw,sync,no_subtree_check,fsid=16)\n\
/var/nfs/k8s-cluster 172.17.1.0/18(rw,sync,no_subtree_check,fsid=17)"

sudo grep -xF "${EXPORT}" /etc/exports || sudo sed -i -e "\$a${EXPORT}" /etc/exports

sudo exportfs -a
sudo systemctl restart nfs-kernel-server.service

# lay down a file for the client to test
touch /var/nfs/k8s-cluster/hello.k8s-cluster

