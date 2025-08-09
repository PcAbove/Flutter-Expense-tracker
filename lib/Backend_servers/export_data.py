import csv
import json
from flask import Flask, jsonify

app = Flask(__name__)

CSV_PATH = r"C:\Users\Twist\Desktop\ExpenseUploads\expenses_export.csv"

@app.route("/get", methods=["GET"])
def get_expenses():
    data = []
    with open(CSV_PATH, newline='') as csvfile:
        reader = csv.DictReader(csvfile)
        for row in reader:
            data.append({
                "expense_id": row["expense_id"],
                "expense_name": row["expense_name"],
                "expense_price": float(row["expense_price"]),
                "expense_created_at": row["expense_created_at"],
                "expense_type": int(row["expense_type"]),
                "expense_category": row.get("expense_category_name")
            })

    return jsonify(data)  # 👈 Flask automatically sets content-type to application/json

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
