#importing libraries
from google.cloud import contentwarehouse
import json
import google.cloud.contentwarehouse_v1.types
from google.api_core.client_options import ClientOptions
from google.cloud import documentai_v1 as documentai
import PyPDF2
from PyPDF2 import PdfFileWriter, PdfFileReader
from gcs_utils import *
import pathlib
import shutil
from config import *
from api_call_utils import *
from postprocessing import *
from datetime import datetime
import proto

def main(event, context):
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
    first_page_path = split_pdf(pdfReader, local_path, blob_name, output_file_loc)
    output_files = []    

    #Calling multiple ocr sync req
    if len(pdfReader.pages) > 10:
        print("More than 10 pages, multiple syncs will follow")
        page_count = 0
        output_file_loc = f"/tmp"
        output_files = split_pdf_ocr_sync(pdfReader, local_path, blob_name, output_file_loc)
        for output_pdf in output_files:
            if page_count == 0:
                try:
                    doc = process_document_ocr(project_id, location, processor_id, output_pdf, "application/pdf")
                    page_count = len(doc.pages)
                except Exception as e:
                    pdfFileObj.close()
                    print(e.message)
                    return {"error": "DocOCR call failed"}
            else:
                try:
                    doc1 = process_document_ocr(project_id, location, processor_id, output_pdf, "application/pdf")
                except Exception as e:
                    pdfFileObj.close()
                    print(e.message)
                    return {"error": "DocOCR call failed"}
                page_count_old = page_count
                for page in doc1.pages:
                    page.page_number = page_count+1
                    page_count = page_count+1
                text_length = len(doc.text)+1
                doc = update_text_anchors(doc, doc1, text_length)
    else:
        try:
            doc = process_document_ocr(project_id, location, processor_id, local_path, "application/pdf")
        except Exception as e:
            pdfFileObj.close()
            print(e.message)
            return {"error": "DocOCR call failed"}
        
    print("doc creation completed")

    #CDE calls
    try:
        doc_cde = process_document_sample_cde(
                project_id,
                location,
                processor_id_cde,
                first_page_path,
                input_mime_type
        )
    except Exception as e:
        pdfFileObj.close()
        print(e.message)
        return {"error": "CDE API call failed"}

    json_string = proto.Message.to_json(doc_cde)
    doc_cde_json = json.loads(json_string)
    #Post-Process the cde response
    key_val_dict = ocr_postprocess(doc_cde_json)

    #Send the value_dict to warehouse api call to display the properties
    display_name = blob_name
    try:
        doc_creation(project_number,
            location,
            doc,
            schema_id,
            display_name,
            gcs_input_uri,
            key_val_dict 
        )
    except Exception as e:
        pdfFileObj.close()
        print(e.message)
        return {"error": "Warehouse Document Creation failed"}

    pdfFileObj.close()
    os.remove(local_path)
    os.remove(first_page_path)
    if output_files:
        for output_pdf in output_files:
            os.remove(output_pdf)
    print("process complete")
        
    