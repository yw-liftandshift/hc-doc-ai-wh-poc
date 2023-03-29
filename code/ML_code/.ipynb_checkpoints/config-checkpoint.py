from google.cloud import contentwarehouse
import PyPDF2
from PyPDF2 import PdfWriter, PdfFileReader
import pathlib
import os

#Defining constants
project_id = os.environ.get("project_id", '')
project_number = os.environ.get("project_number", '')
location = os.environ.get("location", '')
processor_id = os.environ.get("processor_id", '')
processor_id_cde = os.environ.get("processor_id_cde", '')
processor_version_id= os.environ.get("processor_version_id", '')
gcs_output_uri = os.environ.get("gcs_output_uri", '')
gcs_output_uri_prefix = os.environ.get("gcs_output_uri_prefix", '')
input_mime_type = os.environ.get("input_mime_type", '')
schema_id = os.environ.get("schema_id", '')
sa_user = os.environ.get("sa_user", '')

def split_pdf(pdfReader, file_loc, blob_name, output_file_loc):
    '''
    This function extracts only the first page out the pdf

    Args:
    pdfReader : PyPDF2 pdf reader object

    file_loc : str
               Contains the location of the raw pdf
    
    blob_name : str
                PDF file name without extension

    output_file_loc : str
                      Contains output directory of first page pdf

    Returns:
    output_file_name : str
                       Contains location of output path of first page pdf 
    '''
    if pdfReader.is_encrypted:
        pdfReader.decrypt('')
    number_of_pages = pdfReader.pages
    for i in range(len(number_of_pages)):
        output = PdfWriter()
        output.add_page(pdfReader.pages[i])
        output_file_name = output_file_loc+ "/" + blob_name+ f"first_page_{i+1}.pdf"
        with open(output_file_name, "wb") as outputStream:
            output.write(outputStream)
        break
    return output_file_name


def split_pdf_ocr_sync(pdfReader, file_loc, pdf_file_name, output_file_loc):
    '''
    Split pdf in groups of 10 pages and save them for further processing

    Args:
    pdfReader : PyPDF2 pdf reader object

    file_loc : str
               Contains the location of the raw pdf
    
    pdf_file_name : str
                PDF file name

    output_file_loc : str
                      Contains output directory of split pdfs

    Returns:
    output_files : list
                   Contains location of splitted pdf of 10 pages 
    '''
    start = 0 
    # starting index of last slice 
    end = 10 
    splits = len(pdfReader.pages)//10
    output_files = []

    for i in range(splits+1): 
        # creating pdf writer object for ith split 
        if start == end: break
        pdfWriter = PdfWriter() 

        # output pdf file name 
        outputpdf = pdf_file_name.split('.pdf')[0] + "_" + str(i+1) + '.pdf'

        # adding pages to pdf writer object 
        for page in range(start,end): 
            pdfWriter.add_page(pdfReader.pages[page]) 

        # writing split pdf pages to pdf file 
        outputpdf = output_file_loc + "/" + outputpdf
        output_files.append(outputpdf)
        with open(outputpdf, "wb") as f: 
            pdfWriter.write(f) 

        # interchanging page split start position for next split 
        start = end 

        end = end+10
        if end >= len(pdfReader.pages):
            end = len(pdfReader.pages)
    
    return output_files

        

def property_set(document, key_val_dict):
    '''
    Split pdf in groups of 10 pages and save them for further processing

    Args:
    document : contentwarehouse document object

    key_val_dict : dict
                   Dictionary of key-value pairs
    
    Returns:
    document : contentwarehouse document object with appended properties
    '''
    for prop_name,prop_value in key_val_dict.items():
        prop = contentwarehouse.Property()
        prop.name = prop_name
        prop.text_values.values = [prop_value]
        document.properties.append(prop)
    return document
        

    
