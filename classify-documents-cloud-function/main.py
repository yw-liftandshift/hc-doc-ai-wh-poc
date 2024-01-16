import json
import logging
import sys
import functions_framework
from google.cloud import storage
from classify_documents import config

logging.basicConfig(stream=sys.stdout, level=config.LOG_LEVEL)

storage_client = storage.Client(project=config.GOOGLE_CLOUD_PROJECT_ID)


@functions_framework.http
def main(request):
    document_ai_classifier_batch_response = request.json

    lrs_documents = []
    general_documents = []

    for individual_process_status in document_ai_classifier_batch_response["metadata"][
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
                document_ai_classifier_response = json.loads(blob.download_as_string())

                entities = document_ai_classifier_response["entities"]

                max_confidence_entity = max(entities, key=lambda e: e["confidence"])

                gcs_uri = individual_process_status["inputGcsSource"]

                gcs_uri_split = gcs_uri.split("/", 3)

                gcs_uri_bucket_name, gcs_uri_blob_name = (
                    gcs_uri_split[2],
                    gcs_uri_split[3],
                )

                gcs_uri_blob = storage_client.bucket(
                    bucket_name=gcs_uri_bucket_name
                ).get_blob(gcs_uri_blob_name)

                gcs_document = {
                    "gcsUri": gcs_uri,
                    "mimeType": gcs_uri_blob.content_type,
                }

                if max_confidence_entity["type"] == "lrs_documents_type":
                    lrs_documents.append(gcs_document)
                else:
                    general_documents.append(gcs_document)

    return {"lrs": lrs_documents, "general": general_documents}
