import io
from typing import Optional
from sqlalchemy.orm.exc import NoResultFound
from google.cloud import storage
from backend.db import db
from backend.exceptions import NotFoundException
from backend.documents.models import Batch, BatchStatus, Document


class DocumentsService:
    def __init__(self, storage_client: storage.Client):
        self.__storage_client = storage_client

    def create_batch(self) -> Batch:
        batch = Batch()

        db.session.add(batch)

        db.session.commit()

        return batch

    def process_batch(self, batch_id: str):
        try:
            batch = db.session.get_one(Batch, batch_id)
        except NoResultFound:
            raise NotFoundException(f"Batch {batch_id} not found")

        batch.status = BatchStatus.PROCESSING

        db.session.commit()

        return batch

    def create_document(
        self,
        batch_id: str,
        google_cloud_storage_bucket_name: str,
        file_name: str,
        file_obj: io.BytesIO,
        content_type: Optional[str],
    ) -> Document:
        google_cloud_storage_blob_name = f"{batch_id}/{file_name}"

        google_cloud_storage_bucket = self.__storage_client.bucket(
            google_cloud_storage_bucket_name
        )

        google_cloud_storage_blob = google_cloud_storage_bucket.blob(
            google_cloud_storage_blob_name
        )

        google_cloud_storage_blob.upload_from_file(file_obj, content_type=content_type)

        document = Document(
            batch_id=batch_id,
            google_cloud_storage_bucket_name=google_cloud_storage_bucket_name,
            google_cloud_storage_blob_name=google_cloud_storage_blob_name,
        )

        db.session.add(document)

        db.session.commit()

        return document
