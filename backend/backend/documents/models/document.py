import datetime
from dataclasses import dataclass

from sqlalchemy import ForeignKey, DateTime, String, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql.functions import now

from backend.db import db


@dataclass
class Document(db.Model):
    id: str
    batch_id: str
    created_at: datetime.datetime
    updated_at: datetime.datetime

    id = db.Column(UUID, primary_key=True, server_default=text("gen_random_uuid()"))
    batch_id = db.Column(ForeignKey("batch.id"))
    google_cloud_storage_blob_name = db.Column(String, nullable=False)
    created_at = db.Column(DateTime(timezone=True), server_default=now())
    updated_at = db.Column(DateTime(timezone=True), onupdate=now())
