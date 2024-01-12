FROM python:3.12-slim

ARG POETRY_VERSION=1.6.1

COPY . /app

WORKDIR /app

# Generate requirements.txt
RUN pip install --upgrade pip && \
    pip install poetry==$POETRY_VERSION && \
    poetry export -f requirements.txt --output requirements.txt && \
    pip install -r requirements.txt

CMD gunicorn --bind "0.0.0.0:$PORT" --workers 1 --threads 8 --timeout 0 "backend:setup_app()"