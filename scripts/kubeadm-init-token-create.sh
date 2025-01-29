#!/bin/sh
set -e

# DEPRECATED #

# get the full path of the script
DIR=$( dirname "$0" )

# Create a join command to be used by worker nodes
sudo kubeadm token create --print-join-command > $DIR/kubeadm-join-node.sh
echo "sudo $(cat ${DIR}/kubeadm-join-node.sh)" > $DIR/kubeadm-join-node.sh

# Extract the certificate key from the output
#TODO extract the certificate key from the certificate key
CERT_KEY=$(grep -oP '(?<=--certificate-key )\S+' ${DIR}/kubeadm-init-cp1.out)
CONTROL_PLANE_JOIN_CMD=$(cat $DIR/kubeadm-join-node.sh)
## Create a join command to be used by additional control-plane nodes
echo "$CONTROL_PLANE_JOIN_CMD --control-plane --certificate-key $CERT_KEY" > $DIR/kubeadm-join-cpx.sh
