import json
import logging
import pathlib
import sys
import functions_framework
from google.cloud import storage
from postprocess_lrs import config

logging.basicConfig(stream=sys.stdout, level=config.LOG_LEVEL)

storage_client = storage.Client(project=config.GOOGLE_CLOUD_PROJECT_ID)


@functions_framework.http
def main(request):
    lrs_processor_batch_response = request.json

    extracted_properties = []

    for individual_process_status in lrs_processor_batch_response["metadata"][
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
                properties = {}

                gcs_uri = individual_process_status["inputGcsSource"]

                original_file_name = gcs_uri.split("/")[-1]

                properties["original_file_name"] = original_file_name

                document_ai_classifier_response = json.loads(blob.download_as_string())

                entities = document_ai_classifier_response["entities"]

                for entity in entities:
                    entity_type = entity["type"]

                    if entity_type == "barcode_number":
                        properties["barcode_number"] = entity["mentionText"]
                    elif entity_type == "classification_code":
                        properties["classification_code"] = entity["mentionText"]
                    elif entity_type == "classification_level":
                        properties["classification_level"] = entity["mentionText"]
                    elif entity_type == "file_number":
                        properties["file_number"] = entity["mentionText"]
                        properties["new_file_name"] = entity["mentionText"]
                    elif entity_type == "file_title":
                        properties["file_title"] = entity["mentionText"]
                        original_file_name_extension = pathlib.Path(
                            original_file_name
                        ).suffix
                        properties[
                            "file_title"
                        ] = f"{properties['file_title']}{original_file_name_extension}"
                    elif entity_type == "org_code":
                        properties["org_code"] = entity["mentionText"]
                    elif entity_type == "volume":
                        properties["volume"] = entity["mentionText"]
                    else:
                        raise ValueError(
                            f"Unexpected entity type {entity_type} in blob {blob.name}"
                        )

                extracted_properties.append(properties)

    return extracted_properties
