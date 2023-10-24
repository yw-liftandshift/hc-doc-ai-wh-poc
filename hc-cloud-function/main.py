'''
Triggered by a change in a storage bucket to perform
ocr extraction -> entity extraction -> result upload to DocAI Warehouse.
'''
#importing libraries
import logging
import os
import PyPDF2
import google.cloud.contentwarehouse_v1.types
import google.cloud.logging
from gcs_utils import GCSStorage
from cf_config import split_pdf_ocr_sync
from cf_config import env_var
from api_call_utils import process_document_ocr
from api_call_utils import doc_warehouse_creation
from api_call_utils import process_document_and_extract_entities
from postprocessing import build_dictionary_and_filename_from_entities
from postprocessing import update_text_anchors
from postprocessing import get_document_type
from postprocessing import DocumentType

#Setting up logging
#Instantiates a client
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
    gcs_obj = GCSStorage()
    # downloading the file from bucket
    gcs_input_uri = f"gs://{event['bucket']}/{event['name']}"
    pdf_file_name = gcs_input_uri.split('/')[-1]
    blob_name = pdf_file_name.replace(".pdf","")
    local_path = f"/tmp/{pdf_file_name}"
    gcs_obj.download_file(local_path, gcs_input_uri)

    #declaring pdf file reader
    pdfFileObj = open(local_path, 'rb')
    pdfReader = PyPDF2.PdfReader(pdfFileObj)

    output_files = []    

    #Calling multiple ocr sync req
    if len(pdfReader.pages) > 10:
        logging.info('More than 10 pages, multiple syncs will follow')
        page_count = 0
        output_file_loc = f"/tmp"
        output_files = split_pdf_ocr_sync(pdfReader, local_path, blob_name, output_file_loc)
        for output_pdf in output_files:
            if page_count == 0:
                try:
                    doc = process_document_ocr(env_var["project_id"], env_var["location"], env_var["processor_id"], output_pdf, env_var["input_mime_type"])
                    page_count = len(doc.pages)
                except Exception as e:
                    pdfFileObj.close()
                    logging.error(e.message)
                    return {"error": "DocOCR call failed"}
            else:
                try:
                    doc_next = process_document_ocr(env_var["project_id"], env_var["location"], env_var["processor_id"], output_pdf, env_var["input_mime_type"])
                except Exception as e:
                    pdfFileObj.close()
                    logging.error(e.message)
                    return {"error": "DocOCR call failed"}
                for page in doc_next.pages:
                    page.page_number = page_count + 1
                    page_count = page_count + 1
                text_length = len(doc.text) + 1
                doc = update_text_anchors(doc, doc_next, text_length)
        pdfFileObj.close()
    else:
        try:
            doc = process_document_ocr(env_var["project_id"], env_var["location"], env_var["processor_id"], local_path, env_var["input_mime_type"])
        except:
            raise
        finally:
            pdfFileObj.close()
        
    logging.info("doc creation completed")

    #Sending request to classifier and choose proper document processor
    try:
        extract_file_type_from_entities = lambda entities: get_document_type(sorted(entities, key=lambda x: x.confidence, reverse=True)[0].type_)

        document_class = extract_file_type_from_entities(process_document_and_extract_entities(env_var["project_id"], env_var["location"], env_var["processor_id_cde_classifier_type_type"], local_path))

        logging.debug(document_class)

        entities_extractor_processor_id = env_var["processor_id_cde_lrs_type"] if document_class == DocumentType.LRS_DOCUMENTS_TYPE else env_var["processor_id_cde_general_type_type"]

        entities = process_document_and_extract_entities(env_var["project_id"], env_var["location"], entities_extractor_processor_id, local_path)

    except:
        raise

    #Post-Process the cde response
    key_val_dict, display_name = build_dictionary_and_filename_from_entities(entities, blob_name, float(env_var["file_number_confidence_threshold"]))

    #Send the value_dict to warehouse api call to display the properties
    try:
        doc_warehouse_creation(env_var["project_number"],
            env_var["location"],
            doc,
            env_var["schema_id"],
            display_name,
            gcs_input_uri,
            key_val_dict 
        )
    except:
        raise

    os.remove(local_path)
    if output_files:
        for output_pdf in output_files:
            os.remove(output_pdf)
    logging.info("process complete")