from google.cloud import contentwarehouse
from google.cloud import documentai_v1 as documentai
from google.cloud import storage
import google.cloud.contentwarehouse_v1.types
from google.api_core.client_options import ClientOptions
from config import *

def batch_process_docs(
    project_id,
    location,
    processor_id,
    gcs_input_uri,
    gcs_output_uri,
    gcs_output_uri_prefix,
    timeout: int = 300
):
    
    # Initiate Client
    client = documentai.DocumentProcessorServiceClient()
    
    # Output path
    destination_uri = f"{gcs_output_uri}/{gcs_output_uri_prefix}/"
    
    # Processor path
    name = client.processor_path(project_id, location, processor_id)
    
    # Input document
    gcs_documents = documentai.GcsDocuments(
        documents=[{"gcs_uri": gcs_input_uri, "mime_type": "application/pdf"}]
    )
    
    input_config = documentai.BatchDocumentsInputConfig(gcs_documents=gcs_documents)
    
    # Where to write results
    output_config = documentai.DocumentOutputConfig(
        gcs_output_config={"gcs_uri": destination_uri}
    )
    
    request = documentai.types.document_processor_service.BatchProcessRequest(
        name=name,
        input_documents=input_config,
        document_output_config=output_config,
    )

    operation = client.batch_process_documents(request)

    # Wait for the operation to finish
    operation.result(timeout=timeout) 
    
    try:
        print(f"Waiting for operation {operation.operation.name} to complete...")
        operation.result(timeout=timeout)
    # Catch exception when operation doesn't finish before timeout
    except (RetryError, InternalServerError) as e:
        print(e.message)
        
    storage_client = storage.Client()
    operation_id = str(operation.operation.name).split('/')[-1]
    gcs_output_uri_prefix = gcs_output_uri_prefix + "/" + operation_id
    output_blobs = storage_client.list_blobs("hcwarehouse-pdf-storage", prefix=gcs_output_uri_prefix)
    for blob in output_blobs:
        print(blob.name)
        if ".json" not in blob.name:
            print(f"skipping non-supported file: {blob.name} - Mimetype: {blob.content_type}")
            continue
        document = documentai.Document.from_json(
                blob.download_as_bytes(), ignore_unknown_fields=True
            )
        return document

#Sync dococr calls
def process_document_ocr(
    project_id: str, location: str, processor_id: str, file_path: str, mime_type: str
) -> documentai.Document:
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
    

#Document AI warehouse
def doc_creation(project_number,
    location,
    doc,
    schema_id,
    display_name,
    gcs_input_uri,
    key_val_dict    #TO-DO
    ):
    nested_prop_sc = schema_id
    document = contentwarehouse.Document()
    document.display_name = display_name
    document.reference_id = display_name
    document.title = document.display_name
    document.document_schema_name = nested_prop_sc 
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
    request_metadata.user_info.id = sa_user
    load_request.request_metadata = request_metadata
    
    document_client = contentwarehouse.DocumentServiceClient()
    load_resp = document_client.create_document(request=load_request)
    
    
#CDE calls
def process_document_sample_cde(
        project_id: str,
        location: str,
        processor_id: str,
        file_path: str,
        mime_type: str,
        field_mask: str = None,
):

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


    

    
    


