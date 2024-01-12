from backend import setup_app

if __name__ == "__main__":
    app = setup_app()
    app.run(port=app.config["PORT"], debug=True)
