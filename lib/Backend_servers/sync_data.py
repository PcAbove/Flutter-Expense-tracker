from flask import Flask, request, jsonify
import csv
import os
from datetime import datetime

app = Flask(__name__)
@app.route("/sync", methods=["GET"])
def sync_from_csv():
    import csv
    from flask import jsonify

    try:
        latest_file = sorted(os.listdir("exports"))[-1]  # get last file
        filepath = os.path.join("exports","expenses_export.csv")

        with open(filepath, mode='r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            data = [row for row in reader]

        return jsonify(data), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000,)
