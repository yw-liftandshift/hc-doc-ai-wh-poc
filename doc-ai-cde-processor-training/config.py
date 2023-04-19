# This file is for holding variables and schema
import pathlib
import os
#Defining the variables
parameter_dict = {'DEST_PROCESSOR_NUMBER': '1e6f4d8306a06c8a',
                 'GCS_PATH_FOR_LABELLED_DATA_TEST':'gs://marcus-test-doc-wh-poc-1-cde-processor-training-bucket/exported-cde-tagged-data/test/',
                 'GCS_PATH_FOR_LABELLED_DATA_TRAIN':'gs://marcus-test-doc-wh-poc-1-cde-processor-training-bucket/exported-cde-tagged-data/train/',
                 'PROJECT_ID': 'marcus-test-doc-wh-poc-1-cde-processor',
                 'API_LOCATION' : 'northamerica-northeast1',
                 'PROJECT_NUMBER' : '716395299097',
                 'VERSION_NAME' : 'HC CDE processor'}


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