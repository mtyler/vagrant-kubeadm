# -*- mode: ruby -*-
# vi: set ft=ruby :

# cluster-wide settings
cluster = {
  :name => "k8s",
  :box => "bento/ubuntu-22.04",
  :pod_cidr => "172.16.1.0/16",
  :service_cidr => "172.17.1.0/18",
  :domain => "k8s.local",
  # if true, the shared folders will be created to store etcd data on this host
  :persist => true,
  :kubeadm_prereq => "scripts/sysprep-kubeadm.sh",
  :nfs_share => "/var/nfs/k8s-cluster-pvs"
}

# VMs
nodes = {
  "k8scp" => {
    :role => "proxy",
    :ip => "10.0.0.10",
    :cpus => 1,
    :memory => 2048,
    :provision => "scripts/k8scp-proxy.sh"
  },
  # This node is must be started before cp2, cp3, n1, n2, n3
  #
  # etcd runs on the controlplane and steps need to be taken to ensure 
  # it can elect a leader.
  #   cp1 should run alone
  #      OR
  #   cp1, cp2 and cp3 should all run together  
  #
  "cp1" => {
    :role => "control",
    :ip => "10.0.0.11",
    :cpus => 2,
    :memory => 4096,
    :shared_folders => [
      {
        host_path: "../data/etcd-cp1",
        vm_path: "/var/lib/etcd"
      },
      {
        host_path: "../data/#{cluster[:nfs_share]}",
        vm_path: cluster[:nfs_share]
      }
    ],
    :provision => "scripts/kubeadm-init-cp1.sh",
    :nfs_service => "scripts/sysprep-nfsserver.sh"
  },
  "cp2" => {
    :role => "control",
    :ip => "10.0.0.12",
    :cpus => 2,
    :memory => 4096,
    :shared_folders => [
      {
        host_path: "../data/etcd-cp2",
        vm_path: "/var/lib/etcd"
      }
    ],
    :provision => "scripts/kubeadm-join-cpx.sh"
    #, :nfs_service => "scripts/sysprep-nfsclient.sh"
  },
  "cp3" => {
    :role => "control",
    :ip => "10.0.0.13",
    :cpus => 2,
    :memory => 4096,
    :shared_folders => [
      {
        host_path: "../data/etcd-cp3",
        vm_path: "/var/lib/etcd"
      }
    ],
    :provision => "scripts/kubeadm-join-cpx.sh"
    #, :nfs_service => "scripts/sysprep-nfsclient.sh"
  },
  "n1" => {
    :role => "worker",
    :ip => "10.0.0.21",
    :cpus => 1,
    :memory => 2048,
    :provision => "scripts/kubeadm-join-node.sh"
  },
  "n2" => {
    :role => "worker",
    :ip => "10.0.0.22",
    :cpus => 1,
    :memory => 2048,
    :provision => "scripts/kubeadm-join-node.sh"
  },
  "n3" => {
    :role => "worker",
    :ip => "10.0.0.23",
    :cpus => 1,
    :memory => 2048,
    :provision => "scripts/kubeadm-join-node.sh"
  }
}

Vagrant.configure("2") do |config|
  hostsfile = ""
  nodes.each do |hostname, node|
    hostsfile += node[:ip] + " " + hostname + " " + hostname + "." + cluster[:domain] + "\r\n"  
  end

  nodes.each do |hostname, node|
    config.vm.box = cluster[:box]
    config.vm.box_check_update = true
  
    config.vm.define hostname do |cfg|
      cfg.vm.hostname = hostname
      cfg.vm.network "private_network", ip: node[:ip]
      if cluster[:persist]
      # configure shared folders to persist data on the local file system
        if node[:shared_folders]
          node[:shared_folders].each do |shared_folder|
            cfg.vm.synced_folder shared_folder[:host_path], shared_folder[:vm_path], create: true
          end
        end
        # nfs shares
        if node[:nfs_service] 
          cfg.vm.provision "shell", env: {}, path: node[:nfs_service]
        end
      end

      cfg.vm.provider "vmware_fusion" do |vb|
        vb.cpus = node[:cpus]
        vb.memory = node[:memory]
      end

      # Lay down the /etc/hosts file
      cfg.vm.provision "shell", env: { "hostsfile" => hostsfile }, inline: <<-SHELL  
        echo "${hostsfile}" >> /etc/hosts
      SHELL
      
      # prepare system for k8s
      if ["control", "worker"].include? node[:role]
          cfg.vm.provision "shell", env: {}, path: cluster[:kubeadm_prereq]
      end

      # kubeadm commands
      if node[:provision]
        cfg.vm.provision "shell", env: {}, path: node[:provision]
      end  
    end
  end
end
