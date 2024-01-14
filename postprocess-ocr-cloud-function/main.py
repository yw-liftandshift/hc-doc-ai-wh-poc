import json
import logging
import sys
import functions_framework
from google.cloud import storage
from postprocess_ocr import config

logging.basicConfig(stream=sys.stdout, level=config.LOG_LEVEL)

storage_client = storage.Client(project=config.GOOGLE_CLOUD_PROJECT_ID)


@functions_framework.http
def main(request):
    ocr_processor_batch_response = request.json

    extracted_properties = {}

    for individual_process_status in ocr_processor_batch_response["metadata"][
        "individualProcessStatuses"
    ]:
        output_gcs_destination = individual_process_status["outputGcsDestination"]

        output_gcs_destination_split = output_gcs_destination.split("/", 3)

        bucket_name, folder_name = (
            output_gcs_destination_split[2],
            output_gcs_destination_split[3],
        )

        blobs = storage_client.list_blobs(
            bucket_or_name=bucket_name, prefix=folder_name
        )

        for blob in blobs:
            if blob.name.endswith(".json"):
                gcs_uri = individual_process_status["inputGcsSource"]

                blob_file_name = gcs_uri.split("/")[-1]

                extracted_properties[blob_file_name] = {}

                document_ai_classifier_response = json.loads(blob.download_as_string())

                extracted_properties[blob_file_name][
                    "gcs_uri"
                ] = gcs_uri

                extracted_properties[blob_file_name][
                    "content_type"
                ] = blob.content_type

                extracted_properties[blob_file_name][
                    "text"
                ] = document_ai_classifier_response["text"]

    return extracted_properties
