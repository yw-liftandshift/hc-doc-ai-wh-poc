from enum import Enum, auto
import re

'''
This file is responsible to perform post-processing on top of API responses.
'''
def build_dictionary_and_filename_from_entities(entities, blob_name, file_number_confidence_threshold):
    '''
    This function post process the CDE response and
    creates a key value pair dictionary and chose provide file name based on confidence score

    Args:
    doc_cde_json : json
                   Contains the CDE output response

    blob_name : string
                Contains the blob name

    Returns:
    key_val_dict : dictionary
                   Contains the key value pair dictionary

    display_name : string
                   Contains the file name
    '''
    # TODO: we have dependency on different schema, pass it from variables or make schemas compatible
    schema_map = {"file_no": "file_number",
                  "full_title": "file_title",
                  "printed_date": "date"}

    key_val_dict = {}
    file_number_confidence_score = 0
    #Post-Process the cde response
    for item in entities.pb:
        schema_key = schema_map[item.type_] if item.type_ in schema_map else item.type_
        key_val_dict[schema_key] = item.mention_text
        if schema_key == "file_number":
            file_number_confidence_score = item.confidence
    
    # if file_number exists and confidence score is above 0.7 then display_name will be the file_number,
    # if volume exists then display_name will be file_number concatenated with the volume.
    # otherwise display_name will be the file_name (blob_name)
    if ("file_number" in key_val_dict and file_number_confidence_score > file_number_confidence_threshold):
        display_name = key_val_dict["file_number"]
        if ("volume" in key_val_dict):
            display_name = key_val_dict["file_number"] +'_'+ re.sub(r"\s", "", key_val_dict['volume']).lower()
    else:
        display_name = blob_name

    return [key_val_dict, display_name]

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