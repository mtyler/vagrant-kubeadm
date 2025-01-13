#!/bin/bash
set -euxo pipefail

#
# prepare DNS
#
sudo mkdir -p /etc/systemd/resolved.conf.d
cat <<EOF | sudo tee /etc/systemd/resolved.conf.d/dns_servers.conf
[Resolve]
DNS=8.8.8.8
EOF

sudo systemctl restart systemd-resolved

#
# turn off swap
#
sudo swapoff -a
# remove swap config
sudo sed -i '/\tswap\t/d' /etc/fstab

#
# configure Network & iptables
#
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF

sudo modprobe overlay
sudo modprobe br_netfilter

# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system

echo -e "\n\n system settiings modified. Begin package installs. \n\n"

#
# add basic tools
#
sudo apt-get update -y
sudo apt-get install -y software-properties-common curl apt-transport-https ca-certificates jq

#
# install Container Runtime 
# Containerd is pulled from the docker repo and installed with Apt
#
# *containerd.io package includes runc
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update -y
sudo apt-get install -y containerd.io

# generate default containerd config
sudo containerd config default > config.toml
sudo mv config.toml /etc/containerd/config.toml

# update settings required by k8s
sudo sed -i 's/^disabled_plugins \=/\#disabled_plugins \=/g' /etc/containerd/config.toml
sudo sed -i 's/SystemdCgroup \= false/\SystemdCgroup \= true/g' /etc/containerd/config.toml

# cni plugins for containerd
CNI_VER="1.6.0"
ARCH="arm"
sudo mkdir -p /opt/cni/bin/
sudo wget https://github.com/containernetworking/plugins/releases/download/v${CNI_VER}/cni-plugins-linux-${ARCH}-v${CNI_VER}.tgz
sudo tar Cxzf /opt/cni/bin cni-plugins-linux-${ARCH}-v${CNI_VER}.tgz

sudo systemctl restart containerd

#
# Install Kube packages from kubernetes repo
#
K8S_VER="1.32"
curl -fsSL https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${K8S_VER}/deb/ /" | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt-get update -y

#BIN_VER="1.31.2-1.1"
#sudo apt-get install -y kubeadm=$BIN_VER kubectl=$BIN_VER kubelet=$BIN_VER 
sudo apt-get install -y kubeadm kubectl kubelet
sudo apt-mark hold kubeadm kubectl kubelet
sudo systemctl enable --now kubelet

# print status 
sudo ctr version
sudo systemctl status containerd
sudo systemctl status kubelet

echo -e "\n\nDone.\n"