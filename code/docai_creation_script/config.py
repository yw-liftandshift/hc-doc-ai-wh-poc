# This file is for holding variables and schema
#Importing Library
import pathlib

#Defining the variables
parameter_dict = {'DEST_WORKBENCH_PROCESSOR_NAME': 'auto_processor2',
                'GCS_PATH_FOR_LABELLED_DATA_TEST':'gs://hcwarehouse-pdf-storage/exported-cde-tagged-data/test/',
                'GCS_PATH_FOR_LABELLED_DATA_TRAIN ': 'gs://hcwarehouse-pdf-storage/exported-cde-tagged-data/train/',
                'PROJECT_ID': 'q-gcp-10940-hcwarehouse-23-02',
                'API_LOCATION' : 'us',
                'PROJECT_NUMBER' : '739989291402',
                 'VERSION_NAME' : 'version1'}

#Schema for the labelled entities
schema_json = """{
    "displayName": "all-entity-document-schema",
    "description": "Document schema for purchase order processor.",
    "entityTypes": [{
        "name": "custom_extraction_document_type",
        "baseTypes": ["document"],
        "properties": [{
            "name": "barcode_number",
            "valueType": "string",
            "occurrenceType": 1
        }, 
        {
            "name": "classification_code",
            "valueType": "string",
            "occurrenceType": 1
        },
        {
            "name": "classification_level",
            "valueType": "string",
            "occurrenceType": 1
        },
        {
            "name": "file_number",
            "valueType": "string",
            "occurrenceType": 1
        },
        {
            "name": "org_code",
            "valueType": "string",
            "occurrenceType": 1
        },
        {
            "name": "volume",
            "valueType": "string",
            "occurrenceType": 1
        }]
    }]
}"""
