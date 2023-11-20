from enum import Enum, auto
import copy
from cf_config import DocumentWarehouseProperties
from roman_to_arabic import roman_to_arabic, is_roman_number

class DocumentType(Enum):
    LRS_DOCUMENTS_TYPE = auto()
    GENERAL_DOCUMENTS_TYPE = auto()

def get_document_type(doc_type_str):
    try:
        return DocumentType[doc_type_str.upper()]
    except KeyError:
        # Handle the case where the string doesn't match any enum member
        return None
    
'''
This file is responsible to perform post-processing on top of API responses.
'''
def build_documents_warehouse_properties_from_entities(entities, blob_name, file_number_confidence_threshold, documentType: DocumentType):
    '''
    This function post process the CDE response and
    creates a list of documents

    Args:
    doc_cde_json : json
                   Contains the CDE output response

    blob_name : string
                Contains the blob name

    file_number_confidence_threshold : float
                Contains the confidence threshold for file number

    Returns:
    documents : list
                Contains the list of documents

    '''
    return process_lrs_documents(entities, blob_name) if documentType == DocumentType.LRS_DOCUMENTS_TYPE else process_general_documents(entities, blob_name, file_number_confidence_threshold)
    
def process_lrs_documents(entities, blob_name):
    documentWarehouseProperties = DocumentWarehouseProperties()
    for item in entities.pb:
        if (item.type_ == "file_number"):
            documentWarehouseProperties.file_number = item.mention_text
        elif (item.type_ == "barcode_number"):
            documentWarehouseProperties.barcode_number = item.mention_text
        elif (item.type_ == "classification_code"):
            documentWarehouseProperties.classification_code = item.mention_text
        elif (item.type_ == "classification_level"):
            documentWarehouseProperties.classification_level = item.mention_text
        elif (item.type_ == "file_title"):
            documentWarehouseProperties.file_title = item.mention_text
        elif (item.type_ == "volume"):
            documentWarehouseProperties.volume = item.mention_text
        elif (item.type_ == "org_code"):
            documentWarehouseProperties.org_code = item.mention_text

    documentWarehouseProperties.display_name = (blob_name 
                                                if documentWarehouseProperties.volume is None or documentWarehouseProperties.file_number is None
                                                else documentWarehouseProperties.file_number + '_' + documentWarehouseProperties.volume.replace(" ", "").lower())

    documents = []
    documents.append(documentWarehouseProperties)
    return documents

