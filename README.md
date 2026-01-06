# FileVault

FileVault is a modern file uploading application with versions for both AWS S3 and Azure Blob Storage. It features a clean interface with light/dark mode toggle and file management capabilities.

## Application Screenshots

### FileVault Interface
![FileVault](images/filevault.png)

### Upload File to Azure Storage Account
![Upload File to Azure Storage Account](images/upload-file-to-azure-storage-account.png)
The upload screen allows you to select a file and enter a name for the file. Upon clicking the submit button, the file is uploaded to the Azure Blob Storage.

### File Appears in Azure Storage Account
![File Appears in Azure SA](images/file-appears-in-azure-sa.png)
This screen shows the file successfully uploaded to the Azure Blob Storage container. The table displays the file name and its corresponding key.

### Delete File
![Delete File](images/delete-file.png)
This screen demonstrates the delete functionality. Clicking the delete button removes the file from the cloud storage and updates the table accordingly.

### File Removed from Azure Storage Account
![File Removed from Azure SA](images/file-removed-from-azure-sa.png)
This screen shows that the file has been successfully deleted from the Azure Blob Storage container, and the table has been updated to reflect this.

### Toggle Light/Dark Mode
![Toggle Light/Dark Mode](images/toggle.png)
This screen shows the light mode when you slide the toggle switch.

## Features

- Upload files to cloud storage (AWS S3 or Azure Blob Storage).
- Save and retrieve file metadata.
- Delete files directly from the table.
- Light/Dark mode toggle.

## Project Structure
The project is organized into several directories:
- **.github/workflows**: Contains GitHub Actions workflows for CI/CD.
- **ansible-deployment**: Includes Ansible playbooks for application deployment.
- **images**: Stores application screenshots and diagrams.
- **infrastructure-aks**: Holds Terraform configurations for the Azure Kubernetes Service (AKS) infrastructure.
- **infrastructure-data**: Contains Terraform configurations for data-related resources like storage accounts.
- **src**: The source code for the Node.js application, with separate implementations for AWS S3 and Azure Storage Account.

## Prerequisites

- Node.js
- Docker
- Terraform
- Azure CLI
- Helm

## Getting Started

### Clone the Repository
```bash
git clone https://github.com/yourusername/filevault.git
cd filevault
```

## Infrastructure Setup with Terraform
The project uses Terraform to provision the necessary Azure infrastructure. The main Terraform files are:
- **main.tf**: Defines the core resources, including the AKS cluster, Container Registry, and Key Vault.
- **grafana-k8s-monitoring.tf**: Configures Grafana for Kubernetes monitoring.
- **secrets.tf**: Manages secrets using Azure Key Vault.
- **vars.tf**: Contains variable definitions for the Terraform configurations.

To provision the infrastructure, navigate to the `infrastructure-aks` directory and run the following commands:
```bash
terraform init
terraform plan
terraform apply
```

## Application Deployment with Helm
The application is deployed to the AKS cluster using a Helm chart. The chart is defined by the following files:
- **values.yaml**: Contains the default values for the Helm chart.
- **deployment.yaml**: Defines the Kubernetes deployment for the application.
- **service.yaml**: Defines the Kubernetes service to expose the application.
- **secretprovider.yaml**: Manages secrets for the application using the Azure Key Vault provider.

To deploy the application, use the following Helm command:
```bash
helm install filevault . -f values.yaml
```

## CI/CD Pipeline
The project includes a CI/CD pipeline using GitHub Actions. The workflows are defined in the `.github/workflows` directory:
- **terraform.yml**: Automates the provisioning of the Terraform infrastructure.
- **azure-kubernetes-service.yml**: Automates the deployment of the application to the AKS cluster.

## To-Do
- [ ] **Use a Database for Persistent Data**: Replace the `filesData.json` with a database (e.g., MongoDB, PostgreSQL) to store file metadata persistently.
- [ ] **User Authentication**: Implement user authentication to manage user-specific files securely.
- [ ] **File Search and Filtering**: Add functionality to search and filter files in the table.
- [ ] **Drag and Drop Upload**: Enhance the upload feature with drag and drop functionality.
- [ ] **Complete AWS S3 Implementation**: Finish the implementation of the AWS S3 version of the application.
- [ ] **Improve Test Coverage**: Increase the test coverage for both the application and the infrastructure.