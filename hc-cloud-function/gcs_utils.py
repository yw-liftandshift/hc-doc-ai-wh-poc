'''
This file is responsible for GCS operations
'''
#importing libraries
import re
from google.cloud import storage

class GCSStorage:
    """This class contains functions realted to Google Cloud Storage API."""
    def __init__(self) -> None:
        '''
        GCP Storage class constructor.
        '''
        self.storage_client = storage.Client()

    def refresh_storage_instance(self) -> None:
        '''
        Use to create a new storage client each time any function is called.
        '''
        self.storage_client = storage.Client()

    def download_file(self, local_path: str, gcs_path: str) -> None:
        '''
        Function to download a file from gcs.

        Args:
        local_path : str
                     Local path to where you want the file from GCS
        
        gcs_path : str
                   gs path of the files
        '''
        self.refresh_storage_instance()
        match = re.match(r'gs://([^/]+)/(.+)', gcs_path)
        source_bucket = match.group(1)
        source_prefix = match.group(2)
        bucket = self.storage_client.bucket(source_bucket)
        blob = bucket.get_blob(source_prefix)
        blob.download_to_filename(local_path)