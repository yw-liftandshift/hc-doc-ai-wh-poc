export:
	poetry export -f requirements.txt --output requirements.txt

flask-db-init:
	poetry run flask db init

format:
	poetry run black .

run:
	poetry run dotenv run -- python -m backend

up:
	docker compose up --wait -d

down:
	docker compose down