import datetime
from dataclasses import dataclass
from typing import List, Optional

from sqlalchemy import ForeignKey, DateTime, String, text
from sqlalchemy.dialects.postgresql import ARRAY, UUID
from sqlalchemy.sql.functions import now

from backend.db import db


@dataclass
class Document(db.Model):
    id: str
    batch_id: str
    barcode_number: Optional[str]
    classification_code: Optional[str]
    classification_level: Optional[str]
    display_name: str
    file_number: Optional[List[str]]
    file_title: Optional[str]
    org_code: Optional[str]
    volume: Optional[str]
    created_at: datetime.datetime
    updated_at: datetime.datetime

    id = db.Column(UUID, primary_key=True, server_default=text("gen_random_uuid()"))
    batch_id = db.Column(ForeignKey("batch.id"))
    barcode_number = db.Column(String)
    classification_code = db.Column(String)
    classification_level = db.Column(String)
    content_type = db.Column(String, nullable=False)
    display_name = db.Column(String, nullable=False)
    file_number = db.Column(ARRAY(String))
    file_title = db.Column(String)
    org_code = db.Column(String)
    volume = db.Column(String)
    created_at = db.Column(DateTime(timezone=True), server_default=now())
    updated_at = db.Column(DateTime(timezone=True), onupdate=now())
