import click
import google.cloud.documentai_v1beta3 as docai_v1beta3
from google.api_core.client_options import ClientOptions


@click.command()
@click.option("--project-id", help="The Google Cloud Project ID.")
@click.option("--location", help=" The location of the resource of the processor.")
@click.option("--processor-name", help="The resource name of the processor.")
@click.option("--processor-version-display-name", help="The display name.")
@click.option("--train-data-uri", help="The train data GCS URI.")
@click.option("--test-data-uri", help="The train data GCS URI.")
@click.option(
    "--timeout",
    help="Timeout in seconds for getting the result of the processor training operation.",
)
def train_processor_version(
    project_id: str,
    location: str,
    processor_name: str,
    processor_version_display_name: str,
    train_data_uri: str,
    test_data_uri: str,
    timeout: str,
):
    timeout_int = int(timeout)

    # You must set the api_endpoint if you use a location other than 'us', e.g.:
    opts = ClientOptions(api_endpoint=f"{location}-documentai.googleapis.com")

    client = docai_v1beta3.DocumentProcessorServiceClient(client_options=opts)

    # The full resource name of the processor
    # e.g. `projects/{project_id}/locations/{location}/processors/{processor_name}
    parent = client.processor_path(project_id, location, processor_name)

    processor_version = docai_v1beta3.ProcessorVersion(
        display_name=processor_version_display_name
    )

    # If train/test data is not supplied, the default sets in the Cloud Console will be used
    input_data = docai_v1beta3.types.TrainProcessorVersionRequest.InputData(
        training_documents=docai_v1beta3.BatchDocumentsInputConfig(
            gcs_prefix=docai_v1beta3.types.GcsPrefix(gcs_uri_prefix=train_data_uri)
        ),
        test_documents=docai_v1beta3.BatchDocumentsInputConfig(
            gcs_prefix=docai_v1beta3.types.GcsPrefix(gcs_uri_prefix=test_data_uri)
        ),
    )

    json_schema = """{
        "displayName": "all-entity-document-schema",
        "description": "Document schema for purchase order processor.",
        "entityTypes": [{
            "name": "custom_extraction_document_type",
            "baseTypes": ["document"],
            "properties": [{
                "name": "barcode_number",
                "valueType": "string",
                "occurrenceType": 1
            }, 
            {
                "name": "classification_code",
                "valueType": "string",
                "occurrenceType": 1
            },
            {
                "name": "classification_level",
                "valueType": "string",
                "occurrenceType": 1
            },
            {
                "name": "file_number",
                "valueType": "string",
                "occurrenceType": 1
            },
            {
                "name": "org_code",
                "valueType": "string",
                "occurrenceType": 1
            },
            {
                "name": "volume",
                "valueType": "string",
                "occurrenceType": 1
            }]
        }]
    }"""

    document_schema = docai_v1beta3.types.DocumentSchema.from_json(json_schema)

    request = docai_v1beta3.TrainProcessorVersionRequest(
        parent=parent,
        processor_version=processor_version,
        input_data=input_data,
        document_schema=document_schema,
    )

    operation = client.train_processor_version(request=request)
    # Print operation details
    print(operation.operation.name)
    # Wait for operation to complete
    response = docai_v1beta3.TrainProcessorVersionResponse(
        operation.result(timeout=timeout_int)
    )

    metadata = docai_v1beta3.TrainProcessorVersionMetadata(operation.metadata)

    print(f"New Processor Version:{response.processor_version}")
    print(f"Training Set Validation: {metadata.training_dataset_validation}")
    print(f"Test Set Validation: {metadata.test_dataset_validation}")
