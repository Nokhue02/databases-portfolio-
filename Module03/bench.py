
import sqlite3
import statistics
import time
from pathlib import Path

DB = Path(__file__).with_name("warehouse.db")
REPEATS = 3

QUERIES = {
    "Dashboard query": """
        SELECT c.city,
               COUNT(DISTINCT c.customer_id) AS customers,
               SUM(ol.qty * p.price) AS revenue
        FROM customer c
        JOIN orders o ON o.customer_id = c.customer_id
        JOIN order_line ol ON ol.order_id = o.order_id
        JOIN product p ON p.product_id = ol.product_id
        WHERE o.ordered_on >= '2025-01-01'
          AND o.ordered_on < '2026-01-01'
        GROUP BY c.city
        ORDER BY revenue DESC
    """,
    "Single-day lookup": """
        SELECT o.order_id, o.ordered_on, c.name
        FROM orders o
        JOIN customer c ON c.customer_id = o.customer_id
        WHERE o.ordered_on = '2026-02-14'
    """,
    "Product filter": """
        SELECT ol.order_id, ol.product_id, ol.qty
        FROM order_line ol
        WHERE ol.product_id = 1
    """,
    "Date function (negative test)": """
        SELECT order_id, ordered_on
        FROM orders
        WHERE date(ordered_on) = '2026-02-14'
    """,
}


def benchmark(connection, sql):
    times = []

    for _ in range(REPEATS):
        start = time.perf_counter()
        connection.execute(sql).fetchall()
        times.append(time.perf_counter() - start)

    return statistics.median(times)


def main():
    if not DB.exists():
        raise FileNotFoundError(
            f"Database not found: {DB}\n"
            "Make sure warehouse.db is inside Module03."
        )

    with sqlite3.connect(DB) as connection:
        print(f"Database: {DB}")
        print(f"Runs per query: {REPEATS}")

        for name, sql in QUERIES.items():
            print(f"\n--- {name} ---")

            plan = connection.execute(
                "EXPLAIN QUERY PLAN " + sql
            ).fetchall()

            print("Query plan:")
            for row in plan:
                print(" ", row[3])

            median = benchmark(connection, sql)
            print(f"Median: {median:.6f} seconds")


if __name__ == "__main__":
    main()
