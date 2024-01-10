import logging
import os


class _Config:
    DEBUG = True if os.environ.get("DEBUG") else False
    GOOGLE_CLOUD_PROJECT = os.environ["GOOGLE_CLOUD_PROJECT"]
    GOOGLE_CLOUD_STORAGE_BUCKET_DOCUMENTS = os.environ[
        "GOOGLE_CLOUD_STORAGE_BUCKET_DOCUMENTS"
    ]
    LOG_LEVEL = os.environ["LOG_LEVEL"]
    PORT = int(os.environ["PORT"])
    SQLALCHEMY_DATABASE_URI = f"postgresql://{os.environ['POSTGRES_USER']}:{os.environ['POSTGRES_PASSWORD']}@{os.environ['POSTGRES_HOST']}:{os.environ['POSTGRES_PORT']}/{os.environ['POSTGRES_DB']}"

    @staticmethod
    def init_app(app):
        pass


config = _Config()
