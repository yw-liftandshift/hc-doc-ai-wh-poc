import argparse
import json
import os
import traceback
import requests
import time
import logging
import google.auth
import google.auth.transport.requests
import google.cloud.logging
import google.cloud.documentai_v1beta3 as docai_v1beta3
from google.api_core.client_options import ClientOptions
from tabulate import tabulate
from google.cloud import documentai
from config import parameter_dict,schema_json


#Setting up logging
#Instantiates a client
client = google.cloud.logging.Client()
client.setup_logging()
logging.basicConfig(level=logging.DEBUG)

print(parameter_dict)
#Get client and parent details
def get_client_and_parent(project_id: str, location: str):
    """ Get parent and client details """
    client_options = ClientOptions(api_endpoint=f"{API_LOCATION}-documentai.googleapis.com")
    client = docai_v1beta3.DocumentProcessorServiceClient(client_options=client_options)
    parent = client.common_location_path(project_id, location)
    return client, parent

def list_processors_sample(project_id: str, location: str):
    """ Returns the List of the processor's name"""
    processor_name_list = []
    opts = ClientOptions(api_endpoint = f"{location}-documentai.googleapis.com")
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
        processor_name_list = list_processors_sample(project_id, location)
        if display_name in processor_name_list:
            logging.info(f"A Processor with the name {display_name} already exists.")
        else:
            processor = docai_v1beta3.Processor(display_name=display_name, type_=type)
            # Print the processor information
            logging.info(f"Processor Display Name: {processor.display_name}")
            logging.info(f"Processor Type: {processor.type_}")    
            logging.info(f"Processor Created")            
            processor_id = client.create_processor(parent=parent, processor=processor)
            return processor_id.name.split("/")[-1]
    except Exception as e:
        logging.error(e.message)

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
    gcs_prefix = docai_v1beta3.types.GcsPrefix(gcs_uri_prefix = GCS_PATH_FOR_LABELLED_DATA_TRAIN))  
    test_documents_input_config = docai_v1beta3.BatchDocumentsInputConfig(
    gcs_prefix = docai_v1beta3.types.GcsPrefix(gcs_uri_prefix = GCS_PATH_FOR_LABELLED_DATA_TEST))
    
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
    logging.info("Training of processor has initiated")    
    logging.info(f"Operation id:{operation.operation.name}")  

def main():  
    try:
        dest_processor_number = create_processor(parameter_dict['DEST_WORKBENCH_PROCESSOR_NAME'],
                                                 "CUSTOM_EXTRACTION_PROCESSOR",
                                                 parameter_dict['PROJECT_ID'], 
                                                 parameter_dict['API_LOCATION'])
        if dest_processor_number != None:
            train_processor_version(schema, 
                                    parameter_dict['VERSION_NAME'],
                                    dest_processor_number,
                                    parameter_dict['PROJECT_NUMBER'])
    except Exception as e:
        logging.error(f"Error in processor training : {e}")
