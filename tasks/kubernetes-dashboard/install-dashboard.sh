#!/bin/bash

helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard

# create service account, secret, rolebinding 
kubectl apply -f serviceAccount.yaml

echo -e "use command in ./get-token.sh to obtain login token for dashboard.\r\n"

kubectl -n kubernetes-dashboard port-forward svc/kubernetes-dashboard-kong-proxy 8443:443