def process_general_documents(entities, blob_name, file_number_confidence_threshold):
    file_number_confidence_score_dict = {}

    #bunch of numbers in documents often have nds before the actual number, its not file number
    nds_no_set = set()

    documentWithoutFileNumber = DocumentWarehouseProperties()
    
    company_name = None
    address = None
    for item in entities.pb:
        if (item.type_ == "file_no_1" or item.type_ == "file_no_2"):
            confidence = file_number_confidence_score_dict.get(item.mention_text, 0)
            if item.mention_text not in file_number_confidence_score_dict or confidence > file_number_confidence_score_dict[item.mention_text]:
                file_number_confidence_score_dict[item.mention_text] = item.confidence
        elif (item.type_ == "full_title"):
            documentWithoutFileNumber.file_title = item.mention_text
        elif (item.type_ == "volume"):
            documentWithoutFileNumber.volume = item.mention_text
        elif (item.type_ == "printed_date"):
            documentWithoutFileNumber.date = item.normalized_value.text if item.normalized_value is not None else item.mention_text
        elif (item.type_ == "company_name"):
            company_name = item.mention_text
        elif (item.type_ == "nds_no"):
            nds_no_set.add(item.mention_text)
        elif (item.type_ == "address"):
            address = item.mention_text

    # When we send generic docs to the processor not only we receive file_numbers that we want which are formatted 
    # as (9427-g38-8753) we also get some unwanted numbers formatted as (HN-7654 or DS-8773). 
    # In order to distinguish between the real file numbers and the unwanted numbers we have trained
    # the processor with WANTED labels (file_no_1 and file_no_2) and unwanted label of (nds_no). 
    # As a result we tell the processor that these numbers are not wanted and categorize them under a different label. 
    # Then during post-processing we detect the unwanted numbers and delete them, thus only getting the true file numbers.
    for nds_no in nds_no_set:
        file_number_confidence_score_dict.pop(nds_no, None)

    def process_roman_numbers_for_volume(volume):
        if volume is not None:
            parts = [part.strip() for part in volume.split('OF')]
            # translate to arabic if volume is represented as roman
            if (len(parts) == 2 and 
                is_roman_number(parts[0]) and
                is_roman_number(parts[1])):
                return roman_to_arabic(parts[0]) + ' OF ' + roman_to_arabic(parts[1])
            elif (len(parts) == 1 and 
                is_roman_number(parts[0])):
                return roman_to_arabic(parts[0])
            
    documentWithoutFileNumber.volume = process_roman_numbers_for_volume(documentWithoutFileNumber.volume)

    # add company_name to title if not already part of the title
    def update_file_title_with_company_name_and_address (document_file_title, company_name, address):
        if (document_file_title is None):
            document_file_title = ""

        if (company_name is not None and company_name not in document_file_title):
            new_file_title = document_file_title + " - " + company_name
        else:
            new_file_title = document_file_title

        if (address is not None and address not in document_file_title):
            new_file_title = new_file_title + " - " + address

        return new_file_title

    documentWithoutFileNumber.file_title = update_file_title_with_company_name_and_address(documentWithoutFileNumber.file_title, company_name, address)
    
    # if file_number exists and confidence score is above 0.7 then display_name will be the file_number,
    # if volume exists then display_name will be file_number concatenated with the volume.
    # otherwise display_name will be the file_name (blob_name)
    documents = []
    for file_number, confidence_score in file_number_confidence_score_dict.items():
        document = copy.deepcopy(documentWithoutFileNumber)
        document.file_number = file_number
        if (confidence_score > file_number_confidence_threshold):
            document.display_name = (file_number 
                                     if document.volume is None 
                                     else file_number + '_' + document.volume.replace(" ", "").lower())
        else:
            document.display_name = blob_name
        documents.append(document)

    # special case if we did not recognize any file_number
    if (len(documents) == 0):
        documentWithoutFileNumber.display_name = blob_name
        documents.append(documentWithoutFileNumber)

    return documents

def update_text_anchors(doc, doc_next, text_length):
    '''
    This function updates the text anchors and indexes of tokens, lines, paragraphs, blocks

    Args:
    doc : document proto object
          Contains the sync OCR output response

    doc_next: document proto object
          Contains the sync OCR output response except for first 10 pages

    Returns:
    doc : document proto object
          Contains the complete OCR response wrt overall document 
    '''
    for page in doc_next.pages:
        for token in page.tokens:
            token.layout.text_anchor.text_segments[0].start_index = token.layout.text_anchor.text_segments[0].start_index + text_length
            token.layout.text_anchor.text_segments[0].end_index = token.layout.text_anchor.text_segments[0].end_index + text_length
        for line in page.lines:
            line.layout.text_anchor.text_segments[0].start_index = line.layout.text_anchor.text_segments[0].start_index + text_length
            line.layout.text_anchor.text_segments[0].end_index = line.layout.text_anchor.text_segments[0].end_index + text_length
        for paragraph in page.paragraphs:
            paragraph.layout.text_anchor.text_segments[0].start_index = paragraph.layout.text_anchor.text_segments[0].start_index + text_length
            paragraph.layout.text_anchor.text_segments[0].end_index = paragraph.layout.text_anchor.text_segments[0].end_index + text_length
        for block in page.blocks:
            block.layout.text_anchor.text_segments[0].start_index = block.layout.text_anchor.text_segments[0].start_index + text_length
            block.layout.text_anchor.text_segments[0].end_index = block.layout.text_anchor.text_segments[0].end_index + text_length

    doc.pages.extend(doc_next.pages)
    doc.text = doc.text + "\n" + doc_next.text
    return doc