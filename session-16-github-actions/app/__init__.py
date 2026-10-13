"""GPA Calculator API (Session 16 CI/CD demo)."""

import os

from flask import Flask, jsonify, request

from app.gpa import GRADE_POINTS, calculate_gpa

APP_VERSION = os.environ.get("APP_VERSION", "dev")


def create_app() -> Flask:
    app = Flask(__name__)

    @app.get("/health")
    def health():
        return jsonify(status="ok", version=APP_VERSION)

    @app.get("/api/grades")
    def grades():
        return jsonify(scale="4.0", grade_points=GRADE_POINTS)

    @app.post("/api/gpa")
    def gpa():
        payload = request.get_json(silent=True) or {}
        try:
            result = calculate_gpa(payload.get("courses", []))
        except ValueError as error:
            return jsonify(error=str(error)), 400
        return jsonify(result)

    return app
