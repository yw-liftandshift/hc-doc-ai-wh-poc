import os


class _Config:
    PORT = int(os.environ["PORT"])
    DEBUG = os.environ.get("DEBUG") or False

    @staticmethod
    def init_app(app):
        pass


config = _Config()
