import io
import json
from typing import Optional
from sqlalchemy.orm.exc import NoResultFound
from google.cloud import pubsub_v1, storage
from backend.db import db
from backend.exceptions import NotFoundException
from backend.documents.models import Batch, BatchStatus, Document


class DocumentsService:
    def __init__(
        self,
        project_id: str,
        pubsub_publisher_client: pubsub_v1.PublisherClient,
        process_documents_workflow_pubsub_topic: str,
        storage_client: storage.Client,
        google_cloud_storage_documents_bucket: str,
    ):
        self.__pubsub_publisher_client = pubsub_publisher_client
        self.__process_documents_workflow_pubsub_topic_path = (
            self.__pubsub_publisher_client.topic_path(
                project_id, process_documents_workflow_pubsub_topic
            )
        )
        self.__storage_client = storage_client
        self.__google_cloud_storage_documents_bucket = (
            google_cloud_storage_documents_bucket
        )

    def create_batch(self) -> Batch:
        batch = Batch(
            google_cloud_storage_bucket_name=self.__google_cloud_storage_documents_bucket
        )

        db.session.add(batch)

        db.session.commit()

        return batch

    def process_batch(self, batch_id: str):
        try:
            batch = db.session.get_one(Batch, batch_id)
        except NoResultFound:
            raise NotFoundException(f"Batch {batch_id} not found")

        self.__pubsub_publisher_client.publish(
            self.__process_documents_workflow_pubsub_topic_path,
            data=json.dumps(
                {
                    "batch_id": str(batch.id),
                }
            ).encode(),
        )

        batch.status = BatchStatus.PROCESSING

        db.session.commit()

        return batch

    def create_document(
        self,
        batch_id: str,
        file_name: str,
        file_obj: io.BytesIO,
        content_type: Optional[str],
    ) -> Document:
        try:
            batch = db.session.get_one(Batch, batch_id)
        except NoResultFound:
            raise NotFoundException(f"Batch {batch_id} not found")

        google_cloud_storage_blob_name = f"{batch_id}/{file_name}"

        google_cloud_storage_bucket = self.__storage_client.bucket(
            batch.google_cloud_storage_bucket_name
        )

        google_cloud_storage_blob = google_cloud_storage_bucket.blob(
            google_cloud_storage_blob_name
        )

        google_cloud_storage_blob.upload_from_file(file_obj, content_type=content_type)

        document = Document(
            batch_id=batch_id,
            google_cloud_storage_blob_name=google_cloud_storage_blob_name,
        )

        db.session.add(document)

        db.session.commit()

        return document
