# InferX Kubernetes Deployment Guide

This directory contains the Kubernetes manifests required to deploy the InferX platform on a Kubernetes cluster.

## Components Overview

The InferX platform consists of the following components:

1. **InferX One**: Main InferX service for REST API, scheduler, etc.
2. **InferX Dashboard**: Web UI dashboard for InferX platform
3. **Keycloak**: Authentication service
4. **Databases**:
   - Secret DB (PostgreSQL)
   - Audit DB (PostgreSQL)
   - Keycloak DB (PostgreSQL)
5. **etcd**: Stores InferX configurations such as tenant, namespace, and model functions

## Prerequisites

Before deploying InferX on Kubernetes, ensure you have the following:

- A Kubernetes cluster (v1.20+)
- kubectl command line tool installed
- NVIDIA GPU operators installed (for GPU support)
- A storage class that supports ReadWriteOnce access mode
- Ingress controller installed (like NGINX Ingress Controller)

## Preparation

1. Clone the InferX repository:

```bash
git clone https://github.com/inferx-net/inferx.git
cd inferx/k8s_manifests
```

2. Download the InferX runtime package and extract it to a location that will be mounted to your pods:

```bash
# Create a directory for InferX binaries and data
mkdir -p /path/to/inferx/bin /path/to/inferx/data /path/to/inferx/config

# Download InferX runtime package
wget https://github.com/inferx-net/inferx/releases/download/0.1.0/inferx.tar.gz

# Extract to the bin directory
tar -xzf inferx.tar.gz -C /path/to/inferx/bin
```

3. Create or obtain the necessary configuration files:
   - Copy the node1.json configuration file to `/path/to/inferx/config/`
   - Copy SQL initialization scripts to `/path/to/inferx/config/`

## Deployment Steps

Follow these steps to deploy InferX on Kubernetes:

### 1. Create Namespace

```bash
kubectl apply -f 00-namespace.yaml
```

### 2. Deploy Secrets

Update the secret values in `10-secrets.yaml` before applying:

```bash
# Edit the secrets file with your own secure passwords
vi 10-secrets.yaml

# Apply secrets
kubectl apply -f 10-secrets.yaml
```

### 3. Create Database Configuration

Apply the ConfigMaps for database initialization:

```bash
kubectl apply -f 01-secret-db-config.yaml
kubectl apply -f 02-audit-db-config.yaml
```

### 4. Deploy Databases

```bash
kubectl apply -f 03-secret-db.yaml
kubectl apply -f 04-audit-db.yaml
kubectl apply -f 06-keycloak-db.yaml
```

### 5. Deploy etcd

```bash
kubectl apply -f 05-etcd.yaml
```

### 6. Deploy Keycloak

```bash
kubectl apply -f 07-keycloak.yaml
```

### 7. Configure InferX One

Update the ConfigMap in `09-inferx-one.yaml` with your node configuration:

```bash
# Edit the ConfigMap
vi 09-inferx-one.yaml
```

The node1.json configuration should be properly formatted with your specific configuration.

### 8. Deploy InferX One

```bash
kubectl apply -f 09-inferx-one.yaml
```

### 9. Deploy InferX Dashboard

```bash
kubectl apply -f 08-inferx-dashboard.yaml
```

### 10. Configure Ingress

Edit the Ingress manifest if needed to match your domain and configuration:

```bash
# Edit the Ingress configuration if needed
vi 11-ingress.yaml

# Apply Ingress
kubectl apply -f 11-ingress.yaml
```

## Persistent Volumes

The deployment uses PersistentVolumeClaims for:

- Secret DB data
- Audit DB data
- Keycloak DB data
- etcd data
- InferX data
- InferX binaries

Ensure your Kubernetes cluster has a storage class that can provision these volumes.

## Keycloak Configuration

After deployment, you'll need to configure Keycloak. There are two options:

### Option 1: Use Keycloak Postgres Data

1. Download the pre-configured Keycloak database:

```bash
wget https://github.com/inferx-net/inferx/releases/download/0.1.0/postgres_keycloak.tar.gz
tar -xzf postgres_keycloak.tar.gz -C /path/to/inferx/data/postgres_keycloak
```

2. Restart the Keycloak pod:

```bash
kubectl rollout restart deployment keycloak -n inferx
```

### Option 2: Manual Configuration

Follow the steps at https://github.com/inferx-net/inferx/wiki/keycloak-configuration to configure Keycloak manually.

## Accessing InferX Dashboard

Once all components are deployed and running, access the InferX dashboard through the Ingress URL. By default, it will be available at:

```
http://<your-ingress-ip-or-hostname>/
```

## GPUs in Kubernetes

To use GPUs in your InferX deployment, ensure:

1. NVIDIA GPU operators are installed in your cluster
2. The node where InferX pods run has GPUs available
3. The InferX One pod has the required GPU resources requested

## Submitting User Models

To submit user models to the InferX platform, please follow the guide at:
https://github.com/inferx-net/inferx/wiki/Submit-User-model-to-InferX-platform

## Troubleshooting

If you encounter issues with the deployment, check the following:

1. Pod status:

```bash
kubectl get pods -n inferx
```

2. Pod logs:

```bash
kubectl logs -n inferx <pod-name>
```

3. Persistent volume claims:

```bash
kubectl get pvc -n inferx
```

4. Ensure all services are running:

```bash
kubectl get services -n inferx
```

5. Check Ingress configuration:

```bash
kubectl get ingress -n inferx
kubectl describe ingress inferx-ingress -n inferx
```