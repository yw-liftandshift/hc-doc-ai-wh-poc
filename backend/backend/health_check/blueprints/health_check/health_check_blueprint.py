from flask import Blueprint

from backend.db import db

health_check_blueprint = Blueprint("health_check", __name__, url_prefix="/healthz")


@health_check_blueprint.get(rule="/")
async def health_check():
    db.session.execute("SELECT 1")
    return {}
