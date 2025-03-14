#!/bin/bash

# User-provided variables
# Define tags (you can add as many as needed)
TAGS="tier=network tier_type=privatelink"
SUBSCRIPTION_NETWORK_ID="055299c1-9e0a-4d2d-afe7-2b1c6af40aac"
PVT_DNS_RESOURCE_GROUP="network_vvonline"
PVT_DNS_NAME="privatelink.blob.core.windows.net"
PVT_DNS_CONFIGURATION_NAME="privatelink_blob_core_windows_net"
PVT_DNS_ZONE_GROUP_NAME="default"
STA_GROUP_ID="blob"

# Prompt user for input
read -p "Enter Subscription ID: " SUBSCRIPTION_ID
read -p "Enter Resource Group: " RESOURCE_GROUP
read -p "Enter Storage Account Name: " STA_NAME
read -p "Enter Environment (e.g., dev, hlg, prod): " ENV
read -p "Enter Location: " LOCATION

# Conditional assignment based on SUBSCRIPTION_ID
if [[ "$SUBSCRIPTION_ID" == "cd7830ba-234d-4033-9d38-22306144b136" ]]; then
    VNET_NAME="AZ_DEVHLG_BIGDATA"
    VNET_RESOURCE_GROUP="rg-network"
    SUBNET_NAME="snet-default"
elif [[ "$SUBSCRIPTION_ID" == "f4e6253c-c926-4223-99db-d6c0e6790a86" ]]; then
    VNET_NAME="AZ_BIGDATA"
    VNET_RESOURCE_GROUP="RG-NETWORK"
    SUBNET_NAME="snet-default"
elif [[ "$SUBSCRIPTION_ID" == "e4128695-83c0-493e-89db-2095acf2d7c6" ]]; then
    VNET_NAME="AZ_DATASCIENCE-PRD"
    VNET_RESOURCE_GROUP="rg-network"
    SUBNET_NAME="snet-datascience"
else
    read -p "Enter Virtual Network Name: " VNET_NAME
    read -p "Enter Virtual Network Resource Group: " VNET_RESOURCE_GROUP
    read -p "Enter Subnet Name: " SUBNET_NAME
fi

# Derived variables
PVE_NAME="pvtlink-$STA_GROUP_ID-$STA_NAME-$ENV"
PVE_CONNECTION_ID=$(az storage account show --resource-group $RESOURCE_GROUP --name $STA_NAME --query '[id]' --output tsv)
CONNECTION_NAME="$STA_NAME.001"
SUBNET_ID=$(az network vnet subnet show --resource-group $VNET_RESOURCE_GROUP --vnet-name $VNET_NAME --name $SUBNET_NAME --query '[id]' --output tsv)

# Set Azure subscription SHARED
az account set --subscription $SUBSCRIPTION_NETWORK_ID

sleep 3

# Get the ID of the private DNS zone in the shared subscription
PRIVATE_DNS_ZONE_ID=$(az network private-dns zone show --resource-group $PVT_DNS_RESOURCE_GROUP --name $PVT_DNS_NAME --query id --output tsv)

# Set Azure subscription of the storage account
az account set --subscription $SUBSCRIPTION_ID

sleep 3

echo -e "\nCreating Private Endpoint: $PVE_NAME"

# Check if a private endpoint already exists for this storage account
EXISTING_PE=$(az network private-endpoint list --resource-group $RESOURCE_GROUP --query "[?privateLinkServiceConnections[?privateLinkServiceId=='$PVE_CONNECTION_ID']].id" --output tsv)

if [[ -n "$EXISTING_PE" ]]; then
    echo "Ô£à A private endpoint already exists for storage account '$STA_NAME'. Skipping creation."
    exit 0
fi

echo "­ƒÜÇ Creating Private Endpoint: $PVE_NAME"

# Create Private Endpoint
az network private-endpoint create --connection-name $CONNECTION_NAME --name $PVE_NAME \
    --private-connection-resource-id $PVE_CONNECTION_ID --resource-group $RESOURCE_GROUP \
    --subnet $SUBNET_ID --group-id $STA_GROUP_ID --vnet-name $VNET_NAME --tags $TAGS

echo -e "­ƒÜÇ Creating Private Endpoint custom DNS in the zone $PVT_DNS_NAME"

# Create Private Endpoint DNS Zone Group "$PVT_DNS_CONFIGURATION_NAME" in the private zone $PVT_DNS_NAME in the shared subscription
az network private-endpoint dns-zone-group create --resource-group $RESOURCE_GROUP --endpoint-name $PVE_NAME --name $PVT_DNS_ZONE_GROUP_NAME --zone-name $PVT_DNS_CONFIGURATION_NAME --private-dns-zone $PRIVATE_DNS_ZONE_ID --tags $TAGS
