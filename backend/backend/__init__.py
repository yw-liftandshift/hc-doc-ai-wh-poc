from flask import Flask
from .health_check import health_check_blueprint
from .error_handlers import add_error_handlers
from .config import config

app = Flask(__name__)

app.config.from_object(config)

add_error_handlers(app=app)

with app.app_context():
    app.register_blueprint(blueprint=health_check_blueprint)
