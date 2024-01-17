import uuid
from http import HTTPStatus
from flask import Blueprint, current_app, request

from backend.documents.schemas import batch_schema, document_schema

documents_blueprint = Blueprint("documents", __name__, url_prefix="/documents")


@documents_blueprint.post("/batch")
def create_batch():
    batch = current_app.documents_service.create_batch()

    return batch_schema.dump(batch), HTTPStatus.CREATED


@documents_blueprint.post("/batch/<batch_id>/process")
def process_batch(batch_id: str):
    batch = current_app.documents_service.process_batch(batch_id=batch_id)

    return batch_schema.dump(batch)


@documents_blueprint.get("/batch")
def list_batch():
    batch = current_app.documents_service.list_batch()

    return batch_schema.dump(batch, many=True)


@documents_blueprint.get("/batch/<batch_id>")
def get_batch(batch_id: uuid.UUID):
    batch = current_app.documents_service.get_batch(batch_id=batch_id)

    return batch_schema.dump(batch)


@documents_blueprint.patch("/batch/<batch_id>")
def update_batch(batch_id: str):
    batch = current_app.documents_service.update_batch(
        batch_id=batch_id,
        status=request.json["status"],
    )

    return batch_schema.dump(batch)


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

    return document_schema.dump(document), HTTPStatus.CREATED


@documents_blueprint.get("/")
def list_documents():
    documents = current_app.documents_service.list_documents(
        batch_id=request.args.get("batch_id"),
        barcode_number=request.args.get("barcode_number"),
        classification_code=request.args.get("classification_code"),
        classification_level=request.args.get("classification_level"),
        display_name=request.args.get("display_name"),
        file_number=request.args.get("file_number"),
        file_title=request.args.get("file_title"),
        org_code=request.args.get("org_code"),
        text=request.args.get("text"),
        volume=request.args.get("volume"),
    )

    current_app.logger.info(documents)

    return document_schema.dump(documents, many=True)


@documents_blueprint.get("/<document_id>")
def get_document(document_id: uuid.UUID):
    documents = current_app.documents_service.get_document(document_id=document_id)

    current_app.logger.info(documents)

    return document_schema.dump(documents)


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
        text=request.json["text"],
        volume=request.json["volume"],
    )

    return document_schema.dump(document)
