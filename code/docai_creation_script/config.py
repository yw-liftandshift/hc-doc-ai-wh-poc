# This file is for holding variables and schema
import pathlib

#Defining the variables
parameter_dict = {'GCS_PATH_FOR_LABELLED_DATA_TEST':'<Add GCS PATH for TEST_DATA>',
                'GCS_PATH_FOR_LABELLED_DATA_TRAIN ': '<Add Project ID>',
                'PROJECT_ID': '<Add Project ID>',
                'API_LOCATION' : '<Add Location>',
                'PROJECT_NUMBER' : '<Add project number>',
                'VERSION_NAME' : '<Add Processor training version name>'}

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
