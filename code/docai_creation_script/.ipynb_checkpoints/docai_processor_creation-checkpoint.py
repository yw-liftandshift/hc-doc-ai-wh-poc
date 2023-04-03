#Importing Libraries
import argparse
import json
import logging
import os
import requests
import time
import traceback
import google.auth
import google.auth.transport.requests
import google.cloud.logging
import google.cloud.documentai_v1beta3 as docai_v1beta3
from google.api_core.client_options import ClientOptions as client_options
from tabulate import tabulate
from google.cloud import documentai
from config import parameter_dict,schema_json

#Setting up logging
#Instantiates a client
client = google.cloud.logging.Client()
client.setup_logging()
logging.basicConfig(level=logging.DEBUG)

#Variables from terraform code
project_id = os.environ.get("project_id", '')
location = os.environ.get("location", '')
dest_processor_number = os.environ.get("processor_id", '')
version_name = os.environ.get("version_name", '')

def get_client_and_parent(project_id: str, location: str):
    '''
    This function gets parent and client details

    Args:
    project_id : str
                 Contains the Project id

    location : str
               Contains the location of processor

    Returns:
    client : str
              Contains client details
    parent : str
              parent details  
    '''
    client_options = client_options(api_endpoint=f"{API_LOCATION}-documentai.googleapis.com")
    client = docai_v1beta3.DocumentProcessorServiceClient(client_options=client_options)
    parent = client.common_location_path(project_id, location)
    return client, parent


#Defining the schema using the schema json
schema = docai_v1beta3.types.DocumentSchema.from_json(schema_json)

def train_processor_version(document_schema: docai_v1beta3.types.DocumentSchema,
                            version_name: str, 
                            processor_number:str,
                            project_number:str):
    '''
    This function trains the CDE processor

    Args:
    document_schema : str
                    Schema for the processor
    version_name : str
                 version name for the training
    processor_number : str
                     processor number 
    project_number : str
               Contains the project number    
    '''
    client,parent = get_client_and_parent()  
    processor_parent = f"projects/{project_number}/locations/us/processors/{processor_number}"
    processor_version = docai_v1beta3.ProcessorVersion(display_name=version_name)  
    training_documents_input_config = docai_v1beta3.BatchDocumentsInputConfig(
    gcs_prefix = docai_v1beta3.types.GcsPrefix(gcs_uri_prefix=GCS_PATH_FOR_LABELLED_DATA_TRAIN))  
    test_documents_input_config = docai_v1beta3.BatchDocumentsInputConfig(
    gcs_prefix = docai_v1beta3.types.GcsPrefix(gcs_uri_prefix=GCS_PATH_FOR_LABELLED_DATA_TEST))    
    input_data =docai_v1beta3.types.TrainProcessorVersionRequest.InputData(training_documents=training_documents_input_config,
                                                                           test_documents=test_documents_input_config)
    request = docai_v1beta3.TrainProcessorVersionRequest(parent=processor_parent,
                                                         processor_version=processor_version,
                                                         input_data=input_data,
                                                         document_schema=document_schema)
    operation = client.train_processor_version(request=request)
    logging.info("Training of processor has initiated")    
    logging.info(f"Operation id:{operation.operation.name}")  

def main():  
    try:
        #Processor id to be recieved from the the terraform code
        dest_processor_number = os.environ.get("processor_id", '')
        if dest_processor_number != None:
            train_processor_version(schema, 
                                    parameter_dict['VERSION_NAME'],
                                    dest_processor_number,
                                    parameter_dict['PROJECT_NUMBER'])
    except Exception as e:
        logging.error(f"Error in processor training : {e}")