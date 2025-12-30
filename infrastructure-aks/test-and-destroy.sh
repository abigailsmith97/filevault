#!/bin/bash

echo "--- 1. Deploying Infrastructure ---"
echo "...checking terraform plan"
terraform plan -out=tfplan
echo "...deployement started"
terraform apply "tfplan"

echo "--- 2. Infrastructure is Live ---"
kubectl get nodes

echo "--- 3. Sleeping for 60 seconds ---"
sleep 60

echo "--- 4. Tearing Down ---"
terraform destroy -auto-approve