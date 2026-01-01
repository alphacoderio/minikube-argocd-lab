# GitOps-Driven Deployment on Minikube

## Overview
This project demonstrates a production-grade GitOps workflow using Minikube, ArgoCD, and a Python REST API with HTTPS ingress.

## Prerequisites
- macOS with Docker Desktop installed
- Minikube
- kubectl
- Helm (for ArgoCD installation)
- ArgoCD CLI
- Git

## Architecture
See `architecture-diagram.png` for system architecture visualization.

## Project Structure
```
.
├── app/
│   ├── main.py                # Python REST API
│   ├── Dockerfile             # Non-root container image
│   └── requirements.txt       # Python dependencies
├── k8s/
│   ├── namespace.yaml         # web-api namespace
│   ├── deployment.yaml        # Web API deployment
│   ├── service.yaml           # Service definition
│   ├── ingress.yaml           # HTTPS ingress with TLS
│   └── tls-secret.yaml        # TLS certificate secret
├── argocd/
│   └── application.yaml       # ArgoCD Application manifest
├── terraform/
│   ├── main.tf                # Terraform configuration
│   ├── variables.tf
│   └── outputs.tf
├── architecture-diagram.png
└── README.md
```

## Setup Instructions

### 1. Initialize Minikube Cluster
```bash
# Start Minikube with Docker driver
minikube start --driver=docker --cpus=4 --memory=8192

# Enable ingress addon
minikube addons enable ingress

# Verify cluster is running
kubectl cluster-info
```

### 2. Install ArgoCD
```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
kubectl wait --for=condition=ready pod -l app.kubernetes.in/name=argocd-server -n argocd --timeout=300s

# Get initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to access ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access ArgoCD at: https://localhost:8080
- Username: `admin`
- Password: (from command above)

### 3. Create TLS Certificate
```bash
# Generate certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=web.local/O=web-api"

# Encode to base64
cat tls.crt | base64 | tr -d '\n'
cat tls.key | base64 | tr -d '\n'
```

### 4. Apply Terraform Configuration
```bash
cd terraform

# Initialize Terraform
terraform init

# Review planned changes
terraform plan

# Apply configuration
terraform apply -auto-approve
```

### 5. Deploy Application via ArgoCD
```bash
# Apply ArgoCD Application
kubectl apply -f argocd/application.yaml

# Sync application (or wait for auto-sync)
argocd app sync web-api --port-forward --port-forward-namespace argocd
```

### 6. Configure Local DNS
Add to `/etc/hosts`:
```
127.0.0.1 web.local
```

### 7. Access the Application
```bash
# Start Minikube tunnel (in a separate terminal)
minikube tunnel

# Test HTTP redirect to HTTPS
curl -L http://web.local

# Test HTTPS endpoint (with self-signed cert)
curl -k https://web.local/
curl -k https://web.local/health
```

## Application Endpoints

- `GET /` - Welcome message
- `GET /health` - Health check endpoint

## Security Features

### Non-Root Container
The application runs as user `appuser` (UID 1000) with the following security context:
```yaml
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
```

### TLS/HTTPS
- All HTTP traffic (port 80) is redirected to HTTPS (port 443)
- TLS termination at ingress level
- Self-signed certificate stored as Kubernetes Secret

## GitOps Workflow

1. Developer pushes code changes to GitHub
2. ArgoCD detects changes in the repository (monitors `k8s/` folder)
3. ArgoCD automatically syncs and deploys to web-api namespace
4. Application is updated with zero-downtime rolling update

## Monitoring

### Check Application Status
```bash
# View pods
kubectl get pods -n web-api

# View application logs
kubectl logs -f deployment/web-api -n web-api

# Check ingress status
kubectl get ingress -n web-api
```

### ArgoCD Application Status
```bash
# Via CLI
argocd app get web-api --port-forward --port-forward-namespace argocd

# Via UI
# Navigate to https://localhost:8080
```

## Troubleshooting

### Pod not starting
```bash
kubectl describe pod <pod-name> -n web-api
kubectl logs <pod-name> -n web-api
```

### Ingress not working
```bash
kubectl describe ingress web-api -n web-api
minikube addons list | grep ingress

# Make sure minikube tunnel is running
minikube tunnel
```

### ArgoCD sync issues
```bash
argocd app get web-api --port-forward --port-forward-namespace argocd
argocd app sync web-api --force --port-forward --port-forward-namespace argocd
```

## Cleanup
```bash
# Delete ArgoCD application
kubectl delete -f argocd/application.yaml

# Delete Terraform resources
cd terraform && terraform destroy -auto-approve

# Delete ArgoCD
kubectl delete namespace argocd

# Stop Minikube
minikube stop

# Delete Minikube cluster (optional)
minikube delete
```

## Technologies Used
- **Minikube**: Local Kubernetes cluster
- **ArgoCD**: GitOps continuous delivery
- **Python 3.10**: REST API development
- **Docker**: Container runtime
- **Terraform**: Infrastructure as Code
- **Nginx Ingress**: Traffic management and TLS termination
