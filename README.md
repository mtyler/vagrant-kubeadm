## Vagrant based K8s cluster for personal use

## Prerequisites

A working Vagrant setup using VMware Fusion on MacOS ARM64.

## Bring Up the Cluster

To provision the cluster, execute the following commands.

> Important Note: You have to use sudo with all the vagrant commands.

```shell
git clone https://github.com/mtyler/vagrant-kubeadm.git
cd vagrant-kubeadm
sudo vagrant up
```

Once the cluster is up, run kubeadm using the provided script on the control plane node

```shell
cd vagrant-kubeadm
vagrant ssh cp1
sudo /vagrant/scripts/kubeadm-init-cp1.sh
```

Follow the instructions in the log output to join remaining nodes

## Set Kubeconfig file variable

You can connect to the Vagrant cluster from your local mac terminal by configuring the following.

```shell
cd vagrant-kubeadm
sudo chmod +r config 
export KUBECONFIG=$(pwd)/config
```

or you can copy the config file to .kube directory.

```shell
cp config ~/.kube/
```

Validate the cluster access

```shell
kubectl get po -n kube-system
```

## To shutdown the cluster,

```shell
sudo vagrant halt
```

## To restart the cluster,

```shell
sudo vagrant up
```

## To destroy the cluster,

```shell
sudo vagrant destroy -f
```
