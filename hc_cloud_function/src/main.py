'''
Triggered by a change in a storage bucket to perform
ocr extraction -> entity extraction -> result upload to DocAI Warehouse.
'''
# importing libraries
import logging
import google.cloud.contentwarehouse_v1.types
import google.cloud.logging
from cf_config import env_var
from api_call_utils import doc_warehouse_creation, get_file_from_cloud_storage_as_raw_document, process_document_ocr, process_document_and_extract_entities
from postprocessing.postprocessing import build_documents_warehouse_properties_from_entities, get_document_type, DocumentType

# Setting up logging
# Instantiates a client
client = google.cloud.logging.Client()
client.setup_logging()
logging.basicConfig(level=logging.DEBUG)

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

        document_class = extract_file_type_from_entities(process_document_and_extract_entities(
            env_var["project_id"], env_var["location"], env_var["processor_id_cde_classifier_type_type"], raw_document))

        logging.debug(document_class)

        entities_extractor_processor_id = env_var["processor_id_cde_lrs_type"] if document_class == DocumentType.LRS_DOCUMENTS_TYPE else env_var["processor_id_cde_general_type_type"]

        entities = process_document_and_extract_entities(
            env_var["project_id"], env_var["location"], entities_extractor_processor_id, raw_document)
    except:
        raise

    # Post-Process the cde response
    document_warehouse_properties = build_documents_warehouse_properties_from_entities(
        entities, blob_name, document_class)

    # Send the value_dict to warehouse api call to display the properties
    try:
        doc_warehouse_creation(env_var["project_number"],
                                env_var["location"],
                                doc,
                                env_var["schema_id"],
                                gcs_input_uri,
                                document_warehouse_properties
                                )
    except:
        raise

    logging.info("process complete")
