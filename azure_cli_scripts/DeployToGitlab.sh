#!/bin/bash
# this scripts deploys an app service applicaton to a git repo
#variable
let "randomIdentifier=$RANDOM*$RANDOM"
location="europe-east"
resourceGroup="my-app-service-rg-$randomIdentifier"
tag="deploy-github.sh"
gitrepo= #https://gitlab.com/Azure-Samples/nodejs-docs-hello-world # Replace the following URL with your own public Gitlab repo URL if you have one
appServicePlan="my-app-service-plan-$randomIdentifier"
webapp="my-web-app-$randomIdentifier"

# Create a resource group.
echo "Creating $resourceGroup in "$location"..."
az group create --name $resourceGroup --location "$location" --tag $tag

# Create an App Service plan in `FREE` tier.
echo "Creating $appServicePlan"
az appservice plan create --name $appServicePlan --resource-group $resourceGroup --sku FREE

# Create a web app.
echo "Creating $webapp"
az webapp create --name $webapp --resource-group $resourceGroup --plan $appServicePlan

# Deploy code from a public GitLab repository. 
az webapp deployment source config --name $webapp --resource-group $resourceGroup \
--repo-url $gitrepo --branch master --manual-integration

# Use curl to see the web app.
site="http://$webapp.azurewebsites.net"
echo $site
curl "$site" # Optionally, copy and paste the output of the previous command into a browser to see the web app
