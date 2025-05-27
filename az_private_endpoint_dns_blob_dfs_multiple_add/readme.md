# Objetivo

Fazer a criação de private endpoints do tipo BLOB e/ou DFS (Hierarchical Namespace) e registra-lo em uma zona de DNS privada espeficiada.
Esse script tem uma função de LOOP onde você poderá definir multiplas storage accounts desde que elas estejam na mesma subscrição, resource group, localidade e ambiente "DEV,HLG,PRD";
É necessário criar um arquivo storage_accounts.txt no path do script e lá dentro definir as storage accounts que queira adicionar.
Caso seja uma storage account para Datalake com Hierarchical Namespace habilitado, vai criar somente o private endpoint do tipo DFS.

# Como usar

1- Antes de utilizar este script, é necessário ter instalado o modulo do AZ CLI e ter permissões nas subscrições onde fará as operações, bem como fazer o az login na subscripção onde a storage account esteja criada.

az login --use-device-code

2- Passar os parametros abaixo:

- Esse script leva em consideração que a zona de DNS privada está localizada em outra subscription, portanto é necessário preencher os campos dessa subscrição abaixo:

TAGS="key=value key=valeu"

SUBSCRIPTION_NETWORK_ID=""

PVT_DNS_RESOURCE_GROUP=""

PVT_DNS_NAME_BLOB=""

PVT_DNS_NAME_DFS=""

PVT_DNS_CONFIGURATION_NAME_BLOB=""

PVT_DNS_CONFIGURATION_NAME_DFS=""

PVT_DNS_ZONE_GROUP_NAME=""

STA_GROUP_ID_BLOB="blob"

STA_GROUP_ID_DFS="dfs"

3- Existe uma condicional onde fixa os valores de vnet e subnet para alguns subscripções em especifico. Se necessário, customizar.

4- Passar os valores abaixo na execução do script:

read -p "Enter Subscription ID: " SUBSCRIPTION_ID
read -p "Enter Resource Group: " RESOURCE_GROUP
read -p "Enter Environment (e.g., dev, hlg, prod): " ENV
read -p "Enter Location: " LOCATION

5- Baixar o arquivo "az_private_endpoint_dns_blob_dfs_add.sh" e executa-lo.
