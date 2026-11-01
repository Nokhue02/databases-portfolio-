import sqlite3
import tempfile
import time
from pathlib import Path
from datetime import datetime, timedelta

folder = Path(__file__).resolve().parent
db_path = folder / "edge.db"

# Generate 10,000 synthetic vibration readings
start = datetime(2026, 4, 1)

rows = [
    (
        2,
        (start + timedelta(seconds=i)).isoformat(sep=" "),
        2.7,
        1
    )
    for i in range(10000)
]

sql = """
INSERT INTO reading(sensor_id, ts, value, interval_s)
VALUES (?, ?, ?, ?)
"""

def benchmark(path, use_trigger):
    conn = sqlite3.connect(path)
    conn.execute("PRAGMA foreign_keys = ON")

    if not use_trigger:
        conn.execute("DROP TRIGGER IF EXISTS trg_vib_alarm")
        conn.commit()

    start_time = time.perf_counter()

    with conn:
        conn.executemany(sql, rows)

    elapsed = time.perf_counter() - start_time

    alarm_count = conn.execute(
        "SELECT COUNT(*) FROM alarm"
    ).fetchone()[0]

    conn.close()
    return elapsed, alarm_count


# Create independent test copies so the real database
# is not changed by the benchmark.
with tempfile.TemporaryDirectory() as temp:
    times = []

    for enabled in (False, True):
        copy_path = Path(temp) / (
            "with_trigger.db" if enabled
            else "without_trigger.db"
        )

        source = sqlite3.connect(db_path)
        target = sqlite3.connect(copy_path)
        source.backup(target)
        target.close()
        source.close()

        seconds, alarms = benchmark(copy_path, enabled)
        times.append(seconds)

        print(
            f"Trigger enabled: {enabled}, "
            f"Time: {seconds:.4f} seconds, "
            f"Total alarms: {alarms}"
        )

    print(
        f"Extra time with trigger: "
        f"{times[1] - times[0]:.4f} seconds"
    )
