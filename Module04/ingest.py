
import csv
import sqlite3
from pathlib import Path

# Locate files inside Module04
folder = Path(__file__).resolve().parent
db_path = folder / "edge.db"
csv_path = folder / "readings.csv"

# Connect to SQLite
conn = sqlite3.connect(db_path)
conn.execute("PRAGMA foreign_keys = ON")

# Read the CSV file
with open(csv_path, newline="", encoding="utf-8") as file:
    reader = csv.DictReader(file)

    rows = [
        (
            int(row["sensor_id"]),
            row["ts"],
            float(row["value"]),
            int(row["interval_s"])
        )
        for row in reader
    ]

# Insert or update readings
sql = """
INSERT INTO reading(sensor_id, ts, value, interval_s)
VALUES (?, ?, ?, ?)
ON CONFLICT(sensor_id, ts)
DO UPDATE SET
    value = excluded.value,
    interval_s = excluded.interval_s;
"""

with conn:
    conn.executemany(sql, rows)

# Count the rows
count = conn.execute(
    "SELECT COUNT(*) FROM reading"
).fetchone()[0]

print("CSV readings processed:", len(rows))
print("Total database rows:", count)

conn.close()
