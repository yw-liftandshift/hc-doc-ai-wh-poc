export:
	poetry export -f requirements.txt --output requirements.txt

flask-db-init:
	FLASK_APP=backend poetry run flask db init

flask-db-migrate:
	FLASK_APP=backend poetry run flask db migrate -m "$(MESSAGE)"

format:
	poetry run black .

run:
	poetry run dotenv run -- python -m backend

up:
	docker compose up --wait -d --build

up-postgres:
	docker compose up postgres --wait -d

down:
	docker compose down

clean-up-postgres:
	make down && rm -rf postgres-data && sleep 2 && make up-postgres