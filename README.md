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

## Prerequisites

- Node.js
- Azure account with appropriate storage setup
- Azure Storage Account and Container
- Appropriate credentials Azure

## Getting Started

### Clone the Repository

```bash
git clone https://github.com/yourusername/filevault.git
cd filevault
```

## Project Structure

```
filevault/
├── src/
│   ├── aws-s3/
│   │   ├── public/
│   │   │   ├── app.js
│   │   │   ├── index.html
│   │   │   └── styles.css
│   │   ├── .env.example
│   │   ├── index.js
│   │   ├── package.json
│   │   └── package-lock.json
│   ├── azure-sa/
│   │   ├── public/
│   │   │   ├── app.js
│   │   │   ├── index.html
│   │   │   └── styles.css
│   │   ├── .env.example
│   │   ├── Dockerfile
│   │   ├── docker-compose.yml
│   │   ├── index.js
│   │   ├── package.json
│   │   └── package-lock.json
├── images/
│   ├── filevault.png
│   ├── upload-file-to-azure-storage-account.png
│   ├── file-appears-in-azure-sa.png
│   ├── delete-file.png
│   ├── file-removed-from-azure-sa.png
|   ├── toggle.png
├── .gitignore
├── main.tf
├── service.yaml
├── deployment.yaml
├── test-and-destroy.sh
└── README.md
```

## Setup on Azure Storage Accounts

### Configuration

Navigate to the `src/azure-sa` directory and create a `.env` file based on the `.env.example`:

```
AZURE_STORAGE_ACCOUNT_NAME=your-storage-account-name
AZURE_STORAGE_ACCOUNT_KEY=your-storage-account-key
AZURE_CONTAINER_NAME=your-container-name
PORT=3000
```

### Install Dependencies

```
cd src/azure-sa
npm install
```

## Running and Accessing the Application

```
node index.js
```

Open your browser and navigate to `http://localhost:3000`.

## Testing

The project uses `Mocha` as the test runner, `Supertest` for making HTTP requests to the Express application, and `Chai` for assertions.

To run the tests, navigate to the `src/azure-sa` directory and execute:

```bash
./node_modules/.bin/mocha
```

A basic test for the `/files` endpoint looks like this:

```javascript
const request = require('supertest');
const { expect } = require('chai');
const app = require('../index');

describe('GET /files', function() {
  it('should return a list of files', function(done) {
    request(app)
      .get('/files')
      .end((err, res) => {
        expect(res.statusCode).to.equal(200);
        expect(res.body).to.be.an('array');
        done();
      });
  });
});
```

## Docker

### Build the Docker Image

To build the Docker image for the application, run the following command from the `src/azure-sa` directory:

```bash
docker build -t filevault-azure .
```

### Run the Docker Container

To run the application as a Docker container, use the following command:

```bash
docker run -p 3000:3000 -d --env-file .env filevault-azure
```

## Terraform

### Provision the Infrastructure

The Terraform configuration in this project will provision the following Azure resources:

-   **Azure Kubernetes Service (AKS) Cluster:** A managed Kubernetes cluster to deploy the application.
-   **Azure Container Registry (ACR):** A private Docker registry to store the application's Docker image.

Before running the Terraform commands, make sure you have the Azure CLI installed and configured.

1.  **Initialize Terraform:**

    ```bash
    terraform init
    ```

2.  **Plan the deployment:**

    ```bash
    terraform plan
    ```

3.  **Apply the configuration:**

    ```bash
    terraform apply
    ```

## Kubernetes

### Deploy the Application

Once the infrastructure is provisioned with Terraform, you can deploy the application to the AKS cluster.

1.  **Connect to the AKS cluster:**

    Use the Azure CLI to get the credentials for your AKS cluster.

    ```bash
    az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
    ```

2.  **Deploy the application:**

    Apply the `deployment.yaml` and `service.yaml` files to deploy the application and expose it to the internet.

    ```bash
    kubectl apply -f deployment.yaml
    kubectl apply -f service.yaml
    ```

3.  **Access the application:**

    It may take a few minutes for the LoadBalancer to be provisioned. You can get the external IP address of the service by running:

    ```bash
    kubectl get service firevault-service
    ```

    Once the `EXTERNAL-IP` is available, you can access the application in your browser at `http://<external-ip>`.

## Setup on AWS S3

(Instructions for setting up and running the AWS S3 version of the application will be added here.)

## Technologies Used

- Node.js
- Azure Storage Accounts
- Docker
- Terraform
- Kubernetes
- HTML, CSS, JavaScript

## To-Do

- [ ] **Use a Database for Persistent Data**: Replace the `filesData.json` with a database (e.g., MongoDB, PostgreSQL) to store file metadata persistently.

- [ ] **User Authentication**: Implement user authentication to manage user-specific files securely.

- [ ] **File Search and Filtering**: Add functionality to search and filter files in the table.

- [ ] **Drag and Drop Upload**: Enhance the upload feature with drag and drop functionality.

