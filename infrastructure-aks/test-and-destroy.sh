#!/bin/bash

set -uo pipefail

# --- CONFIGURATION ---
RG_NAME="aks-resource-group"
CLUSTER_NAME="firevault-cluster"
NAMESPACE="default"

# Function to handle errors
error_handler() {
  echo "--------------------------------------------------"
  echo "❌ ERROR: Command failed on line $1"
  echo "⚠️  Deployment failed. Cleaning up app resources, but keeping infrastructure for debugging."
  
  # Optional: Cleanup K8s resources if they failed, but keep Terraform state
  kubectl delete -f service.yaml --ignore-not-found
  kubectl delete -f deployment.yaml --ignore-not-found
  
  exit 1
}

trap 'error_handler $LINENO' ERR

echo "--- 1. Deploying Infrastructure ---"
terraform init
terraform plan -out=tfplan
terraform apply "tfplan"

echo "--- 2. Configuring Connectivity ---"
az aks get-credentials --resource-group "$RG_NAME" --name "$CLUSTER_NAME" --overwrite-existing

echo "--- 3. Deploying Application ---"
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo "--- 4. Health Checks ---"
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=Ready pod -l app=firevault-app --timeout=120s

echo "Waiting for LoadBalancer IP..."
until kubectl get svc firevault-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}' > /dev/null 2>&1; do
  echo -n "."
  sleep 5
done
PUBLIC_IP=$(kubectl get svc firevault-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo -e "\n✅ App is live at: http://$PUBLIC_IP"
echo "--- Workflow Completed Successfully. Infrastructure remains running. ---"