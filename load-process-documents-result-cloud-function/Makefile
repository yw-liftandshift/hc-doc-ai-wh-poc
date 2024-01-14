export:
	poetry export -f requirements.txt --output requirements.txt

format:
	poetry run black .

run:
	OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES poetry run functions-framework --port=8080 --target=main --signature-type=http