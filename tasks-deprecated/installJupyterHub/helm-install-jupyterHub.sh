#!/bin/bash
set -e
#TODO param name
#TODO param namespace
NAME="jhub"
NAMESPACE=$NAME

helm repo add jupyterhub https://jupyterhub.github.io/helm-chart --force-update
helm repo update

# create secrets for Hub install
CONF="$(pwd)/config.yaml"

cat > $CONF <<EOF
hub:
  cookieSecret: $(openssl rand -hex 32) 
proxy:
  secretToken: $(openssl rand -hex 32) 
singleuser:
  image:
    name: jupyter/datascience-notebook
    tag: latest
  cmd: null  
EOF

#helm install my-hub jupyterhub/jupyterhub -f $CONF
helm install $NAME jupyterhub/jupyterhub \
  --namespace $NAMESPACE \
  --version=4.0.0 \
  --values config.yaml

# clean up config file
rm $CONF