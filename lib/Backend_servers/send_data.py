from flask import Flask, request, jsonify
import csv
import os
from datetime import datetime

app = Flask(__name__)

@app.route("/export", methods=["POST"])
def export_data():
    data = request.get_json()

    if not data or not isinstance(data, list):
        return jsonify({"error": "Invalid or missing data. Expected a list of records."}), 400

    # Create "exports" folder if not exists
    export_dir = "exports"
    os.makedirs(export_dir, exist_ok=True)

    # Generate clean filename and full path
    filename = datetime.now().strftime("data_%Y-%m-%d_%H-%M-%S.csv")
    filepath = os.path.join(export_dir, filename)

    # Write CSV
    keys = data[0].keys()
    with open(filepath, mode='w', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=keys)
        writer.writeheader()
        writer.writerows(data)

    print(f"✅ CSV file saved at: {filepath}")
    return jsonify({"message": f"Data exported successfully to {filepath}"}), 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
