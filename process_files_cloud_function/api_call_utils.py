'''
This file has all the necessary api calls code which are required during
the complete process
'''
# importing libraries
from google.cloud import documentai_v1 as documentai
from google.cloud import contentwarehouse
from google.api_core.client_options import ClientOptions
from google.cloud import storage
import google.cloud.logging
import logging

class DocumentWarehouseProperties:
    '''
    This class contains the properties of DocAI Warehouse
    '''
    def __init__(self, file_title = None, file_number = None, barcode_number = None, org_code=None, date=None, classification_code=None, classification_level=None, volume=None):
        
        self.barcode_number = barcode_number
        self.classification_code = classification_code
        self.classification_level = classification_level
        self.file_number = file_number
        self.file_title = file_title
        self.org_code = org_code
        self.volume = volume
        self.date = date
        self.display_name = None #not a part of DocumentWarehouse schema, contains display name
    
    def __eq__(self, other):
        if not isinstance(other, DocumentWarehouseProperties):
            return False
        return (
            self.barcode_number == other.barcode_number
            and self.classification_code == other.classification_code
            and self.classification_level == other.classification_level
            and self.file_number == other.file_number
            and self.file_title == other.file_title
            and self.org_code == other.org_code
            and self.volume == other.volume
            and self.date == other.date
            and self.display_name == other.display_name
        )
    '''
    Returns:
    props : list
            List of properties to be set in DocumentWarehouse
    '''
    def to_documentai_property(self):
        props = []
        for field, value in vars(self).items():
            if value is not None and field != 'display_name':
                prop = contentwarehouse.Property()
                prop.name = field
                prop.text_values.values = value if isinstance(value, list) else [value]
                props.append(prop)
        return props

def process_document_ocr(project_id: str, location: str, processor_id: str, raw_document: documentai.RawDocument) -> documentai.Document:
    '''
    This function invoke OCR processor in online mode over all document pages multiple times
    to extract entities.

    Args:
    project_id: str
                Contains the project id

    location: str
              Contains the location of processor

    processor_id: str
                  Contains the processor id

    raw_document: RawDocument
                  Contains the raw document object

    Returns:
    document_object : Document proto object
                      Contains the CDE response
    '''
    # Instantiates a client
    docai_client = documentai.DocumentProcessorServiceClient(
        client_options=ClientOptions(
            api_endpoint=f"{location}-documentai.googleapis.com")
    )

    RESOURCE_NAME = docai_client.processor_path(
        project_id, location, processor_id)
    
    process_options = documentai.ProcessOptions(
        # Process only specific pages
        from_end = 1
    )

    # Configure the process request
    request = documentai.ProcessRequest(
        name=RESOURCE_NAME, raw_document=raw_document, process_options=process_options)

    # Use the Document AI client to process the sample form
    result = docai_client.process_document(request=request)

    last_page_document_object = result.document

    last_page_number = last_page_document_object.pages[0].page_number

    # corner case: one page document
    if last_page_number == 1:
        return last_page_document_object


    PAGES_PER_BATCH = 15  # online processing support up to 15 pages
    starting_page = 1
    previous_document_object = None # used to concatenate document objects returned by OCR
    while (last_page_number > starting_page):
        pages_to_scan = list(
            range(starting_page, starting_page + PAGES_PER_BATCH))
        starting_page = starting_page + PAGES_PER_BATCH

        process_options = documentai.ProcessOptions(
            # Process only specific pages
            individual_page_selector=documentai.ProcessOptions.IndividualPageSelector(
                pages=pages_to_scan
            )
        )

        # Configure the process request
        request = documentai.ProcessRequest(
            name=RESOURCE_NAME, raw_document=raw_document, process_options=process_options)

        # Use the Document AI client to process the sample form
        result = docai_client.process_document(request=request)

        document_object = result.document

        if previous_document_object is not None:
            previous_document_object.pages.extend(document_object.pages)
            previous_document_object.text = previous_document_object.text + \
                "\n" + document_object.text
        else:
            previous_document_object = document_object

    return previous_document_object

