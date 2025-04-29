# Components overview
InferX platform includes InferX runtime and InferX platform service.

InferX runtime: It is released as a tgz package at the repo release https://github.com/inferx-net/inferx/releases/tag/0.1.0
InferX platform service: It will be installed with docker compose as https://github.com/inferx-net/inferx/blob/main/docker-compose.yml. There are following container images:
- inferx/inferx_dashboard:v0.1.0: The inferx webui dashboard.
- inferx/inferx_one:v0.1.0: The inferx platform services such as rest api gateway,scheduler, etc.
- inferx/spdk-container:v0.1.0: Optional. This is simple wrapper of https://spdk.io/. It is only needed when using InferX blob store.
- quay.io/keycloak/keycloak:latest: Keycloak image which used for Authentication.
- postgres:14.5: Standard postgres container. It stores inferx audit log, secret and keycloak configuration
- quay.io/coreos/etcd:v3.5.13: Inferx configurations such as tenant, namespace and model functions.
# Install Steps
1. Install Inferx runtime package
download inferx.tar.gz from https://github.com/inferx-net/inferx/releases/tag/0.1.0
unzip the package to /opt folder
cd /opt
sudo tar zxvf inferx.tar.gz
Create or update the docker configuration: /etc/docker/daemon.json as example. please add the section:

        "inferx": {
            "path": "/opt/inferx/bin/inferx"
        }
Restare docker

sudo systemctl restart docker

or

sudo systemctl restart docker.service
2. Running InferX service with docker composer
Clone this repo and Run the docker composer as makefile

git clone git@github.com:inferx-net/inferx.git
cd inferx
make run
3. Configure Keycloak: There are 2 options to configure the keycloak
Option#1: use keyclaok postgres data. Download keycloak database file from https://github.com/inferx-net/inferx/releases/download/0.1.0/postgres_keycloak.tar.gz and unzip that in /opt/inferx/data folder
Option#2: follow the steps at https://github.com/inferx-net/inferx/wiki/keycloak-configuration
4. Restart he inferx service
make stop
make run
now you can access inferx dashboard from http://localhost:81/

# Submit User model to InferX platform
please follow the steps at https://github.com/inferx-net/inferx/wiki/Submit-User-model-to-InferX-platform

InferX support high perform blob store. To configure that, please reference document https://github.com/inferx-net/inferx/wiki/InferX-Snapshot-and-restore-configuration.