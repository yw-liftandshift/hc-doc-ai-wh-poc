import os


class _Config:
    GOOGLE_CLOUD_PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT_ID"]
    GOOGLE_CLOUD_STORAGE_OUTPUT_BUCKET = os.environ[
        "GOOGLE_CLOUD_STORAGE_OUTPUT_BUCKET"
    ]
    GOOGLE_CLOUD_STORAGE_OUTPUT_FOLDER = os.environ[
        "GOOGLE_CLOUD_STORAGE_OUTPUT_FOLDER"
    ]
    LOG_LEVEL = os.environ["LOG_LEVEL"]

    @staticmethod
    def init_app(app):
        pass


config = _Config()