def doc_warehouse_creation(project_number: str,
                           location: str,
                           doc: documentai.Document,
                           schema_id: str,
                           gcs_input_uri: str,
                           documentProperties: DocumentWarehouseProperties,
                           service_account_user_id: str
                           ):
    '''
    This function is used to initialize and set properties for DocAI Warehouse.

    Args:
    location : str
               Contains the location of processor

    doc : Document proto object
          Contains the document response of CDE

    schema_id : str
                Contains the predefined schema id

    gcs_input_uri : str
                    Contains the gs path of the file

    key_val_dict : dict
                   Contains the key value dictionary    
    '''
    document = contentwarehouse.Document()
    document.display_name = documentProperties.display_name
    document.reference_id = documentProperties.display_name
    document.title = documentProperties.display_name
    document.document_schema_name = schema_id
    document.raw_document_file_type = contentwarehouse.RawDocumentFileType.RAW_DOCUMENT_FILE_TYPE_PDF
    document.raw_document_path = gcs_input_uri
    document.text_extraction_disabled = False
    document.plain_text = doc.text
    document.cloud_ai_document = doc._pb
    for prop in documentProperties.to_documentai_property():
        document.properties.append(prop)
    load_request = contentwarehouse.CreateDocumentRequest()
    load_request.parent = f"projects/{project_number}/locations/{location}"
    load_request.document = document
    request_metadata = contentwarehouse.RequestMetadata()
    request_metadata.user_info = contentwarehouse.UserInfo()
    request_metadata.user_info.id = service_account_user_id
    load_request.request_metadata = request_metadata
    document_client = contentwarehouse.DocumentServiceClient()
    document_client.create_document(request=load_request)

def process_document_and_extract_entities(
    project_id: str,
    location: str,
    processor_id: str,
    raw_document: documentai.RawDocument,
    gcs_input_uri: str
) -> documentai.Document:
    '''
    This function is used to invoke the CDE processor and return entities.

    Args:
    project_id : str
                 Contains the Project id

    location : str
               Contains the location of processor

    processor_id: str:
                  Contains the processor id

    file_path : str
                Contains the local file path of the file

    Returns:
    document : Document proto object
               Contains the CDE response
    '''
    # You must set the `api_endpoint`if you use a location other than "us".
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")

    client = documentai.DocumentProcessorServiceClient(client_options=opts)

    # if processorVersions is None else client.processor_version_path(project_id, location, processor_id, processorVersions)
    name = client.processor_path(project_id, location, processor_id)

    process_options = documentai.ProcessOptions(
        # Process only first page
        individual_page_selector=documentai.ProcessOptions.IndividualPageSelector(
            pages=[1]
        )
    )

    # Configure the process request
    request = documentai.ProcessRequest(
        name=name,
        raw_document=raw_document,
        field_mask="entities",
        process_options=process_options,
    )


    processor_result = client.get_processor(name=name)
    processor_version_result = client.get_processor_version(name=processor_result.default_processor_version)


    result = client.process_document(request=request)

    __logEntries(result.document.entities, file_name = gcs_input_uri, model_version = processor_version_result.name, model_name = processor_version_result.display_name)
    # We are interested only in entities
    return result.document.entities

def __logEntries(recognized_entities, file_name = None, model_name = None, model_version = None):
    '''
    This function is used to log the entries.
    '''
    client = google.cloud.logging.Client()
    client.setup_logging(log_level=logging.DEBUG)
    logger = client.logger(name="recognition_result")

    entities = {}
    for item in recognized_entities.pb:
        entities[item.type_] = {"value": item.mention_text, "confidence": item.confidence}
    
    data = {}
    data["entities"] = entities
    data["filename"] = file_name
    data["model_name"] = model_name
    data["model_version"] = model_version

    logger.log_struct(data)


def get_file_from_cloud_storage_as_raw_document(bucket_name: str, object_name: str, mime_type="application/pdf") -> documentai.RawDocument:
    '''
    This function is used to get the file from cloud returning it as RawDocument object.

    Args:
    bucket_name : str
                  Contains the bucket name

    object_name : str
                  Contains the object name

    mime_type : str
                Contains the mime type of the file
    '''
    storage_client = storage.Client()

    # Get the bucket
    bucket = storage_client.bucket(bucket_name)

    # Get the object
    object = bucket.blob(object_name)

    # Download the object's contents to a buffer in memory
    buffer = object.download_as_bytes()

    # Load Binary Data into Document AI RawDocument Object
    raw_document = documentai.RawDocument(content=buffer, mime_type=mime_type)

    return raw_document