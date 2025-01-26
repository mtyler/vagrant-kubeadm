## Vagrant based K8s cluster for personal use

## Prerequisites

A working Vagrant setup using VMware Fusion on MacOS ARM64.

## Bring Up the Cluster

To provision the cluster, execute the following commands.

> Important Note: You may or may not need to use sudo with all the vagrant commands.

```shell
git clone https://github.com/mtyler/vagrant-kubeadm.git
cd vagrant-kubeadm

# bring up the proxy 
vagrant up k8scp

# bring up first Control Plane
vagrant up cp1

# once cp1 is successfully running, any other combination of nodes can 
# be added or not
vagrant up cp2 cp3 n1 n2 n3
```

Once the cluster is up you should see the following files created

- ./scripts/kubeadm-join-node.sh
- ./scripts/kubeadm-join-cp.sh
- ./kubeadm-init-cp1.out
- ./kubeconfig

## Set Kubeconfig file variable

You can connect to the Vagrant cluster from your local mac terminal by configuring the following.

```shell
cd vagrant-kubeadm
sudo chmod +r kubeconfig 
export KUBECONFIG=$(pwd)/config
```

or you can copy the config file to .kube directory.

```shell
cd vagrant-kubeadm
mv kubeconfig ~/.kube/config
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
