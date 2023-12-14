'''
This file contains the functionality to split first page out of pdf,
splitting pdf into sets of 10 pages each and setting values for each
properties of DocAI Warehouse.
'''
#importing libraries
import os
from google.cloud import contentwarehouse



class DocumentWarehouseProperties:
    '''
    This class contains the properties of DocAI Warehouse
    '''
    def __init__(self, file_title = None, file_number = None, barcode_number = None, org_code=None, date=None, classification_code=None, classification_level=None, volume=None):
        
        self.barcode_number = barcode_number
        self.classification_code = classification_code
        self.classification_level = classification_level
        self.file_number = file_number
        self.file_title = file_title
        self.org_code = org_code
        self.volume = volume
        self.date = date
        self.display_name = None #not a part of DocumentWarehouse schema, contains display name
    
    '''
    Returns:
    props : list
            List of properties to be set in DocumentWarehouse
    '''
    def to_documentai_property(self):
        props = []
        for field, value in vars(self).items():
            if value is not None and field != 'display_name':
                prop = contentwarehouse.Property()
                prop.name = field
                prop.text_values.values = value if isinstance(value, list) else [value]
                props.append(prop)
        return props

'''Defining variables which will be initialized from terraform script'''
env_var = {"project_id" : os.environ.get("project_id", ""),
           "project_number" : os.environ.get("project_number", ""),
           "location" : os.environ.get("location", ""),
           "processor_id" : os.environ.get("processor_id", ""),
           "processor_id_cde_lrs_type" : os.environ.get("processor_id_cde_lrs_type", ""),
           "processor_id_cde_classifier_type_type" : os.environ.get("processor_id_cde_classifier_type_type", ""),
           "processor_id_cde_general_type_type" : os.environ.get("processor_id_cde_general_type_type", ""),
           "file_number_confidence_threshold" : os.environ.get("file_number_confidence_threshold", "0.7"),
           "input_mime_type" : os.environ.get("input_mime_type", ""),
           "schema_id" : os.environ.get("schema_id", ""),
           "sa_user" : os.environ.get("sa_user", "")}
