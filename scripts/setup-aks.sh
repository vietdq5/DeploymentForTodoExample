#!/bin/bash

# Variables
RESOURCE_GROUP="rg-todo-app-aks"
LOCATION="southeastasia"
AKS_NAME="aks-todo-app"
ACR_NAME="acrtodoapp$RANDOM"
KEY_VAULT_NAME="kv-todo-app-$RANDOM"
IDENTITY_NAME="id-aks-todo-app"

# Create Resource Group
echo "Creating Resource Group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create Azure Container Registry
echo "Creating Azure Container Registry..."
az acr create \
  --resource-group $RESOURCE_GROUP \
  --name $ACR_NAME \
  --sku Basic

# Create User Assigned Managed Identity
echo "Creating Managed Identity..."
az identity create \
  --resource-group $RESOURCE_GROUP \
  --name $IDENTITY_NAME

IDENTITY_CLIENT_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY_NAME --query clientId -o tsv)
IDENTITY_RESOURCE_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $IDENTITY_NAME --query id -o tsv)

# Create AKS Cluster with Managed Identity
echo "Creating AKS Cluster..."
az aks create \
  --resource-group $RESOURCE_GROUP \
  --name $AKS_NAME \
  --node-count 3 \
  --node-vm-size Standard_B2ms \
  --network-plugin azure \
  --enable-managed-identity \
  --enable-workload-identity \
  --enable-oidc-issuer \
  --assign-identity $IDENTITY_RESOURCE_ID \
  --attach-acr $ACR_NAME \
  --generate-ssh-keys

# Get AKS Credentials
echo "Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_NAME

# Install CSI Driver
echo "Installing Secrets Store CSI Driver..."
az aks enable-addons \
  --addons azure-keyvault-secrets-provider \
  --name $AKS_NAME \
  --resource-group $RESOURCE_GROUP

# Create Azure Key Vault
echo "Creating Azure Key Vault..."
az keyvault create \
  --name $KEY_VAULT_NAME \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --enable-rbac-authorization false

# Set Key Vault Policy for Managed Identity
echo "Setting Key Vault access policy..."
az keyvault set-policy \
  --name $KEY_VAULT_NAME \
  --object-id $IDENTITY_CLIENT_ID \
  --secret-permissions get list

# Add secrets to Key Vault
echo "Adding secrets to Key Vault..."
az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "postgres-username" \
  --value "dbadmin"

az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "postgres-password" \
  --value "$(openssl rand -base64 32)"

az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "postgres-connection-string-prod" \
  --value "Host=your-postgres.postgres.database.azure.com;Port=5432;Database=tododb;Username=dbadmin;Password=<password>;SSL Mode=Require;"

az keyvault secret set \
  --vault-name $KEY_VAULT_NAME \
  --name "gateway-api-key" \
  --value "$(openssl rand -base64 32)"

# Output important values
echo "======================================"
echo "Deployment completed successfully!"
echo "======================================"
echo "Resource Group: $RESOURCE_GROUP"
echo "AKS Cluster: $AKS_NAME"
echo "ACR Name: $ACR_NAME"
echo "Key Vault: $KEY_VAULT_NAME"
echo "Managed Identity Client ID: $IDENTITY_CLIENT_ID"
echo ""
echo "Update your values.yaml files with:"
echo "  ACR: $ACR_NAME.azurecr.io"
echo "  Key Vault: $KEY_VAULT_NAME"
echo "  Identity Client ID: $IDENTITY_CLIENT_ID"