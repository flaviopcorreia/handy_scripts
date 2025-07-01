# Objetivo

Conectar em uma storage account com acesso público habilitado e checar se existem alguns blobs .csv com um padrão de nome pré-determinada e com a data que no caso é todo dia 05 do mês e ano corrente. Se houver, vai apresentar como output a mensagem que o arquivo existe, se não, apresentará a mensagem que não existe, posteriormente escreverá no diretório local definido na variavel "output_dir" o output.

# Como usar

1- Antes de utilizar este script, é necessário ter instalado o pyhton 3.12 e os pacotes abaixo:

pip install azure-storage-blob

2- Baixar o arquivo "az_storageaccount_checking_files.py" e edita-lo alterando as informações de sua storage account nos campos:

- storage_account_url: Informar a URL do storage account
- container_name: Informar o container
- credential: Informar a key de acesso a storage account. Preferencialmente gere uma SAS key.
- folder_prefix: Caso os blobs estejam dentro de pastas, informar o path das pastas aqui.
- date_str: Definir a data que quer que seja analisada. No caso está configurado todo dia 05 do mês e ano corrente.

3- Após editar o arquivo, basta executa-lo "az_storageaccount_checking_files.py"
