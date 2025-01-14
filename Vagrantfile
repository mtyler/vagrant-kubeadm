
require "yaml"
vagrant_root = File.dirname(File.expand_path(__FILE__))
settings = YAML.load_file "#{vagrant_root}/settings.yaml"

DOMAIN = settings["network"]["domain"]
# Split the control IP into 2 parts: the first 3 octets and the last octet
IP_SECTIONS = settings["network"]["control_ip"].match(/^([0-9.]+\.)([^.]+)$/)
# First 3 octets including the trailing dot:
IP_NW = IP_SECTIONS.captures[0]
# Last octet excluding all dots:
IP_START = Integer(IP_SECTIONS.captures[1])
NUM_CONTROL_NODES = settings["nodes"]["control"]["count"]
NUM_WORKER_NODES = settings["nodes"]["workers"]["count"]
SYSTEM_PREP_SH = "scripts/system-prep.sh"

Vagrant.configure("2") do |config|
  config.vm.provision "shell", env: { "IP_NW" => IP_NW, "IP_START" => IP_START, \
    "NUM_CONTROL_NODES" => NUM_CONTROL_NODES, "NUM_WORKER_NODES" => NUM_WORKER_NODES, \
    "DOMAIN" => DOMAIN}, inline: <<-SHELL  
      apt-get update -y
      # Lay down the /etc/hosts file
      # pin domain to first control plane node
      echo "$IP_NW$((IP_START+1)) ${DOMAIN}" >> /etc/hosts
      for i in `seq 1 ${NUM_CONTROL_NODES}`; do
        echo "$IP_NW$((IP_START+i)) cp${i}" >> /etc/hosts
      done
      for i in `seq 1 ${NUM_WORKER_NODES}`; do
        echo "$IP_NW$((IP_START+NUM_CONTROL_NODES+i)) n${i}" >> /etc/hosts
      done
  SHELL

  config.vm.box = settings["software"]["box"]

  config.vm.box_check_update = true
  
  # Control Plane Nodes
  (1..NUM_CONTROL_NODES).each do |i|
    config.vm.define "cp#{i}" do |cp|
      cp.vm.hostname = "cp#{i}"
      cp.vm.network "private_network", ip: IP_NW + "#{IP_START + i}"
      if settings["shared_folders"]
        settings["shared_folders"].each do |shared_folder|
          cp.vm.synced_folder shared_folder["host_path"], shared_folder["vm_path"]
        end
      end
      cp.vm.provider "vmware_fusion" do |vb|
          vb.cpus = settings["nodes"]["control"]["cpu"]
          vb.memory = settings["nodes"]["control"]["memory"]
      end
      cp.vm.provision "shell",
      env: {},
      path: SYSTEM_PREP_SH

    end
  end  

  # Worker Nodes
  (1..NUM_WORKER_NODES).each do |i|
    config.vm.define "n#{i}" do |node|
      node.vm.hostname = "n#{i}"
      node.vm.network "private_network", ip: IP_NW + "#{IP_START + NUM_CONTROL_NODES + i}"
      if settings["shared_folders"]
        settings["shared_folders"].each do |shared_folder|
          node.vm.synced_folder shared_folder["host_path"], shared_folder["vm_path"]
        end
      end
      node.vm.provider "vmware_fusion" do |vb|
          vb.cpus = settings["nodes"]["workers"]["cpu"]
          vb.memory = settings["nodes"]["workers"]["memory"]
      end
      node.vm.provision "shell",
      env: {},
      path: SYSTEM_PREP_SH  
    end

  end
end 
