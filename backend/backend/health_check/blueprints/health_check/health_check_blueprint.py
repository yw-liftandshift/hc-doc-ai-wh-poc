from flask import Blueprint
from sqlalchemy import text

from backend.db import db

health_check_blueprint = Blueprint("health_check", __name__, url_prefix="/healthz")


@health_check_blueprint.get(rule="/")
async def health_check():
    db.session.execute(text("SELECT 1"))
    return {}
