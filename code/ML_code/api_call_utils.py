'''
This file has all the necessary api calls code which are required during
the complete process
'''
#importing libraries
from cf_config import property_set
from cf_config import env_var
from google.cloud import documentai_v1 as documentai
from google.cloud import contentwarehouse
from google.cloud import storage
import google.cloud.contentwarehouse_v1.types
from google.api_core.client_options import ClientOptions

def process_document_ocr(
    project_id: str, location: str, processor_id: str, file_path: str, mime_type: str
) -> documentai.Document:
    '''
    This function is used to invoke the DocOCR processor for sync requests

    Args:
    project_id : str
                 Contains the Project id

    location : str
               Contains the location of processor
    
    processor_id: str:
                  Contains the processor id

    file_path : str
                Contains the local file path of the file

    mime_type : str
                Contains the mime type of file(for pdf - application/pdf)

    Returns:
    result.document : Document proto object
                      Contains the DocOCR response
    '''
    # You must set the api_endpoint if you use a location other than 'us'.
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")

    client = documentai.DocumentProcessorServiceClient(client_options=opts)

    # The full resource name of the processor, e.g.:
    # projects/project_id/locations/location/processor/processor_id
    name = client.processor_path(project_id, location, processor_id)

    # Read the file into memory
    with open(file_path, "rb") as image:
        image_content = image.read()

    # Load Binary Data into Document AI RawDocument Object
    raw_document = documentai.RawDocument(content=image_content, mime_type=mime_type)

    # Configure the process request
    request = documentai.ProcessRequest(name=name, raw_document=raw_document)

    result = client.process_document(request=request)

    return result.document
    
def doc_warehouse_creation(project_number,
    location,
    doc,
    schema_id,
    display_name,
    gcs_input_uri,
    key_val_dict 
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
    document.display_name = display_name
    document.reference_id = display_name
    document.title = document.display_name
    document.document_schema_name = schema_id 
    document.raw_document_file_type = contentwarehouse.RawDocumentFileType.RAW_DOCUMENT_FILE_TYPE_PDF
    document.raw_document_path = gcs_input_uri
    document.text_extraction_disabled = False
    document.plain_text= doc.text
    document.cloud_ai_document = doc._pb
    document = property_set(document, key_val_dict)
    load_request = contentwarehouse.CreateDocumentRequest()
    load_request.parent = f"projects/{project_number}/locations/{location}"
    load_request.document = document
    request_metadata = contentwarehouse.RequestMetadata()
    request_metadata.user_info = contentwarehouse.UserInfo()
    request_metadata.user_info.id = env_var["sa_user"]
    load_request.request_metadata = request_metadata
    document_client = contentwarehouse.DocumentServiceClient()
    load_resp = document_client.create_document(request=load_request)
    
def process_document_sample_cde(
        project_id: str,
        location: str,
        processor_id: str,
        file_path: str,
        mime_type: str,
        field_mask: str = None,
):
    '''
    This function is used to invoke the CDE processor.

    Args:
    project_id : str
                 Contains the Project id

    location : str
               Contains the location of processor
    
    processor_id: str:
                  Contains the processor id

    file_path : str
                Contains the local file path of the file

    mime_type : str
                Contains the mime type of file(for pdf - application/pdf)

    Returns:
    document : Document proto object
               Contains the CDE response
    '''
    # You must set the api_endpoint if you use a location other than 'us', e.g.:
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")
    client = documentai.DocumentProcessorServiceClient(client_options=opts)
    # The full resource name of the processor, e.g.:
    # projects/{project_id}/locations/{location}/processors/{processor_id}
    name = client.processor_path(project_id, location, processor_id)

    # Read the file into memory
    with open(file_path, "rb") as image:
        image_content = image.read()

    # Load Binary Data into Document AI RawDocument Object
    raw_document = documentai.RawDocument(content=image_content, mime_type=mime_type)

    # Configure the process request
    request = documentai.ProcessRequest(
        name=name, raw_document=raw_document, field_mask=field_mask
    )

    result = client.process_document(request=request)
    document = result.document

    # Read the text recognition output from the processor
    return document