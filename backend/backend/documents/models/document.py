import datetime
import uuid
from typing import List, Optional

from sqlalchemy import ForeignKey, String, text
from sqlalchemy.dialects.postgresql import ARRAY, UUID
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql.functions import now

from backend.db import db
from .batch import Batch


class Document(db.Model):
    id: Mapped[uuid.UUID] = mapped_column(UUID, primary_key=True)
    batch_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("batch.id"))
    batch: Mapped["Batch"] = relationship(back_populates="documents")
    barcode_number: Mapped[Optional[str]] = mapped_column()
    classification_code: Mapped[Optional[str]] = mapped_column()
    classification_level: Mapped[Optional[str]] = mapped_column()
    content_type: Mapped[str] = mapped_column(nullable=False)
    display_name: Mapped[str] = mapped_column(nullable=False)
    file_number: Mapped[Optional[List[str]]] = mapped_column(ARRAY(String))
    file_title: Mapped[Optional[str]] = mapped_column()
    org_code: Mapped[Optional[str]] = mapped_column()
    volume: Mapped[Optional[str]] = mapped_column()
    created_at: Mapped[datetime.datetime] = mapped_column(server_default=now())
    updated_at: Mapped[datetime.datetime] = mapped_column(
        server_default=now(), onupdate=now()
    )
