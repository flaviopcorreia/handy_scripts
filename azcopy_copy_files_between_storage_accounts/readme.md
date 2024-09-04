# Objetivo

Apresentar como operar com o "azcopy" para fazer cópia de blobs entre storage accounts com diversas opções habilitadas para otmizar a cópia [Opção 1]. Será apresentado uma segunda opção [Opção 2] de como copiar os blobs enviando blobs HOT para o tier ARCHIVE
# Como usar

1- Instalar AzureCLI e AzCopy e acessar o diretório do azcopy baixado.

https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli
https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-v10?tabs=dnf

2-  Logar na subscription da Azure:

az login --tenant "TENANT_ID" --use-device-code 

* Se for necessário, dar autorização ao Use-Device com os comandos abaixo:
https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-authorize-azure-active-directory

export AZCOPY_AUTO_LOGIN_TYPE=DEVICE (linux)
set AZCOPY_AUTO_LOGIN_TYPE=DEVICE (windows DOS)
![image](https://github.com/user-attachments/assets/53509459-f101-4771-8523-42f9b0bf37d4)

3- (Best Practice) Checar se a variável de ambiente de "AZCOPY_CONCURRENCY_VALUE" está definida acima de 1000, se não estiver, pode-se aumentar. Sugestão "2000".

azcopy env (Comando para checar o valor configurado)
set AZCOPY_CONCURRENCY_VALUE=<value> (Comando para configurar o valor desejado)

4- Execução da cópia: 

[Opção de cópia 1] - Cópia de blobs entre storage accounts com diversas opções habilitadas para otmizar a cópia:

azcopy copy "origem/token" "destino/token" --recursive --log-level ERROR --cap-mbps 51200 

[Opção de cópia 2] - Cópia os blobs enviando blobs HOT para o tier ARCHIVE e posteriormente mandar o restante dos dados com o tier original (HOT)

azcopy copy "origem/token" "destino/token" --recursive --log-level ERROR --cap-mbps 51200 --include-before "2024-07-24T14:00:00Z" --blob-type BlockBlob --block-blob-tier Archive
azcopy copy "origem/token" "destino/token" --recursive --log-level ERROR --cap-mbps 51200 --include-after "2024-07-24T14:00:00Z"

5- Depois de fazer a primeira transferência, rodar o sync para transferir os arquivos que ficaram para trás ou foram criados no momento da copia.

azcopy sync "origem/token" "destino/token" --recursive --log-level ERROR --cap-mbps 51200

7- Checar os logs:

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-configure

Log path: C:\Users\
%USERPROFILE%\.azcopy

Cada job vai gerar um log nesse path. 
Olhar para os erros do tipo (UPLOADFAILED, COPYFAILED, or DOWNLOADFAILED) que são mais relevantes, o restante é feito o retry até 20x.

Para filtrar esses erros, executar em Powershell o comando:

Select-String UPLOADFAILED .\8c5ef26c-d01c-d342-68d5-3606e28f1e5c.log

# Referencias

	- Instalar Azure CLI

https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli

	- Estratégia de migração CAF:

https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/relocate/select#select-a-relocation-method

	- Autorizar AzCopy a usar Microsoft Entra para acessar blobs:

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-authorize-azure-active-directory

	- Az Copy Commands:

https://learn.microsoft.com/en-us/azure/storage/common/storage-ref-azcopy-copy

	- Best practices:

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-optimize#limit-the-throughput-data-rate

* Reduce the size of each job (Usar o parametro "include-patter ou include-path" para diminuir o volume transferido). 

Exemplo: usar o "--include-before "2024-07-24T14:00:00Z" para transferir arquivos antes da data especificada apenas.

* To achieve optimal performance, ensure that each jobs transfers fewer than 10 million files. Jobs that transfer more than 50 million files can perform poorly because the AzCopy job tracking mechanism incurs a significant amount of overhead. To reduce overhead, consider dividing large jobs into smaller ones.

* Increase concurrency - 
If you're copying blobs between storage accounts, consider setting the value of the AZCOPY_CONCURRENCY_VALUE environment variable to a value greater than 1000. You can set this variable high because AzCopy uses server-to-server APIs, so data is copied directly between storage servers and does not use your machine's processing power.
After you've decided how to divide large jobs into smaller ones, consider running jobs on more than one Virtual Machine (VM).

* Decrease the number of logs generated - 
You can improve performance by reducing the number of log entries that AzCopy creates as it completes an operation. By default, AzCopy logs all activity related to an operation. To achieve optimal performance, consider setting the --log-level parameter of your copy, sync, or remove command to ERROR. That way, AzCopy logs only errors. By default, the value log level is set to INFO.

* Rodar benchmark para analisar melhor troughput a ser usado na copia de dado on-prem para azure:

azcopy benchmark "(storage account destination)"

	- Limitar throught de rede

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-optimize#limit-the-throughput-data-rate

azcopy jobs resume <job-id> --cap-mbps 10


	- Storage Account Limits:

https://learn.microsoft.com/en-us/azure/storage/common/scalability-targets-standard-account

	- Rodar benchmark para analisar melhor troughput a ser usado na copia de dado on-prem para azure:

azcopy benchmark (storage account destination) 

	- Logs and Resume Jobs:

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-configure

O job name vc consiguirá no aruqivo de LOG onde a o resumo dos erros.

	- Copiar blobs com Az Copy com network restrictions:

https://learn.microsoft.com/en-us/troubleshoot/azure/azure-storage/blobs/connectivity/copy-blobs-between-storage-accounts-network-restriction#copy-blobs-between-storage-accounts-in-a-hub-spoke-architecture-using-private-endpoints

	- Copy blob into Archive:

azcopy copy 'C:\temp\myTextFile.txt' 'https://<storage-account>.blob.core.windows.net/<container>/myTextFile-archived.txt' --blob-type BlockBlob --block-blob-tier Archive

https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/storage/blobs/archive-blob.md

	- Synchronize blobs:

https://learn.microsoft.com/en-us/azure/storage/common/storage-use-azcopy-blobs-synchronize?toc=%2Fazure%2Fstorage%2Fblobs%2Ftoc.json&bc=%2Fazure%2Fstorage%2Fblobs%2Fbreadcrumb%2Ftoc.json
