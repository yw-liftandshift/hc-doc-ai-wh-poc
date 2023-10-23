'''
This file contains the functionality to split first page out of pdf,
splitting pdf into sets of 10 pages each and setting values for each
properties of DocAI Warehouse.
'''
#importing libraries
import os
import pathlib
import PyPDF2
from PyPDF2 import PdfWriter, PdfFileReader
from google.cloud import contentwarehouse

'''Defining variables which will be initialized from terraform script'''
env_var = {"project_id" : os.environ.get("project_id", ""),
           "project_number" : os.environ.get("project_number", ""),
           "location" : os.environ.get("location", ""),
           "processor_id" : os.environ.get("processor_id", ""),
           "processor_id_cde_lrs_type" : os.environ.get("processor_id_cde_lrs_type", ""),
           "processor_id_cde_classifier_type_type" : os.environ.get("processor_id_cde_classifier_type_type", ""),
           "processor_id_cde_general_type_type" : os.environ.get("processor_id_cde_general_type_type", ""),
           "input_mime_type" : os.environ.get("input_mime_type", ""),
           "schema_id" : os.environ.get("schema_id", ""),
           "sa_user" : os.environ.get("sa_user", "")}

def split_pdf_cde(pdfReader, file_loc, blob_name, output_file_loc):
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
    output = PdfWriter()
    output.add_page(pdfReader.pages[0])
    output_file_name = output_file_loc + "/" + blob_name + f"first_page_1.pdf"
    with open(output_file_name, "wb") as outputStream:
        output.write(outputStream)
    return output_file_name


def split_pdf_ocr_sync(pdfReader, file_loc, pdf_file_name, output_file_loc, chunk_size=10):
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
    num_pages = len(pdfReader.pages)
    output_files = []

    for i in range(0, num_pages, chunk_size): 
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
    This function sets the property of attributes of Docai Warehouse

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