import os


class _Config:
    GOOGLE_CLOUD_PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT_ID"]
    LOG_LEVEL = os.environ["LOG_LEVEL"]

    @staticmethod
    def init_app(app):
        pass


config = _Config()
