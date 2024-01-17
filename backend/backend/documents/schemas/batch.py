from marshmallow_sqlalchemy import SQLAlchemyAutoSchema

from backend.db import db
from backend.documents.models import Batch


class __BatchSchema(SQLAlchemyAutoSchema):
    class Meta:
        model = Batch
        include_relationships = True
        load_instance = True
        sqla_session = db.session


batch_schema = __BatchSchema(exclude=["google_cloud_storage_bucket_name"])
