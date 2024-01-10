import datetime
import uuid
from dataclasses import dataclass
from enum import StrEnum, auto

from sqlalchemy import DateTime
from sqlalchemy.dialects.postgresql import UUID, ENUM
from sqlalchemy.sql.functions import now

from backend.db import db


class BatchStatus(StrEnum):
    CREATED = auto()
    PROCESSING = auto()


@dataclass
class Batch(db.Model):
    id: str
    status: BatchStatus
    created_at: datetime.datetime

    id = db.Column(UUID, primary_key=True, default=uuid.uuid4())
    status = db.Column(
        ENUM(str(BatchStatus.CREATED), str(BatchStatus.PROCESSING), name="status"),
        default=BatchStatus.CREATED,
    )
    created_at = db.Column(DateTime(timezone=True), server_default=now())
