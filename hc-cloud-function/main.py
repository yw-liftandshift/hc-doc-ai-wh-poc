'''
Triggered by a change in a storage bucket to perform
ocr extraction -> entity extraction -> result upload to DocAI Warehouse.
'''
#importing libraries
import json
import logging
import os
import proto
import PyPDF2
import google.cloud.contentwarehouse_v1.types
import google.cloud.logging
from PyPDF2 import PdfFileWriter
from PyPDF2 import PdfFileReader
from gcs_utils import GCSStorage
from cf_config import split_pdf_cde
from cf_config import split_pdf_ocr_sync
from cf_config import property_set
from cf_config import env_var
from api_call_utils import process_document_ocr
from api_call_utils import doc_warehouse_creation
from api_call_utils import process_document_sample_cde
from postprocessing import ocr_postprocess
from postprocessing import update_text_anchors
from google.cloud import contentwarehouse
from google.api_core.client_options import ClientOptions
from google.cloud import documentai_v1 as documentai

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

    #split and fetch the 1st page only
    output_file_loc = f"/tmp"
    first_page_path = split_pdf_cde(pdfReader, local_path, blob_name, output_file_loc)
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
                page_count_old = page_count
                for page in doc_next.pages:
                    page.page_number = page_count + 1
                    page_count = page_count + 1
                text_length = len(doc.text) + 1
                doc = update_text_anchors(doc, doc_next, text_length)
    else:
        try:
            doc = process_document_ocr(env_var["project_id"], env_var["location"], env_var["processor_id"], local_path, env_var["input_mime_type"])
        except Exception as e:
            pdfFileObj.close()
            logging.error(e.message)
            return {"error": "DocOCR call failed"}
        
    logging.info("doc creation completed")

    #Sending request to CDE processor
    try:
        doc_cde = process_document_sample_cde(
                env_var["project_id"],
                env_var["location"],
                env_var["processor_id_cde"],
                first_page_path,
                env_var["input_mime_type"]
        )
    except Exception as e:
        pdfFileObj.close()
        logging.error(e.message)
        return {"error": "CDE API call failed"}

    json_string = proto.Message.to_json(doc_cde)
    doc_cde_json = json.loads(json_string)
    #Post-Process the cde response
    key_val_dict = ocr_postprocess(doc_cde_json)

    #Send the value_dict to warehouse api call to display the properties
    display_name = blob_name
    try:
        doc_warehouse_creation(env_var["project_number"],
            env_var["location"],
            doc,
            env_var["schema_id"],
            display_name,
            gcs_input_uri,
            key_val_dict 
        )
    except Exception as e:
        pdfFileObj.close()
        logging.error(e.message)
        return {"error": "Warehouse Document Creation failed"}

    pdfFileObj.close()
    os.remove(local_path)
    os.remove(first_page_path)
    if output_files:
        for output_pdf in output_files:
            os.remove(output_pdf)
    logging.info("process complete")