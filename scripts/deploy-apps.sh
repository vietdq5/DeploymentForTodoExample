#!/bin/bash

# Build and push Docker images
echo "Building and pushing Docker images..."

# Login to ACR
az acr login --name $ACR_NAME

# Build and push Gateway Service
docker build -t $ACR_NAME.azurecr.io/gateway-service:v1.3 ./gateway-service
docker push $ACR_NAME.azurecr.io/gateway-service:v1.3

# Build and push Todo Service
docker build -t $ACR_NAME.azurecr.io/todo-service:v1.2 ./todo-service
docker push $ACR_NAME.azurecr.io/todo-service:v1.2

# Create namespace
kubectl create namespace todo-app

# Deploy services using Helm
echo "Deploying services..."

# Deploy Todo Service
helm upgrade --install todo-service ./helm-charts/todo-service \
  --namespace todo-app \
  --values ./helm-charts/todo-service/values.yaml \
  --set image.repository=$ACR_NAME.azurecr.io/todo-service \
  --set azureKeyVault.keyvaultName=$KEY_VAULT_NAME \
  --set azureKeyVault.userAssignedIdentityID=$IDENTITY_CLIENT_ID

# Deploy Gateway Service
helm upgrade --install gateway-service ./helm-charts/gateway-service \
  --namespace todo-app \
  --values ./helm-charts/gateway-service/values.yaml \
  --set image.repository=$ACR_NAME.azurecr.io/gateway-service \
  --set azureKeyVault.keyvaultName=$KEY_VAULT_NAME \
  --set azureKeyVault.userAssignedIdentityID=$IDENTITY_CLIENT_ID

# Check deployment status
kubectl get pods -n todo-app
kubectl get svc -n todo-app