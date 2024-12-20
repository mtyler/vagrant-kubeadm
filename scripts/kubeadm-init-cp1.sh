#!/bin/bash

#
# Create first control plane node using central hostname
#
sudo kubeadm init --control-plane-endpoint "k8scp" \
     --pod-network-cidr "172.16.1.0/16" \
     --service-cidr "172.17.1.0/18" \
     --node-name "cp1" \
     --upload-certs | tee /vagrant/kubeadm-init-cp1.out

#
# Setup .kube/config
#
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
echo "alias k='kubectl'" >> .bashrc
echo "source <(kubectl completion bash)" >> .bashrc

kubectl taint nodes cp1 node-role.kubernetes.io/control-plane-

#
# Install Calico Network Plugin
#
CALICO_VERSION="3.29.0"
kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v${CALICO_VERSION}/manifests/calico.yaml

## removing cilium networking. 
## Works well, however, it requires additional configuration to allow traffic on the 10.0.0.x network
## 
### 
###  install cilium networking 
###
##CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/main/stable.txt)
##CLI_ARCH=amd64
##if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
##curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
##sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
##sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
##rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
##
##cilium install --version 1.16.3
##cilium status --wait
##cilium connectivity test

#
# Install Metrics Server
#
kubectl apply -f https://raw.githubusercontent.com/techiescamp/kubeadm-scripts/main/manifests/metrics-server.yaml



