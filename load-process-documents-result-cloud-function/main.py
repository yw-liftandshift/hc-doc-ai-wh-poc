import logging
import sys
import functions_framework
from google.cloud import contentwarehouse
from load_process_documents_result import config

logging.basicConfig(stream=sys.stdout, level=config.LOG_LEVEL)

document_schema_client = contentwarehouse.DocumentSchemaServiceClient()

parent = document_schema_client.common_location_path(
    project="826217361546", location="us"
)

document_client = contentwarehouse.DocumentServiceClient()


@functions_framework.http
def main(request):
    process_documents_result = request.json

    for key, result in process_documents_result.items():
        if "barcode_number" not in result:
            continue

        barcode_number_property = contentwarehouse.Property(
            name="barcode_number",
            text_values=contentwarehouse.TextArray(values=[result["barcode_number"]]),
        )

        document = contentwarehouse.Document(
            display_name=result["display_name"],
            reference_id=result["display_name"],
            title=result["display_name"],
            document_schema_name="projects/826217361546/locations/us/documentSchemas/4ets3493q638g",
            raw_document_file_type=contentwarehouse.RawDocumentFileType.RAW_DOCUMENT_FILE_TYPE_PDF,
            raw_document_path=result["gcs_uri"],
            text_extraction_disabled=False,
            plain_text=result["text"],
            properties=[barcode_number_property],
        )

        create_document_request = contentwarehouse.CreateDocumentRequest(
            parent=parent,
            document=document,
            request_metadata=contentwarehouse.RequestMetadata(
                user_info=contentwarehouse.UserInfo(
                    id="user:docai-warehouse-ui-sa@hc-docai-warehouse-poc-003.iam.gserviceaccount.com"
                )
            ),
        )

        create_document_response = document_client.create_document(
            request=create_document_request
        )

    return {}
