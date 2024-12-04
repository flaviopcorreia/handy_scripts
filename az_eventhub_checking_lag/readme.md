# Objetivo

Fazer uma chamada da API de Event-HUB e blobs em storage accounts para coletar informações para fazer um calculo para saber o LAG de cada partição e total. 
# Como usar

1- Antes de utilizar este script, é necessário ter instalado o pyhton 3.12 e os pacotes abaixo:

pip install fastavro

pip install azure-eventhub

pip install azure-eventhub-checkpointstoreblob

pip install azure-storage-blob

2- Integrar seu Event HUB (topic) a um container em storage account para fazer a captura dos dados no formato Avro:

https://learn.microsoft.com/en-us/azure/event-hubs/event-hubs-capture-managed-identity

O formato do arquivo deverá estar conforme abaixo:
{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}

3- Baixar o arquivo "az_eventhub_checking_lag.py" e edita-lo alterando as informações de seu cluster event-hub e storage account.

5- Após editar o arquivo, basta executa-lo "python az_eventhub_checking_lag.py"

# Descrição do script

- Purpose of the Script

    The script calculates the lag for each partition in an Azure Event Hub by comparing the latest enqueued message's sequence number with the last processed (checkpointed) sequence number stored in Avro files in Azure Blob Storage.

- Key Components

    1- Connection Details:

        namespace, eventhub_name, consumer_group, container_name: Configurations for connecting to Azure Event Hub and Blob Storage.

        eventhub_connection_string: Dynamically constructed to connect to the Event Hub.

        storage_connection_str: Used to connect to Azure Blob Storage.
    
    2- get_latest_checkpoint_from_avro Function:

        - Purpose: Retrieves the highest (latest) SequenceNumber (checkpoint) from Avro files in Blob Storage for a given partition.
  
        - Steps:
  
            1- Connects to Blob Storage using storage_connection_str.
  
            2- Lists blobs in the container with a prefix corresponding to the specific partition.

            3- Identifies the latest blob based on the timestamp in its name.
  
            4- Downloads the latest blob and reads its contents using fastavro.
  
            5- Finds the max SequenceNumber from the records in the Avro file.

            6- Returns the max sequence number or -1 if no records or errors occur.
  
    3- get_partition_lag Function:

        - Purpose: Computes the lag for each partition in the Event Hub.
  
        - Steps:
  
            1- Fetches all partition IDs using client.get_partition_ids().
  
            2- For each partition:
  
                - Gets partition properties, including last_enqueued_sequence_number.
  
                - Fetches the last checkpoint from Blob Storage using get_latest_checkpoint_from_avro.
  
                - Calculates the lag as last_enqueued_sequence_number - last_checkpoint.
  
            3- Aggregates partition lags and prints the total lag.
  
    4- main Function:

        - Purpose: Coordinates the Event Hub connection and calls get_partition_lag.
  
        - Steps:
  
            1- Creates an EventHubConsumerClient using the connection string and consumer group.
  
            2- Calls get_partition_lag to calculate and print partition lags.
  
            3- Handles exceptions and ensures the client is closed.
  
    5- Execution Flow:

        - The script starts by executing main(), which connects to Event Hub and calculates the lag for each partition by comparing the Event Hub’s latest sequence number with the Avro checkpoint.
  
- How It Works:

    1- Fetch the Latest Checkpoint:

        - The script checks Azure Blob Storage for the latest Avro file for each partition.
  
        - The SequenceNumber in this Avro file indicates the last processed message.
  
    2- Calculate Lag:

        - Lag is the difference between the latest message in Event Hub (last_enqueued_sequence_number) and the last processed message (last_checkpoint).
  
    3- Output:

        - The script prints a JSON object summarizing the lag for each partition and the total lag.
  
- Sample Output:

```
json
Copy code
{
  "partitions": [
    {
      "partition_id": "0",
      "lag": 42,
      "last_checkpoint": 100,
      "last_enqueued": 142
    },
    {
      "partition_id": "1",
      "lag": 50,
      "last_checkpoint": 120,
      "last_enqueued": 170
    }
  ],
  "total_lag": 92
}
```

- Error Handling:

    - Blob Not Found: If no Avro files exist, it prints a message and returns -1.

    - Avro File Issues: If the file has no records or if parsing fails, the function gracefully handles this and defaults to -1.

    - General Errors: Logged to help debug any unexpected issues.

- Key Insights:

    - Lag Monitoring: This script is useful for monitoring the Event Hub’s processing backlog, helping ensure real-time or near-real-time processing.
      
    - Blob Storage as Checkpoint Store: The script assumes checkpoints are periodically written as Avro files in Blob Storage.
