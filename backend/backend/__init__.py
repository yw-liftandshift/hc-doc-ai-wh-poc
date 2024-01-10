import logging
import sys
from flask import Flask
from google.cloud import storage


from .health_check.blueprints import health_check_blueprint
from .documents.models import *
from .documents.services import DocumentsService
from .documents.blueprints import documents_blueprint
from .error_handlers import add_error_handlers
from .db import db, migrate
from .config import config


def create_app():
    logging.basicConfig(stream=sys.stdout, level=config.LOG_LEVEL)

    app = Flask(__name__)

    app.config.from_object(config)

    db.init_app(app=app)
    migrate.init_app(app=app, db=db)

    storage_client = storage.Client(project=config.GOOGLE_CLOUD_PROJECT)

    app.documents_service = DocumentsService(storage_client=storage_client)

    app.register_blueprint(blueprint=health_check_blueprint)

    app.register_blueprint(blueprint=documents_blueprint)

    add_error_handlers(app=app)
    return app


def setup_database(app: Flask):
    with app.app_context():
        db.create_all()


def main():
    app = create_app()
    setup_database(app=app)

    app.run(port=app.config["PORT"], debug=True)
