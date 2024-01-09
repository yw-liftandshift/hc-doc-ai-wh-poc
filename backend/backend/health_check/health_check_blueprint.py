from flask import Blueprint

health_check_blueprint = Blueprint("health_check", __name__, url_prefix="/healthz")


@health_check_blueprint.get(rule="/")
async def health_check():
    return {}
