from marshmallow_sqlalchemy import SQLAlchemyAutoSchema, fields

from backend.db import db
from backend.documents.models import Document
from .batch import batch_schema


class __DocumentSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Document
        include_relationships = True
        load_instance = True
        sqla_session = db.session

    batch = fields.Nested(batch_schema)


document_schema = __DocumentSchema()
