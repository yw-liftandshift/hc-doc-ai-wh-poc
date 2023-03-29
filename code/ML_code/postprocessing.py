def ocr_postprocess(doc_cde_json):
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
    key_val_dict = {}
    for entity in doc_cde_json["entities"]:
        key, value = entity["type"], entity["mentionText"]
        key_val_dict[key] = value
        
    return key_val_dict

def update_text_anchors(doc, doc1, text_length):
    '''
    This function post process the CDE response and
    creates a key value pair dictionary out of it

    Args:
    doc : document proto object
          Contains the sync OCR output response

    doc1: document proto object
          Contains the sync OCR output response

    Returns:
    doc : document proto object
          Contains the complete OCR response wrt overall document 
    '''
    for page in doc1.pages:
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

    doc.pages.extend(doc1.pages)
    doc.text = doc.text + "\n" + doc1.text
    return doc
    