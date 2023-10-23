from enum import Enum, auto

'''
This file is responsible to perform post-processing on top of API responses.
'''
def build_dictionary_from_entities(entities):
    '''
    This function post process the CDE response and
    creates a key value pair dictionary out of it

    Args:
    doc_cde_json : json
                   Contains the CDE output response

    Returns:
    key_val_dict : dict
                   key value pair dictionary 
    '''
    # TODO: we have dependency on different schema, pass it from variables or make schemas compatible
    schema_map = {"file_no": "file_number",
                  "full_title": "file_title",
                  "printed_date": "date"}

    key_val_dict = {}
    # #Post-Process the cde response
    # key_val_dict = ocr_postprocess(doc_cde_json)
    for item in entities.pb:
        print(item.type_)
        print(item.mention_text)
        schema_key = schema_map.get(item.type_) if schema_map.get(item.type_) else item.type_
        key_val_dict[schema_key] = item.mention_text
        
    return key_val_dict

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