#!/bin/bash
set -e

DIR=$( dirname "$0" )

echo "Removing k8s cluster VMs. Leaving k8scp alone."
(pwd; vagrant destroy cp1 cp2 cp3 n1 n2 n3 -f)

# clean up data dir. These directories are created by vagrant and used by k8s
# etcd will fail to start if they are not empty
DATA_DIR="${DIR}/../../data"
echo "Cleaning files from ${DATA_DIR}"
rm -rf $DATA_DIR/etcd-cp1/*
rm -rf $DATA_DIR/etcd-cp2/*
rm -rf $DATA_DIR/etcd-cp3/*