#!/bin/bash

# filepath: /Users/mtyler/Workspace/vagrant-kubeadm/scripts/k8scp-proxy.sh

# Install HAProxy
sudo apt-get update
sudo apt-get install -y haproxy

# Configure HAProxy
cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
global
    log /dev/log    local0
    log /dev/log    local1 notice
    chroot /var/lib/haproxy
    stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
    stats timeout 30s
    user haproxy
    group haproxy
    daemon

defaults
    log     global
    mode    tcp
    option  tcplog
    option  dontlognull
    timeout connect 5000
    timeout client  50000
    timeout server  50000

frontend kubernetes-frontend
    bind *:6443
    default_backend kubernetes-backend

backend kubernetes-backend
    balance roundrobin
    server cp1 10.0.0.11:6443 check
    server cp2 10.0.0.12:6443 check
    server cp3 10.0.0.13:6443 check

frontend minio-frontend
    bind *:9000
    default_backend minio-backend

backend minio-backend
    balance roundrobin
    server cp1 10.0.0.11:9000 check 
    server cp2 10.0.0.12:9000 check
    server cp3 10.0.0.13:9000 check


frontend web-frontend
    bind *:80
    default_backend web-backend

backend web-backend
    server cp1 10.0.0.11:30080 check
    server cp2 10.0.0.12:30080 check
    server cp3 10.0.0.13:30080 check
    server n1  10.0.0.21:30080 check
    server n2  10.0.0.22:30080 check
    server n3  10.0.0.23:30080 check
    

listen stats
    mode http
    bind *:9999
    stats enable
    stats uri /stats
    stats refresh 10s
#    stats auth admin:admin
    stats admin if TRUE
EOF

# Restart HAProxy to apply the configuration
sudo systemctl restart haproxy

# Enable HAProxy to start on boot
sudo systemctl enable haproxy

echo "HAProxy installed and configured successfully."