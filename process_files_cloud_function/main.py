'''
Triggered by a change in a storage bucket to perform
ocr extraction -> entity extraction -> result upload to DocAI Warehouse.
'''
# importing libraries
import logging
import google.cloud.contentwarehouse_v1.types
import google.cloud.logging
import os
from api_call_utils import doc_warehouse_creation, get_file_from_cloud_storage_as_raw_document, process_document_ocr, process_document_and_extract_entities
from postprocessing import build_documents_warehouse_properties_from_entities, get_document_type, DocumentType

# Setting up logging
# Instantiates a client
client = google.cloud.logging.Client()
client.setup_logging()
logging.basicConfig(level=logging.DEBUG)

'''Defining variables which will be initialized from terraform script'''
env_var = {"project_id" : os.environ["project_id"],
           "project_number" : os.environ["project_number"],
           "log_id": os.environ["log_id"],
           "location" : os.environ["location"],
           "processor_id" : os.environ["processor_id"],
           "processor_id_cde_lrs_type" : os.environ["processor_id_cde_lrs_type"],
           "processor_id_cde_classifier_type_type" : os.environ["processor_id_cde_classifier_type_type"],
           "processor_id_cde_general_type_type" : os.environ["processor_id_cde_general_type_type"],
           "file_number_confidence_threshold" : os.environ["file_number_confidence_threshold"],
           "input_mime_type" : os.environ["input_mime_type"],
           "schema_id" : os.environ["schema_id"],
           "sa_user" : os.environ["sa_user"]}

def main(event, context):
    '''
    Background Cloud Function to be triggered by Cloud Storage.
    This generic function logs relevant data when a file is changed,
    and works for all Cloud Storage CRUD operations.

    Args:
    event (dict):  The dictionary with data specific to this type of event.
                    The `data` field contains a description of the event in
                    the Cloud Storage `object` format described here:
                    https://cloud.google.com/storage/docs/json_api/v1/objects#resource
    context (google.cloud.functions.Context): Metadata of triggering event.
    '''
    gcs_input_uri = f"gs://{event['bucket']}/{event['name']}"
    pdf_file_name = event['name']
    blob_name = pdf_file_name.replace(".pdf", "")

    raw_document = get_file_from_cloud_storage_as_raw_document(
        event['bucket'], event['name'], event['contentType'])

    doc = process_document_ocr(
        env_var["project_id"], env_var["location"], env_var["processor_id"], raw_document)

    # Sending request to classifier and choose proper document processor
    try:
        def extract_file_type_from_entities(entities): return get_document_type(
            sorted(entities, key=lambda x: x.confidence, reverse=True)[0].type_)
        
        classification_entities, classification_model_info =  process_document_and_extract_entities(
            env_var["project_id"], env_var["location"], env_var["processor_id_cde_classifier_type_type"], raw_document)

        document_class = extract_file_type_from_entities(classification_entities)

        __logEntries(classification_entities, file_name=gcs_input_uri,
                     model_version=classification_model_info.name,
                     model_name=classification_model_info.display_name)

        logging.debug(document_class)

        entities_extractor_processor_id = env_var["processor_id_cde_lrs_type"] if document_class == DocumentType.LRS_DOCUMENTS_TYPE else env_var["processor_id_cde_general_type_type"]

        cde_entities, cde_model_info = process_document_and_extract_entities(
            env_var["project_id"], env_var["location"], entities_extractor_processor_id, raw_document)
        
        __logEntries(cde_entities, file_name=gcs_input_uri,
                model_version=cde_model_info.name,
                model_name=cde_model_info.display_name)
    except:
        raise

    # Post-Process the cde response
    document_warehouse_properties = build_documents_warehouse_properties_from_entities(
        cde_entities, blob_name, document_class)

    # Send the value_dict to warehouse api call to display the properties
    try:
        doc_warehouse_creation(env_var["project_number"],
                                env_var["location"],
                                doc,
                                env_var["schema_id"],
                                gcs_input_uri,
                                document_warehouse_properties,
                                env_var["sa_user"]
                                )
    except:
        raise

    logging.info("process complete")


def __logEntries(recognized_entities, file_name = None, model_name = None, model_version = None):
    '''
    This function is used to log the entries.
    '''
    recognition_output_client = google.cloud.logging.Client()
    recognition_output_client.setup_logging(log_level=logging.DEBUG)
    logger = recognition_output_client.logger(name=env_var["log_id"])

    entities = {}
    file_no_list = []
    for item in recognized_entities.pb:
        # Can be multiple file no
        if item.type_ == "file_no":
            file_no_list.append({"value": item.mention_text, "confidence": item.confidence})
            entities[item.type_] = file_no_list
        else:
            entities[item.type_] = {"value": item.mention_text, "confidence": item.confidence}
    
    data = {}
    data["entities"] = entities
    data["filename"] = file_name
    data["model_name"] = model_name
    data["model_version"] = model_version

    logger.log_struct(data)