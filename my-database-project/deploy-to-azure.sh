#!/bin/bash

# Скрипт для розгортання на Azure Container Registry та AKS
# Використання: ./deploy-to-azure.sh [resource-group] [aks-cluster-name]

set -e

RESOURCE_GROUP=${1:-"myResourceGroup"}
AKS_CLUSTER=${2:-"myAKSCluster"}
ACR_NAME=${3:-"myacr$(date +%s)"}
LOCATION=${4:-"eastus"}

echo "🚀 Deploying to Azure"
echo "Resource Group: $RESOURCE_GROUP"
echo "AKS Cluster: $AKS_CLUSTER"
echo "ACR Name: $ACR_NAME"
echo "Location: $LOCATION"
echo ""

# Створюємо resource group якщо не існує
echo "📦 Creating resource group..."
az group create --name $RESOURCE_GROUP --location $LOCATION

# Створюємо Azure Container Registry
echo "🐳 Creating Azure Container Registry..."
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --admin-enabled true

# Отримуємо ACR login server
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query loginServer --output tsv)
echo "ACR Login Server: $ACR_LOGIN_SERVER"

# Логінимося в ACR
echo "🔐 Logging into ACR..."
az acr login --name $ACR_NAME

# Збираємо Docker образ
echo "🔨 Building Docker image..."
docker build -t $ACR_LOGIN_SERVER/database-app:latest .

# Пушимо образ в ACR
echo "📤 Pushing image to ACR..."
docker push $ACR_LOGIN_SERVER/database-app:latest

# Створюємо AKS кластер якщо не існує
echo "☸️ Creating AKS cluster..."
az aks create \
    --resource-group $RESOURCE_GROUP \
    --name $AKS_CLUSTER \
    --node-count 2 \
    --enable-addons monitoring \
    --generate-ssh-keys \
    --attach-acr $ACR_NAME

# Отримуємо credentials для AKS
echo "🔑 Getting AKS credentials..."
az aks get-credentials --resource-group $RESOURCE_GROUP --name $AKS_CLUSTER

# Оновлюємо образ в k8s deployment
echo "📝 Updating deployment with ACR image..."
sed -i.bak "s|your-registry.azurecr.io/database-app:latest|$ACR_LOGIN_SERVER/database-app:latest|g" k8s-deployment.yml

# Застосовуємо Kubernetes deployment
echo "🚀 Deploying to Kubernetes..."
kubectl apply -f k8s-deployment.yml

# Чекаємо готовності deployment
echo "⏳ Waiting for deployment to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/database-app

# Отримуємо external IP
echo "🌐 Getting external IP..."
kubectl get services database-app-service

echo "✅ Deployment completed!"
echo "You can access your application at the external IP shown above"
echo "To check HPA status: kubectl get hpa"
echo "To check pods: kubectl get pods"
echo "To check logs: kubectl logs -l app=database-app"
