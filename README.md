# Posit Team inside a Kubernetes cluster <!-- omit in toc -->

- [Overview](#overview)
- [References](#references)
- [DevContainer](#devcontainer)
- [Deploy infrastructure](#deploy-infrastructure)
  - [Terraform State](#terraform-state)
  - [Deployment](#deployment)
- [Helm](#helm)
  - [Create custom Helm chart](#create-custom-helm-chart)
  - [Helm chart for Posit Team](#helm-chart-for-posit-team)
  - [Debug K8S Pod](#debug-k8s-pod)

## Overview

In this configuration, each product is installed within the kubernetes cluster and requires:

- User’s home directories to be stored on an external shared file server (Workbench)
- Application data to be stored on an external shared file server (Connect and Package Manager)
- Application metadata to be stored on an external PostgreSQL database server (All)

## References

- [Posit Team Architectures](https://solutions.posit.co/architecting/architectures/posit-team/)
- [GitHub - rstudio/helm](https://github.com/rstudio/helm)

## DevContainer

Create a `.devcontainer` folder in the root of the repository with the following files `Dockerfile` and `devcontainer.json`.
Then on VSCode F1 > Dev Containers: Rebuild and Reopen in Container.

```bash
az login --use-device-code
```

## Deploy infrastructure

### Terraform State

```bash
ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"

RESOURCE_GROUP_NAME="rg-posi"
LOCATION="uksouth"

RANDOM_SUFFIX=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 10 | head -n 1)
STORAGE_ACCOUNT_NAME="tfstate$RANDOM_SUFFIX"
CONTAINER_NAME="tfstate"

# Create a resource group
az group create \
  --name $RESOURCE_GROUP_NAME \
  --location $LOCATION \
  --tags CreatedBy=Dumitru Workload=Posit

# Create a storage account
az storage account create \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --location uksouth \
  --sku Standard_LRS \
  --encryption-services blob \
  --tags CreatedBy=Dumitru Workload=Posit

# Retrieve public IP address using curl
MY_IP=$(curl -s https://api.ipify.org)

# Configure the storage account firewall to allow access only from your IP address
az storage account network-rule add \
  --account-name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --ip-address $MY_IP \
  --action Allow

# Enabled from selected virtual networks and IP addresses
az storage account update \
  --name $STORAGE_ACCOUNT_NAME \
  --resource-group $RESOURCE_GROUP_NAME \
  --bypass AzureServices \
  --default-action Deny \
  --https-only true \
  --allow-blob-public-access false

# Assign the "Storage Blob Data Contributor" role to the service principal
az role assignment create \
  --role "Storage Blob Data Contributor" \
  --assignee $ARM_CLIENT_ID \
  --scope "/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME/providers/Microsoft.Storage/storageAccounts/$STORAGE_ACCOUNT_NAME"

# Create a storage container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT_NAME
```

### Deployment

Environment variables in `.env`:

```ini
ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
TF_STATE_RESOURCE_GROUP_NAME="rg-posit"
TF_STATE_STORAGE_ACCOUNT_NAME="sttfstate"
TF_STATE_CONTAINER_NAME="tfstate"
TF_STATE_KEY="positteam-k8s"
```

```bash
source .env

cd terraform
terraform fmt -recursive

export TF_CLI_ARGS_init="-backend-config='resource_group_name=${TF_STATE_RESOURCE_GROUP_NAME}' 
-backend-config='storage_account_name=${TF_STATE_STORAGE_ACCOUNT_NAME}' 
-backend-config='container_name=${TF_STATE_CONTAINER_NAME}' 
-backend-config='key=${TF_STATE_KEY}.tfstate'"

terraform init

terraform apply -var-file=".config/dev.tfvars" -auto-approve
terraform destroy -var-file=".config/dev.tfvars" -auto-approve
```

## Helm

[Helm - Quickstart Guide](https://helm.sh/docs/intro/quickstart/)

Connect to your AKS cluster:

```bash
az aks install-cli
az login --use-device-code
az account set --subscription 00000000-0000-0000-0000-000000000000
az aks get-credentials --resource-group rg-posit --name aks-posit --overwrite-existing

kubelogin convert-kubeconfig -l azurecli
kubectl get deployments --all-namespaces=true
```

### Create custom Helm chart

[Develop on AKS with Helm](https://learn.microsoft.com/en-us/azure/aks/quickstart-helm?tabs=azure-cli)
[GitHub - AzureSamples/azure-voting-app-redis](https://github.com/Azure-Samples/azure-voting-app-redis)

```bash
mkdir helm-charts
cd helm-charts

git clone https://github.com/Azure-Samples/azure-voting-app-redis.git

cd azure-voting-app-redis/azure-vote/

az acr build --image azure-vote-front:v1 --registry crpositukstest --file Dockerfile .

helm create azure-vote-front

code azure-vote-front/Chart.yaml

helm dependency update azure-vote-front

code azure-vote-front/values.yaml
code azure-vote-front/templates/deployment.yaml

helm install azure-vote-front azure-vote-front/
kubectl get service azure-vote-front --watch

helm list
kubectl get deployments --all-namespaces=true
kubectl get pods --all-namespaces=true

helm uninstall azure-vote-front
```

### Helm chart for Posit Team

[Posit Helm Charts](https://docs.posit.co/helm/)
[Helm ArtifactHUB - RStudio](https://artifacthub.io/packages/search?org=rstudio&sort=relevance&page=1)

```bash
helm repo add rstudio https://helm.rstudio.com
helm search repo rstudio
helm search repo rstudio/rstudio-pm -l
```

Package Manager:

```bash
helm upgrade --install package-manager rstudio/rstudio-pm \
  --version=0.5.29 \
  --set service.type=LoadBalancer \
  --set license.key=0000-0000-0000-0000-0000-0000-0000

kubectl get service package-manager-rstudio-pm --watch

helm uninstall package-manager
```

Connect:

```bash
helm upgrade --install connect rstudio/rstudio-connect \
  --version=0.7.3 \
  --set service.type=LoadBalancer \
  --set config.Quarto.Enabled=false \
  --set license.key=0000-0000-0000-0000-0000-0000-0000

kubectl get service connect-rstudio-connect --watch

helm uninstall connect
```

Workbench:

```bash
helm upgrade --install workbench rstudio/rstudio-workbench \
  --version=0.7.6 \
  --set service.type=LoadBalancer \
  --set userCreate=true \
  --set license.key=0000-0000-0000-0000-0000-0000-0000

kubectl get service workbench-rstudio-workbench --watch

helm uninstall workbench
```

Posit Team:

```bash
cd helm-charts
helm create posit-team

helm install my-posit-team posit-team/ --values=values-dev.yaml

helm upgrade
helm rollback
```

### Debug K8S Pod

```bash
kubectl get pods
kubectl get pods --all-namespaces=true

#Show details of specific pod
kubectl  describe pod connect-rstudio-connect-6b69bc8b79-sl5fm

# View logs for specific pod
kubectl logs connect-rstudio-connect-6b69bc8b79-sl5fm
```
