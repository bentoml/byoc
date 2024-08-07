#!/bin/env bash

set -eo pipefail

# Variables
subscriptionId=$(az account show | jq -r .id)

if [ -z "$1" ]; then
	echo -n "Enter the region you would like to install BentoCloud (e.g. eastus): "
	read -r resourceGroupLocation
	while [ -z "$resourceGroupLocation" ]; do
		echo -n "Please enter a location: "
		read -r resourceGroupLocation
	done
else
	resourceGroupLocation="$1"
fi

resourceGroupName="bentocloud-$resourceGroupLocation"
roleDefinitionName="bcBootstrap"
servicePrincipalName="bcAdmin"

echo "Creating BentoCloud resource group..."
az group create --name "$resourceGroupName" --location "$resourceGroupLocation" &> /dev/null

roleDefinition=$(cat <<EOF
{
	"Name": "$roleDefinitionName",
	"Description": "BentoCloud bootstrap role",
	"Actions": [
		"Microsoft.Authorization/roleAssignments/*",
		"Microsoft.Cache/redis/*",
		"Microsoft.Compute/virtualMachines/*",
		"Microsoft.Compute/availabilitySets/*",
		"Microsoft.Compute/disks/*",
		"Microsoft.ContainerRegistry/registries/*",
		"Microsoft.ContainerService/managedClusters/*",
		"Microsoft.Network/virtualNetworks/*",
		"Microsoft.Network/networkInterfaces/*",
		"Microsoft.Network/publicIPAddresses/*",
		"Microsoft.Network/networkSecurityGroups/*",
		"Microsoft.Network/loadBalancers/*",
		"Microsoft.Network/routeTables/*",
		"Microsoft.Storage/storageAccounts/*",
		"Microsoft.Storage/storageAccounts/listKeys/action",
		"Microsoft.ManagedIdentity/userAssignedIdentities/*",
		"Microsoft.OperationsManagement/solutions/*",
		"Microsoft.OperationalInsights/workspaces/*",
		"Microsoft.Resources/subscriptions/resourceGroups/*",
		"Microsoft.Resources/deployments/*",
		"Microsoft.Resources/subscriptions/resourceGroups/read",
	],
	"NotActions": [],
	"AssignableScopes": [
		"/subscriptions/$subscriptionId"
	]
}
EOF
								 )

existingRole=$(az role definition list --name "$roleDefinitionName" --query "[].name" -o tsv)

if [ -z "$existingRole" ]; then

	echo "Creating BentoCloud Bootstrap role..."
	az role definition create --role-definition "$roleDefinition" &> /dev/null

else

	echo "Updating BentoCloud Bootstrap role..."
	az role definition update --role-definition "$roleDefinition" &> /dev/null

fi

existingSP=$(az ad sp list --display-name "$servicePrincipalName" --query "[].appId" -o tsv)

if [ -z "$existingSP" ]; then

	echo "Creating service principal and assigning custom role..."
	spOutput=$(az ad sp create-for-rbac --name "$servicePrincipalName" --role "$roleDefinitionName" --scopes "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName" 2>/dev/null)

	echo "$spOutput" | jq '. += { subscriptionId: "'"$subscriptionId"'" }' >> bcAdminSP.json

else

	echo "Adding role assignment to existing service principal..."
	az role assignment create --assignee "$existingSP" --role "$roleDefinitionName" --scope "/subscriptions/$subscriptionId/resourceGroups/$resourceGroupName" &> /dev/null

fi

echo "Role assignment completed."

echo "Bootstrap successful. Please send the created ./bcAdminSP.json to the BentoCloud team!"
