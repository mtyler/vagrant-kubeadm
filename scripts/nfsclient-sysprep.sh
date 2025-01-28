#!/bin/bash
# attach to an NFS share

NFSSERVER='10.0.0.11'
sudo apt-get update && sudo apt-get install -y nfs-common
sudo mkdir -p /nfs
sudo mkdir -p /nfs/k8s-cluster

sudo mount -t nfs4 $NFSSERVER:/var/nfs/k8s-cluster /nfs/k8s-cluster
# TODO edit /etc/fstab
if [ -f /nfs/k8s-cluster/hello.k8s-cluster ]; then
  echo "success."
else
  echo "oh noes!"
fi