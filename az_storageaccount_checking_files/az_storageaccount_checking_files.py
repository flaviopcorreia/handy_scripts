#!/usr/bin/env python3

from azure.storage.blob import ContainerClient
from datetime import datetime
import os

# Always use the 5th day of the current month and year
today = datetime.now()
date_str = today.strftime("%Y%m") + "05"
folder_prefix = "reprocessamento/"

patterns = [
    f"DE_CB_EMAIL_CLICK_D-1_{date_str}.csv",
    f"DE_PF_EMAIL_CLICK_D-1_{date_str}.csv",
    f"DE_EX_EMAIL_CLICK_D-1_{date_str}.csv",
    f"DE_CB_EMAIL_BOUNCE_D-1_{date_str}.csv",
    f"DE_PF_EMAIL_BOUNCE_D-1_{date_str}.csv",
    f"DE_EX_EMAIL_BOUNCE_D-1_{date_str}.csv",
    f"DE_CB_EMAIL_JOB_D-1_{date_str}.csv",
    f"DE_PF_EMAIL_JOB_D-1_{date_str}.csv",
    f"DE_EX_EMAIL_JOB_D-1_{date_str}.csv",
    f"DE_CB_EMAIL_OPEN_D-1_{date_str}.csv",
    f"DE_PF_EMAIL_OPEN_D-1_{date_str}.csv",
    f"DE_EX_EMAIL_OPEN_D-1_{date_str}.csv",
    f"DE_CB_EMAIL_SENT_D-1_{date_str}.csv",
    f"DE_PF_EMAIL_SENT_D-1_{date_str}.csv",
    f"DE_EX_EMAIL_SENT_D-1_{date_str}.csv"
]

def check_blobs_exist(storage_account_url, container_name, credential, folder_prefix, patterns):
    container_client = ContainerClient(account_url=storage_account_url, container_name=container_name, credential=credential)
    blobs = list(container_client.list_blobs(name_starts_with=folder_prefix))
    blob_names = {os.path.basename(blob.name) for blob in blobs}

    for pattern in patterns:
        if pattern in blob_names:
            print(f"Found blob: {pattern}")
        else:
            print(f"No blob found with name '{pattern}' in prefix '{folder_prefix}'.")

if __name__ == "__main__":
    storage_account_url = "XXXX"
    container_name = "XXXXX"
    credential = "XXXXX"

    check_blobs_exist(storage_account_url, container_name, credential, folder_prefix, patterns)
