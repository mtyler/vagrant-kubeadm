## JupyterHub Installation 

JupyterHub is a "team" centric version of JupyterNotes | JupyterLab. 

### Steps

This will creates a number of objects in the cluster and it's probably wise to use a dedicated namespace

[Installation Overview](https://z2jh.jupyter.org/en/stable/)

1. get a working k8s cluster
2. create storage via kubectl
3. run bash script to execute helm

### singleuser server

- KubeSpawner creates the user pod 'singleuser' for each user upon login  
- KubeSpawner configuration can be viewed in the configMap under jupyterhub_config.py

[Customize Deployment](https://z2jh.jupyter.org/en/stable/jupyterhub/customization.html)

[KubeSpawner API](https://jupyterhub-kubespawner.readthedocs.io/en/latest/spawner.html#kubespawner.KubeSpawner)
