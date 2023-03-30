import os
import argparse
import json
import traceback
import requests
import time
import google.auth
import google.auth.transport.requests
import google.cloud.documentai_v1beta3 as docai_v1beta3
from tabulate import tabulate
from google.api_core.client_options import ClientOptions
from google.cloud import documentai
from config import *

#Get Processor ServiceClient details
def get_client() :
    """ Get client details """
    client_options = ClientOptions(
        api_endpoint=f"{API_LOCATION}-documentai.googleapis.com"
    )
    return docai_v1beta3.DocumentProcessorServiceClient(client_options=client_options)

def get_parent(client: docai_v1beta3.DocumentProcessorServiceClient):
    """ Get parent details """
    return client.common_location_path(PROJECT_ID, API_LOCATION)

def get_client_and_parent() :
    """ Get parent and client details """
    client = get_client()
    parent = get_parent(client)
    return client, parent

def list_processors_sample(project_id: str, location: str):
    """ Returns the List of the processor's name"""
    processor_name_list=[]
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")
    client = documentai.DocumentProcessorServiceClient(client_options=opts)
    parent = client.common_location_path(project_id, location)
    # Make ListProcessors request
    processor_list = client.list_processors(parent=parent)
    # Print the processor information
    for processor in processor_list:
        processor_name_list.append(processor.display_name) 
    return processor_name_list


#create the processor
def create_processor(display_name: str, type: str,project_id: str ,location: str) -> docai_v1beta3.Processor:
    try:
        client, parent = get_client_and_parent()
        processor_name_list=processor_list=list_processors_sample(project_id, location)
        if display_name in processor_name_list:
            print(f"A Processor with the name {display_name} already exists.")
        else:
            processor = docai_v1beta3.Processor(display_name=display_name, type_=type)
            # Print the processor information
            print(f"Processor Display Name: {processor.display_name}")
            print(f"Processor Type: {processor.type_}")    
            print(f"Processor Created")            
            processor_id=client.create_processor(parent=parent, processor=processor)
            return processor_id.name.split("/")[-1]
    except Exception as e:
        print(f"Processor with the name {display_name} already exist.")

#Defining the schema using the schema json
schema = docai_v1beta3.types.DocumentSchema.from_json(schema_json)

#Trigger training process of the processor
def train_processor_version(document_schema: docai_v1beta3.types.DocumentSchema,
                            version_name: str, 
                            processor_number:str,
                            project_number:str):
    """ Trains the CDE processor with the train and test data"""
    client,parent = get_client_and_parent()  
    processor_parent = f"projects/{project_number}/locations/us/processors/{processor_number}"
    processor_version = docai_v1beta3.ProcessorVersion(display_name = version_name)  
    training_documents_input_config = docai_v1beta3.BatchDocumentsInputConfig(
    gcs_prefix=docai_v1beta3.types.GcsPrefix(gcs_uri_prefix = GCS_PATH_FOR_LABELLED_DATA_TRAIN)
    )  
    test_documents_input_config = docai_v1beta3.BatchDocumentsInputConfig(
    gcs_prefix=docai_v1beta3.types.GcsPrefix(gcs_uri_prefix = GCS_PATH_FOR_LABELLED_DATA_TEST)
    )
    
    input_data = docai_v1beta3.types.TrainProcessorVersionRequest.InputData(
        training_documents =  training_documents_input_config, 
        test_documents = test_documents_input_config)

    request = docai_v1beta3.TrainProcessorVersionRequest(
        parent=processor_parent,
        processor_version = processor_version,
        input_data = input_data,
        document_schema  = document_schema
    )
    operation = client.train_processor_version(request=request)
    print("Training of processor has initiated")
    # Print operation details
    print(f"Operation id:{operation.operation.name}")  

    
try:
    dest_processor_number = create_processor(DEST_WORKBENCH_PROCESSOR_NAME,"CUSTOM_EXTRACTION_PROCESSOR",PROJECT_ID, API_LOCATION)
    if dest_processor_number != None:
        train_processor_version(schema, "ver1",dest_processor_number,project_number)
except Exception as e:
    print("Error in processor training")
    print(e)