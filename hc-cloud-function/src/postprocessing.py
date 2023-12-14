import re
from enum import Enum, auto
from cf_config import DocumentWarehouseProperties
from roman_to_arabic import roman_to_arabic, is_roman_number


class DocumentType(Enum):
    LRS_DOCUMENTS_TYPE = auto()
    GENERAL_DOCUMENTS_TYPE = auto()


class FilenameFlags(Enum):
    ATT_FN = "ATT_FN_"

def get_document_type(doc_type_str):
    try:
        return DocumentType[doc_type_str.upper()]
    except KeyError:
        # Handle the case where the string doesn't match any enum member
        return None


'''
This file is responsible to perform post-processing on top of API responses.
'''


def build_documents_warehouse_properties_from_entities(entities, blob_name, documentType: DocumentType):
    '''
    This function post process the CDE response and
    creates a list of DocumentWarehouseProperties


    Args:
    doc_cde_json : json
                   Contains the CDE output response

    blob_name : string
                Contains the blob name

    documentType : DocumentType
                   Contains the document type

    Returns:
        List of DocumentWarehouseProperties

    '''
    return process_lrs_documents(entities, blob_name) if documentType == DocumentType.LRS_DOCUMENTS_TYPE else process_general_documents(entities, blob_name)


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


def process_general_documents(entities, blob_name):
    file_number_set = set()

    document = DocumentWarehouseProperties()

    company_name = None
    address = None
    for item in entities.pb:
        if item.type_ == "file_no":
            file_number_set.add(item.mention_text)
        elif (item.type_ == "full_title"):
            document.file_title = item.mention_text
        elif (item.type_ == "volume"):
            document.volume = item.mention_text
        elif (item.type_ == "printed_date"):
            document.date = item.normalized_value.text if item.normalized_value is not None else item.mention_text
        elif (item.type_ == "company_name"):
            company_name = item.mention_text
        elif (item.type_ == "address"):
            address = item.mention_text


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
            return volume

    document.volume = process_roman_numbers_for_volume(
        document.volume)

    def process_date(date):
        if date is not None:
            if re.match(r'^\d{4}$', date):
                # If the text matches the pattern (YYYY), do something
                return date + "-00-00"
            elif re.match(r'^\d{4}-\d{2}$', date):
                # If the text matches the pattern (YYYY-MM), append "-0" to the end
                return date + "-00"
            else:
                # If the text doesn't match the pattern, use the original text
                return date

    document.date = process_date(
        document.date)

    # add company_name to title if not already part of the title
    def update_file_title_with_company_name_and_address(document_file_title, company_name, address):
        if (document_file_title is None):
            document_file_title = ""

        if (company_name is not None and company_name not in document_file_title):
            new_file_title = document_file_title + " - " + company_name
        else:
            new_file_title = document_file_title

        if (address is not None and address not in document_file_title):
            new_file_title = new_file_title + " - " + address

        return new_file_title

    document.file_title = update_file_title_with_company_name_and_address(
        document.file_title, company_name, address)


    document.file_number = list(file_number_set)

    # if we have more than one file number than we have to add flag ATT_FN
    if len(document.file_number) > 1:
        document.display_name = FilenameFlags.ATT_FN.value + blob_name
    else:
        document.display_name = blob_name

    return document
