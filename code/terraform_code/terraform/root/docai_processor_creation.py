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
from google.api_core.client_options import ClientOptions as clientoptions
from tabulate import tabulate
from google.cloud import documentai
from config import parameter_dict,schema_json



#Variables from terraform code
project_id = parameter_dict['PROJECT_ID']
project_number=parameter_dict['PROJECT_NUMBER']
location = parameter_dict['API_LOCATION']
version_name = parameter_dict['VERSION_NAME']
gcs_path_for_train_data=parameter_dict['GCS_PATH_FOR_LABELLED_DATA_TRAIN']
gcs_path_for_test_data = parameter_dict['GCS_PATH_FOR_LABELLED_DATA_TEST']
dest_processor_number = parameter_dict['DEST_PROCESSOR_NUMBER']

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
    client_options = clientoptions(api_endpoint=f"{location}-documentai.googleapis.com")
    client = docai_v1beta3.DocumentProcessorServiceClient(client_options=client_options)
    parent = client.common_location_path(project_id, location)
    return client, parent


#Defining the schema using the schema json
schema = docai_v1beta3.types.DocumentSchema.from_json(schema_json)

def train_processor_version(document_schema: docai_v1beta3.types.DocumentSchema,
                            version_name: str, 
                            processor_number:str,
                            project_number:str,
                            project_id: str,
                            location: str,
                            gcs_path_for_train_data: str,
                            gcs_path_for_test_data: str):
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
    gcs_path_for_train_data : str
                            path of the train data
    gcs_path_for_test_data : str
                            path of the test data
    '''
    client,parent = get_client_and_parent(project_id, location)  
    processor_parent = f"projects/{project_number}/locations/us/processors/{processor_number}"
    processor_version = docai_v1beta3.ProcessorVersion(display_name=version_name)  
    training_documents_input_config = docai_v1beta3.BatchDocumentsInputConfig(
    gcs_prefix = docai_v1beta3.types.GcsPrefix(gcs_uri_prefix=gcs_path_for_train_data))  
    test_documents_input_config = docai_v1beta3.BatchDocumentsInputConfig(
    gcs_prefix = docai_v1beta3.types.GcsPrefix(gcs_uri_prefix=gcs_path_for_test_data))    
    input_data =docai_v1beta3.types.TrainProcessorVersionRequest.InputData(training_documents=training_documents_input_config,                                                                                    test_documents=test_documents_input_config)
    request = docai_v1beta3.TrainProcessorVersionRequest(parent=processor_parent,
                                                         processor_version=processor_version,
                                                         input_data=input_data,
                                                         document_schema=document_schema)
    operation = client.train_processor_version(request=request)
   

def main():
    
    try:
        #Processor id to be recieved from the the terraform code
        if dest_processor_number != None:
            train_processor_version(schema, 
                                    version_name,
                                    dest_processor_number,
                                    project_number,
                                    project_id,
                                    location,
                                    gcs_path_for_train_data,
                                    gcs_path_for_test_data)
    except Exception as e:
        logging.error(f"Error in processor training : {e}")

if __name__=="__main__":
    main()
