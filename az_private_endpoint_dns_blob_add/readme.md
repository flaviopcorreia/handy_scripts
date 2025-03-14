# Objetivo

Fazer a criação de private endpoints do tipo BLOB e registra-lo em uma zona de DNS privada espeficiada.
 
# Como usar

1- Antes de utilizar este script, é necessário ter instalado o modulo do AZ CLI e ter permissões nas subscrições onde fará as operações, bem como fazer o az login na subscripção onde a storage account esteja criada.

az login --use-device-code

2- Passar os parametros abaixo:

- Esse script leva em consideração que a zona de DNS privada está localizada em outra subscription, portanto é necessário preencher os campos dessa subscrição abaixo:

TAGS="key=value key=valeu"

SUBSCRIPTION_NETWORK_ID=""

PVT_DNS_RESOURCE_GROUP=""

PVT_DNS_NAME=""

PVT_DNS_CONFIGURATION_NAME=""

PVT_DNS_ZONE_GROUP_NAME=""

STA_GROUP_ID="blob"

3- Existe uma condicional onde fixa os valores de vnet e subnet para alguns subscripções em especifico. Se necessário, customizar.

4- Passar os valores abaixo na execução do script:

read -p "Enter Subscription ID: " SUBSCRIPTION_ID
read -p "Enter Resource Group: " RESOURCE_GROUP
read -p "Enter Storage Account Name: " STA_NAME
read -p "Enter Environment (e.g., dev, hlg, prod): " ENV
read -p "Enter Location: " LOCATION

5- Baixar o arquivo "az_private_endpoint_dns_blob_add.sh" e executa-lo.
