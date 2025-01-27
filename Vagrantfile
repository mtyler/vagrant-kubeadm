# -*- mode: ruby -*-
# vi: set ft=ruby :

SYSTEM_PREP_SH = "scripts/system-prep.sh"
# This hash will replace settings.yaml
cluster = {
  :name => "k8s",
  :box => "bento/ubuntu-22.04",
  :pod_cidr => "172.16.1.0/16",
  :service_cidr => "172.17.1.0/18",
  # if true, the shared folders will be created to store etcd data on this host
  :persist => false
}

nodes = {
  "k8scp" => {
    :role => "proxy",
    :ip => "10.0.0.10",
    :cpus => 1,
    :memory => 2048,
    :shared_folders => [
      {
        host_path: "../data/k8scp",
        vm_path: "/usr/data"
      }
    ],
    :provision => "scripts/k8scp-proxy.sh"
  },
  "cp1" => {
    :role => "control",
    :ip => "10.0.0.11",
    :cpus => 2,
    :memory => 4096,
    :shared_folders => [
      {
        host_path: "../data/cp1",
        vm_path: "/var/lib/etcd"
      }
    ],
    :provision => "scripts/kubeadm-init-cp1.sh"
  },
  "cp2" => {
    :role => "control",
    :ip => "10.0.0.12",
    :cpus => 2,
    :memory => 4096,
    :shared_folders => [
      {
        host_path: "../data/cp2",
        vm_path: "/var/lib/etcd"
      }
    ],
    :provision => "scripts/kubeadm-join-cpx.sh"
  },
  "cp3" => {
    :role => "control",
    :ip => "10.0.0.13",
    :cpus => 2,
    :memory => 4096,
    :shared_folders => [
      {
        host_path: "../data/cp3",
        vm_path: "/var/lib/etcd"
      }
    ],
    :provision => "scripts/kubeadm-join-cpx.sh"
  },
  "n1" => {
    :role => "worker",
    :ip => "10.0.0.21",
    :cpus => 1,
    :memory => 2048,
    :shared_folders => [
      {
        host_path: "../data/n1",
        vm_path: "/usr/data"
      }
    ],
    :provision => "scripts/kubeadm-join-node.sh"
  },
  "n2" => {
    :role => "worker",
    :ip => "10.0.0.22",
    :cpus => 1,
    :memory => 2048,
    :shared_folders => [
      {
        host_path: "../data/n2",
        vm_path: "/usr/data"
      }
    ],
    :provision => "scripts/kubeadm-join-node.sh"
  },
  "n3" => {
    :role => "worker",
    :ip => "10.0.0.23",
    :cpus => 1,
    :memory => 2048,
    :shared_folders => [
      {
        host_path: "../data/n3",
        vm_path: "/usr/data"
      }
    ],
    :provision => "scripts/kubeadm-join-node.sh"
  }
}

Vagrant.configure("2") do |config|
  #hostsfile = cluster[:domain_ip] + " " + cluster[:domain] + "\r\n"
  hostsfile = ""
  nodes.each do |hostname, node|
    hostsfile += node[:ip] + " " + hostname + "\r\n"  
  end

  nodes.each do |hostname, node|
    config.vm.box = cluster[:box]
    config.vm.box_check_update = true
  
    config.vm.define hostname do |cfg|
      cfg.vm.hostname = hostname
      cfg.vm.network "private_network", ip: node[:ip]
      if cluster[:persist]
        if node[:shared_folders]
          node[:shared_folders].each do |shared_folder|
            cfg.vm.synced_folder shared_folder[:host_path], shared_folder[:vm_path]
          end
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
          cfg.vm.provision "shell",
          env: {},
          path: SYSTEM_PREP_SH
      end

      cfg.vm.provision "shell",
      env: {},
      path: node[:provision]
    end
  end
end
