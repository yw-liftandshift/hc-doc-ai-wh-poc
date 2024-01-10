import dataclasses
from http import HTTPStatus
from flask import Blueprint, current_app, request
from backend.config import config

documents_blueprint = Blueprint("documents", __name__, url_prefix="/documents")


@documents_blueprint.post("/batch")
def create_batch():
    batch = current_app.documents_service.create_batch()

    return dataclasses.asdict(batch), HTTPStatus.CREATED


@documents_blueprint.post("/batch/<batch_id>/process")
def process_batch(batch_id: str):
    batch = current_app.documents_service.process_batch(batch_id=batch_id)

    return dataclasses.asdict(batch)


@documents_blueprint.post("/batch/<batch_id>/documents")
def create_document(batch_id: str):
    if len(request.files) == 0:
        raise ValueError("No documents were uploaded")

    if len(request.files) > 1:
        raise ValueError("A single document must be uploaded")

    file = request.files["file"]

    document = current_app.documents_service.create_document(
        batch_id=batch_id,
        google_cloud_storage_bucket_name=config.GOOGLE_CLOUD_STORAGE_BUCKET_DOCUMENTS,
        file_name=file.filename,
        file_obj=file.stream,
        content_type=file.content_type,
    )

    return dataclasses.asdict(document), HTTPStatus.CREATED
