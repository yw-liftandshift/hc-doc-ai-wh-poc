import datetime
import uuid
from enum import StrEnum, auto
from typing import List

from sqlalchemy import Enum, text
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy.sql.functions import now

from backend.db import db


class BatchStatus(StrEnum):
    CREATED = auto()
    ERROR = auto()
    PROCESSING = auto()
    PROCESSED = auto()


class Batch(db.Model):
    id: Mapped[uuid.UUID] = mapped_column(
        primary_key=True, server_default=text("gen_random_uuid()")
    )
    documents: Mapped[List["Document"]] = relationship(back_populates="batch")
    google_cloud_storage_bucket_name: Mapped[str] = mapped_column()
    status: Mapped[BatchStatus] = mapped_column(
        Enum(
            str(BatchStatus.CREATED),
            str(BatchStatus.ERROR),
            str(BatchStatus.PROCESSING),
            str(BatchStatus.PROCESSED),
            name="status",
        ),
        default=BatchStatus.CREATED,
    )
    created_at: Mapped[datetime.datetime] = mapped_column(server_default=now())
