#!/bin/bash
set -e

echo "****************************************************************"
echo "Begin initializing the first control plane node"
#
# Create first control plane node using central hostname
#
# use the kubeadm-config.yaml file to configure the kubeadm init command
# bind-address: 0.0.0.0 is required for prometheus to scrape metrics
SCRIPT_DIR="/vagrant/scripts"
sudo kubeadm init --config $SCRIPT_DIR/kubeadm-config.yaml \
     --upload-certs | tee $SCRIPT_DIR/kubeadm-init-cp1.out

# create/update the join scripts
#    more work req to get this functional, file is run from /tmp
# source $SCRIPT_DIR/kubeadm-init-token-create.sh

# Create a join command to be used by worker nodes
sudo kubeadm token create --print-join-command > $SCRIPT_DIR/kubeadm-join-node.sh
echo "sudo $(cat ${SCRIPT_DIR}/kubeadm-join-node.sh)" > $SCRIPT_DIR/kubeadm-join-node.sh

# Extract the certificate key from the output
#TODO extract the certificate key from the certificate key
CERT_KEY=$(grep -oP '(?<=--certificate-key )\S+' ${SCRIPT_DIR}/kubeadm-init-cp1.out)
CONTROL_PLANE_JOIN_CMD=$(cat $SCRIPT_DIR/kubeadm-join-node.sh)
## Create a join command to be used by additional control-plane nodes
echo "$CONTROL_PLANE_JOIN_CMD --control-plane --certificate-key $CERT_KEY" > $SCRIPT_DIR/kubeadm-join-cpx.sh

#
# Setup .kube/config
#
sudo mkdir -p $HOME/.kube
sudo cp -f /etc/kubernetes/admin.conf $HOME/.kube/config
sudo cp -f /etc/kubernetes/admin.conf $SCRIPT_DIR/kubeconfig
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo "alias k='kubectl'" >> .bashrc
echo "source <(kubectl completion bash)" >> .bashrc

kubectl taint nodes cp1 node-role.kubernetes.io/control-plane-

#
# Install Calico Network Plugin
#
CALICO_VERSION="3.29.0"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/calico.yaml
