import dataclasses
from http import HTTPStatus
from flask import Blueprint, current_app, request

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
        file_name=file.filename,
        file_obj=file.stream,
        content_type=file.content_type,
    )

    return dataclasses.asdict(document), HTTPStatus.CREATED


@documents_blueprint.get("/")
def list_documents():
    documents = current_app.documents_service.list_documents()

    return [dataclasses.asdict(document) for document in documents]


@documents_blueprint.patch("/<document_id>")
def update_document(document_id: str):
    document = current_app.documents_service.update_document(
        document_id=document_id,
        barcode_number=request.json["barcode_number"],
        classification_code=request.json["classification_code"],
        classification_level=request.json["classification_level"],
        display_name=request.json["display_name"],
        file_number=request.json["file_number"],
        file_title=request.json["file_title"],
        org_code=request.json["org_code"],
        volume=request.json["volume"],
    )

    return dataclasses.asdict(document)
