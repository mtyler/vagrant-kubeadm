#!/bin/bash

sudo apt-get update && sudo apt-get install -y haproxy

cat <<EOF | sudo tee /etc/haproxy/haproxy.cfg
frontend proxynode
    bind *:80
    bind *:6443
    stats uri /proxystats
    default_backend k8sServers

backend k8sServers
    balance roundrobin
    server controlplane1  10.0.0.11:6443 check  

listen stats
    bind :9999
    mode http
    stats enable
    stats hide-version
    stats uri /stats
EOF

sudo systemctl restart haproxy.service
sudo systemctl status haproxy.service


