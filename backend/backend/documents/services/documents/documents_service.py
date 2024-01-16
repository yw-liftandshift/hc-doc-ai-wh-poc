import io
import json
import uuid
import sqlalchemy
from typing import List, Optional
from sqlalchemy.orm.exc import NoResultFound
from google.cloud import bigquery, pubsub_v1, storage
from backend.db import db
from backend.exceptions import NotFoundException
from backend.documents.models import Batch, BatchStatus, Document


class DocumentsService:
    def __init__(
        self,
        project_id: str,
        bigquery_client: bigquery.Client,
        bigquery_documents_table: str,
        pubsub_publisher_client: pubsub_v1.PublisherClient,
        process_documents_workflow_pubsub_topic: str,
        storage_client: storage.Client,
        google_cloud_storage_documents_bucket: str,
    ):
        self.__bigquery_client = bigquery_client
        self.__bigquery_documents_table = bigquery_documents_table
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

    def process_batch(self, batch_id: str) -> Batch:
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
        content_type: str,
    ) -> Document:
        try:
            batch = db.session.get_one(Batch, batch_id)
        except NoResultFound:
            raise NotFoundException(f"Batch {batch_id} not found")

        document = Document(
            id=uuid.uuid4(),
            batch_id=batch_id,
            display_name=file_name,
            content_type=content_type,
        )

        google_cloud_storage_bucket = self.__storage_client.bucket(
            bucket_name=batch.google_cloud_storage_bucket_name
        )

        google_cloud_storage_blob = google_cloud_storage_bucket.blob(
            blob_name=self.__make_blob_name(document=document)
        )

        google_cloud_storage_blob.upload_from_file(file_obj, content_type=content_type)

        db.session.add(document)

        db.session.commit()

        return document

    def list_documents(
        self,
        batch_id: Optional[str],
        barcode_number: Optional[str],
        classification_code: Optional[str],
        classification_level: Optional[str],
        display_name: Optional[str],
        file_number: Optional[str],
        file_title: Optional[str],
        org_code: Optional[str],
        text: Optional[str],
        volume: Optional[str],
    ) -> List[Document]:
        query = sqlalchemy.select(Document)

        if batch_id is not None:
            query = query.where(Document.batch_id == batch_id)

        if barcode_number is not None:
            query = query.where(Document.barcode_number == barcode_number)

        if classification_code is not None:
            query = query.where(Document.classification_code == classification_code)

        if classification_level is not None:
            query = query.where(Document.classification_level == classification_level)

        if display_name is not None:
            query = query.where(Document.display_name == display_name)

        if file_number is not None:
            query = query.where(Document.file_number.contains([file_number]))

        if file_title is not None:
            query = query.where(Document.file_title == file_title)

        if org_code is not None:
            query = query.where(Document.org_code == org_code)

        if text is not None:
            text_search_ids = []

            bigquery_documents_text_search_query_results = self.__bigquery_client.query_and_wait(
                f"SELECT ID FROM `{self.__bigquery_documents_table}` WHERE SEARCH(text, {json.dumps(text)})"
            )

            for row in bigquery_documents_text_search_query_results:
                text_search_ids.append(row["ID"])

            query = query.filter(Document.id.in_(text_search_ids))

        if volume is not None:
            query = query.where(Document.volume == volume)

        return db.session.scalars(query)

    def update_document(
        self,
        document_id: str,
        barcode_number: Optional[str],
        classification_code: Optional[str],
        classification_level: Optional[str],
        display_name: Optional[str],
        file_number: Optional[List[str]],
        file_title: Optional[str],
        org_code: Optional[str],
        text: Optional[str],
        volume: Optional[str],
    ) -> Document:
        try:
            document = db.session.get_one(Document, document_id)
        except NoResultFound:
            raise NotFoundException(f"Document {document_id} not found")

        if barcode_number is not None:
            document.barcode_number = barcode_number

        if classification_code is not None:
            document.classification_code = classification_code

        if classification_level is not None:
            document.classification_level = classification_level

        if display_name is not None:
            document.display_name = display_name

        if file_number is not None:
            document.file_number = file_number

        if file_title is not None:
            document.file_title = file_title

        if org_code is not None:
            document.org_code = org_code

        if text is not None:
            bigquery_text = json.dumps(text)

            bigquery_documents_exists_query_results = self.__bigquery_client.query_and_wait(
                f"SELECT 1 FROM `{self.__bigquery_documents_table}` WHERE ID = '{document.id}'"
            )

            if bigquery_documents_exists_query_results.total_rows == 0:
                bigquery_insert_row_errors = self.__bigquery_client.insert_rows_json(
                    table=self.__bigquery_documents_table,
                    json_rows=[{"id": str(document.id), "text": bigquery_text}],
                )

                if len(bigquery_insert_row_errors) > 0:
                    raise Exception(
                        f"Error inserting into BigQuery Table {self.__bigquery_documents_table}. {bigquery_insert_row_errors}"
                    )
            else:
                query_text = f"""
                    UPDATE `{self.__bigquery_documents_table}`
                    SET text = {bigquery_text}
                    WHERE id = '{document.id}'
                    """

                query_job = self.__bigquery_client.query(query_text)

                query_job.result()

                if query_job.num_dml_affected_rows is None:
                    raise Exception(
                        f"Document {document.id} not found in BigQuery Table {self.__bigquery_documents_table}"
                    )

                if query_job.num_dml_affected_rows != 1:
                    raise Exception(
                        f"num_dml_affected_rows should be 1, found {query_job.num_dml_affected_rows}. BigQuery Table {self.__bigquery_documents_table}, Document ID {document.id}"
                    )

        if volume is not None:
            document.volume = volume

        db.session.commit()

        return document

    def __make_blob_name(self, document: Document) -> str:
        return f"{document.batch_id}/{document.id}"
