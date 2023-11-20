#!/bin/bash
# This script creates an Azure resource group, an App Service plan, and a web app.
# It then deploys a Node.js application using a Docker Container.

# Exit the script when any command fails
set -e

# Generate a random identifier for uniqueness
let "randomIdentifier=$RANDOM*$RANDOM"

# Set variables
location="East US"
resourceGroup="my-app-service-rg-$randomIdentifier"
tag="deploy-nodejs-docker-app.sh"
appServicePlan="my-app-service-plan-$randomIdentifier"
webapp="my-web-app-$randomIdentifier"

# Create a resource group in the specified location
echo "Creating resource group: $resourceGroup in $location..."
az group create --name $resourceGroup --location "$location" --tag $tag

# Create an App Service plan in S1 tier (Standard tier)
echo "Creating App Service plan: $appServicePlan"
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku S1 --is-linux

# Create a web app with a specific Docker image
echo "Creating web app: $webapp with Node.js Docker image"
az webapp create --name $webapp --resource-group $resourceGroup --plan $appServicePlan --deployment-container-image-name node:14

# Configure web app with a Docker image from Docker Hub
echo "Configuring $webapp to run Docker image"
az webapp config container set --name $webapp --resource-group $resourceGroup \
    --docker-custom-image-name node:14 --docker-registry-server-url # https://index.docker.io #docker registry

# Output the URL of the created web app and make a curl request to it
site="http://$webapp.azurewebsites.net"
echo "Web app URL: $site"
curl "$site"

# Uncomment the following line to delete all resources
# echo "Deleting all resources"
# az group delete --name $resourceGroup -y
