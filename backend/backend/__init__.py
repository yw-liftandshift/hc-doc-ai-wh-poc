import logging
import sys
import flask_migrate
from flask import Flask
from google.cloud import pubsub_v1, storage


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

    setup_database(app=app)

    pubsub_publisher_client = pubsub_v1.PublisherClient()

    storage_client = storage.Client(project=config.GOOGLE_CLOUD_PROJECT_ID)

    app.documents_service = DocumentsService(
        project_id=config.GOOGLE_CLOUD_PROJECT_ID,
        pubsub_publisher_client=pubsub_publisher_client,
        process_documents_workflow_pubsub_topic=config.GOOGLE_CLOUD_PROCESS_DOCUMENTS_WORKFLOW_PUBSUB_TOPIC,
        storage_client=storage_client,
        google_cloud_storage_documents_bucket=config.GOOGLE_CLOUD_STORAGE_DOCUMENTS_BUCKET,
    )

    app.register_blueprint(blueprint=health_check_blueprint)

    app.register_blueprint(blueprint=documents_blueprint)

    add_error_handlers(app=app)

    return app


def setup_database(app: Flask):
    with app.app_context():
        db.create_all()
        flask_migrate.upgrade()


def setup_app():
    app = create_app()
    setup_database(app=app)

    return app
