import logging
import sys
import functions_framework
from google.cloud import storage
from extract_pdf_first_page import config, extract_pdf_first_page

logging.basicConfig(stream=sys.stdout, level=config.LOG_LEVEL)

storage_client = storage.Client(project=config.GOOGLE_CLOUD_PROJECT_ID)


@functions_framework.http
def main(request):
    input_google_cloud_storage_bucket = request.json["google_cloud_storage"]["bucket"]

    input_google_cloud_storage_folder = request.json["google_cloud_storage"]["folder"]

    blobs = storage_client.list_blobs(
        bucket_or_name=input_google_cloud_storage_bucket,
        prefix=f"{input_google_cloud_storage_folder}/",
        delimiter="/",
    )

    for blob in blobs:
        if blob.content_type != "application/pdf":
            raise ValueError(f"File {blob.name} is not a PDF file.")

        pdf_content = blob.download_as_bytes()

        pdf_first_page = extract_pdf_first_page(pdf_content=pdf_content)

        blob_file_name = blob.name.split("/")[-1]

        blob_name = f"{config.GOOGLE_CLOUD_STORAGE_OUTPUT_FOLDER}/{blob_file_name}"

        output_bucket = storage_client.bucket(
            bucket_name=config.GOOGLE_CLOUD_STORAGE_OUTPUT_BUCKET
        )
        output_blob = output_bucket.blob(blob_name)
        output_blob.upload_from_file(pdf_first_page, content_type="application/pdf")

    return {}
