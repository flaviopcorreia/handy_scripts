import json
import fastavro
import os
from azure.eventhub import EventHubConsumerClient
from azure.storage.blob import BlobServiceClient

# Connection details
namespace = "XXX"  # Your Event Hub namespace without suffix
shared_access_key_name = "XXX" # The shared access key name of your Event-HUB namespace (Not the topic).
shared_access_key = "XX" # The shared access key of your Event-HUB namespace (Not the topic).
eventhub_name = "XXXX" # The topic name of your Event-HUB namespace.
consumer_group = "XXXX"  # Your Event Hub consumer group of your topic.
container_name = "XXX"  # Blob container name for checkpoints
storage_connection_str = "XXX"  # Azure Storage connection string

# Construct the Event Hub connection string dynamically
eventhub_connection_string = (
    f"Endpoint=sb://{namespace}.servicebus.windows.net;"
    f"SharedAccessKeyName={shared_access_key_name};"
    f"SharedAccessKey={shared_access_key};"
    f"EntityPath={eventhub_name}"
)

fully_qualified_namespace = f"{namespace}.servicebus.windows.net"  # Event Hub namespace

# Print the namespace and event_hub connection string

#print("Namespace:", fully_qualified_namespace)
#print("Event Hub Connection String:", eventhub_connection_string)


def get_latest_checkpoint_from_avro(storage_connection_str, container_name, partition_id):
    """Fetch the latest checkpoint from Avro files in the Blob Storage."""
    try:
        blob_service_client = BlobServiceClient.from_connection_string(storage_connection_str)
        container_client = blob_service_client.get_container_client(container_name)

        prefix = f"{namespace}/{eventhub_name}/{partition_id}/"
        #print(f"Searching blobs with prefix: {prefix}")

        blobs = list(container_client.list_blobs(name_starts_with=prefix))

        if not blobs:
            print(f"No blobs found for partition {partition_id}")
            return -1

        # Find the latest blob based on the prefix structure (sorted by timestamp in path)
        latest_blob = max(blobs, key=lambda b: b.name)
        #print(f"Latest blob for partition {partition_id}: {latest_blob.name}")

        # Download and inspect the Avro file
        download_path = f"./temp_{partition_id}.avro"
        with open(download_path, "wb") as file:
            file.write(container_client.download_blob(latest_blob.name).readall())

        # Read the Avro file to get the latest checkpoint
        with open(download_path, "rb") as f:
            reader = fastavro.reader(f)
            records = list(reader)

        if not records:
            print(f"No records found in Avro file {latest_blob.name}")
            return -1

        # Debug: Inspect the contents of the Avro file
        #print(f"Contents of Avro file for partition {partition_id}:")
        #for record in records:
        #    print(record)  # Debug each record

        # Extract the highest sequence number from the Avro records
        max_sequence_number = max((record.get("SequenceNumber", -1) for record in records), default=-1)
        os.remove(download_path)  # Clean up downloaded file

        #print(f"Max sequence number for partition {partition_id}: {max_sequence_number}")
        return max_sequence_number

    except Exception as e:
        print(f"Error fetching checkpoint for partition {partition_id}: {e}")
        return -1




def get_partition_lag(client):
    partition_ids = client.get_partition_ids()
    total_lag = 0
    result = {
        "partitions": [],
        "total_lag": 0
    }

    for partition_id in partition_ids:
        # Fetch partition properties
        partition_properties = client.get_partition_properties(partition_id)
        last_enqueued = partition_properties["last_enqueued_sequence_number"]

        # Fetch the last checkpoint from the checkpoint store
        last_checkpoint = get_latest_checkpoint_from_avro(
            storage_connection_str, container_name, partition_id
        )

        # Calculate lag
        lag = last_enqueued - (last_checkpoint if last_checkpoint != -1 else 0)
        total_lag += lag

        result["partitions"].append({
            "partition_id": partition_id,
            "lag": lag,
            "last_checkpoint": last_checkpoint,
            "last_enqueued": last_enqueued
        })

    result["total_lag"] = total_lag
    print(json.dumps(result, indent=2))
    return result


def main():
    client = EventHubConsumerClient.from_connection_string(
        conn_str=eventhub_connection_string,
        consumer_group=consumer_group
    )

    try:
        with client:
            get_partition_lag(client)
    except KeyboardInterrupt:
        print("Execution interrupted by user.")
    except Exception as e:
        print(f"Error in main execution: {e}")
    finally:
        client.close()


if __name__ == "__main__":
    main()
