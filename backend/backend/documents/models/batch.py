import datetime
import uuid
from dataclasses import dataclass
from enum import StrEnum, auto

from sqlalchemy import DateTime, String
from sqlalchemy.dialects.postgresql import UUID, ENUM
from sqlalchemy.sql.functions import now

from backend.db import db


class BatchStatus(StrEnum):
    CREATED = auto()
    ERROR = auto()
    PROCESSING = auto()
    PROCESSED = auto()


@dataclass
class Batch(db.Model):
    id: str
    status: BatchStatus
    created_at: datetime.datetime

    id = db.Column(UUID, primary_key=True, default=uuid.uuid4())
    status = db.Column(
        ENUM(
            str(BatchStatus.CREATED),
            str(BatchStatus.ERROR),
            str(BatchStatus.PROCESSING),
            str(BatchStatus.PROCESSED),
            name="status",
        ),
        default=BatchStatus.CREATED,
    )
    google_cloud_storage_bucket_name = db.Column(String, nullable=False)
    created_at = db.Column(DateTime(timezone=True), server_default=now())
