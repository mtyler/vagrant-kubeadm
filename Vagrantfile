# -*- mode: ruby -*-
# vi: set ft=ruby :

SYSTEM_PREP_SH = "scripts/system-prep.sh"
# This hash will replace settings.yaml
cluster = {
  :name => "k8s",
  :box => "bento/ubuntu-22.04",
  #:box => "ubuntu/focal64",
  :pod_cidr => "172.16.1.0/16",
  :service_cidr => "172.17.1.0/18",
  :domain => "k8scp",
  :domain_ip => "10.0.0.11"
}

nodes = {
  "cp1" => {
    :role => "control",
    :ip => "10.0.0.11",
    :cpus => 2,
    :memory => 4096,
    :shared_folders => [
      {
        host_path: "../data/cp1",
        vm_path: "/usr/data"
      }
    ],
    :provision => "scripts/kubeadm-init-cp1.sh"
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
    :provision => "scripts/kubeadm-join.sh"
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
    :provision => "scripts/kubeadm-join.sh"
  }
}


Vagrant.configure("2") do |config|
  hostsfile = cluster[:domain_ip] + " " + cluster[:domain] + "\r\n"
  nodes.each do |hostname, node|
    hostsfile += node[:ip] + " " + hostname + "\r\n"  
  end

  nodes.each do |hostname, node|
    config.vm.box = cluster[:box]
    config.vm.box_check_update = true
  
    config.vm.define hostname do |cfg|
      cfg.vm.hostname = hostname
      cfg.vm.network "private_network", ip: node[:ip]
      if node[:shared_folders]
        node[:shared_folders].each do |shared_folder|
          cfg.vm.synced_folder shared_folder[:host_path], shared_folder[:vm_path]
        end
      end
      cfg.vm.provider "vmware_fusion" do |vb|
        vb.cpus = node[:cpus]
        vb.memory = node[:memory]
      end

      # Lay down the /etc/hosts file
      cfg.vm.provision "shell", env: { "hostsfile" => hostsfile }, inline: <<-SHELL  
        apt-get update -y
        echo "${hostsfile}" >> /etc/hosts
      SHELL
      
      # prepare system for k8s
      cfg.vm.provision "shell",
      env: {},
      path: SYSTEM_PREP_SH
      
      cfg.vm.provision "shell",
      env: {},
      path: node[:provision]
    end
  end
end
