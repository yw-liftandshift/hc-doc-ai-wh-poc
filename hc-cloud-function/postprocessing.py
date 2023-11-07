from enum import Enum, auto
import copy
from cf_config import DocumentWarehouseProperties

'''
This file is responsible to perform post-processing on top of API responses.
'''
def build_documents_warehouse_properties_from_entities(entities, blob_name, file_number_confidence_threshold):
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
    file_number_confidence_score_dict = {}

    documentWithoutFileNumber = DocumentWarehouseProperties()
    
    #Post-Process the cde response
    for item in entities.pb:
        if (item.type_ == "file-no" or item.type_ == "file_number"):
            file_number_confidence_score_dict[item.mention_text] = item.confidence
            continue
        if (item.type_ == "barcode_number"):
            documentWithoutFileNumber.barcode_number = item.mention_text
            continue        
        if (item.type_ == "classification_code"):
            documentWithoutFileNumber.classification_code = item.mention_text
            continue
        if (item.type_ == "classification_level"):
            documentWithoutFileNumber.classification_level = item.mention_text
            continue
        if (item.type_ == "file_title" or item.type_ == "full_title"):
            documentWithoutFileNumber.file_title = item.mention_text
            continue
        if (item.type_ == "volume"):
            documentWithoutFileNumber.volume = item.mention_text
            continue
        if (item.type_ == "org_code"):
            documentWithoutFileNumber.org_code = item.mention_text
            continue
        if (item.type_ == "printed_date"):
            documentWithoutFileNumber.date = item.normalized_value.text if item.normalized_value is not None else item.mention_text
            continue
    
    # if file_number exists and confidence score is above 0.7 then display_name will be the file_number,
    # if volume exists then display_name will be file_number concatenated with the volume.
    # otherwise display_name will be the file_name (blob_name)
    documents = []
    for file_number, confidence_score in file_number_confidence_score_dict.items():
        document = copy.deepcopy(documentWithoutFileNumber)
        document.file_number = file_number
        if (confidence_score > file_number_confidence_threshold):
            document.display_name = file_number if document.volume is None else file_number + '_' + document.volume.replace(" ", "").lower()
        else:
            document.display_name = blob_name + file_number
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

class DocumentType(Enum):
    LRS_DOCUMENTS_TYPE = auto()
    GENERAL_DOCUMENTS_TYPE = auto()

def get_document_type(doc_type_str):
    try:
        return DocumentType[doc_type_str.upper()]
    except KeyError:
        # Handle the case where the string doesn't match any enum member
        return None