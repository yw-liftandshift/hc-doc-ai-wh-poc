import os


class _Config:
    DEBUG = True if os.environ.get("DEBUG") else False
    GOOGLE_CLOUD_PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT_ID"]
    GOOGLE_CLOUD_BIGQUERY_DOCUMENTS_TABLE = os.environ[
        "GOOGLE_CLOUD_BIGQUERY_DOCUMENTS_TABLE"
    ]
    GOOGLE_CLOUD_PROCESS_DOCUMENTS_WORKFLOW_PUBSUB_TOPIC = os.environ[
        "GOOGLE_CLOUD_PROCESS_DOCUMENTS_WORKFLOW_PUBSUB_TOPIC"
    ]
    GOOGLE_CLOUD_STORAGE_DOCUMENTS_BUCKET = os.environ[
        "GOOGLE_CLOUD_STORAGE_DOCUMENTS_BUCKET"
    ]
    LOG_LEVEL = os.environ["LOG_LEVEL"]
    PORT = int(os.environ["PORT"])
    SQLALCHEMY_DATABASE_URI = f"postgresql://{os.environ['POSTGRES_USER']}:{os.environ['POSTGRES_PASSWORD']}@{os.environ['POSTGRES_HOST']}:{os.environ['POSTGRES_PORT']}/{os.environ['POSTGRES_DB']}"

    @staticmethod
    def init_app(app):
        pass


config = _Config()
