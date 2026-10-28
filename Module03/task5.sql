
-- TASK 5: WINDOW FUNCTIONS AND SUBQUERY REWRITE

-- QUERY 1: Original GROUP BY query
SELECT
    c.customer_id,
    c.name,
    COUNT(*) AS late_orders
FROM orders o
JOIN customer c
    ON c.customer_id = o.customer_id
WHERE o.status = 'late'
GROUP BY c.customer_id, c.name
ORDER BY late_orders DESC;


-- QUERY 2: Correlated subquery
SELECT
    c.customer_id,
    c.name,
    (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.customer_id = c.customer_id
          AND o.status = 'late'
    ) AS late_orders
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'late'
)
ORDER BY late_orders DESC;


-- QUERY 3: Window function
SELECT DISTINCT
    c.customer_id,
    c.name,
    COUNT(*) OVER (
        PARTITION BY c.customer_id
    ) AS late_orders
FROM orders o
JOIN customer c
    ON c.customer_id = o.customer_id
WHERE o.status = 'late'
ORDER BY late_orders DESC;


-- EXECUTION PLAN 1: Original GROUP BY
EXPLAIN QUERY PLAN
SELECT
    c.customer_id,
    c.name,
    COUNT(*) AS late_orders
FROM orders o
JOIN customer c
    ON c.customer_id = o.customer_id
WHERE o.status = 'late'
GROUP BY c.customer_id, c.name
ORDER BY late_orders DESC;


-- EXECUTION PLAN 2: Correlated subquery
EXPLAIN QUERY PLAN
SELECT
    c.customer_id,
    c.name,
    (
        SELECT COUNT(*)
        FROM orders o
        WHERE o.customer_id = c.customer_id
          AND o.status = 'late'
    ) AS late_orders
FROM customer c
WHERE EXISTS (
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.customer_id
      AND o.status = 'late'
)
ORDER BY late_orders DESC;


-- EXECUTION PLAN 3: Window function
EXPLAIN QUERY PLAN
SELECT DISTINCT
    c.customer_id,
    c.name,
    COUNT(*) OVER (
        PARTITION BY c.customer_id
    ) AS late_orders
FROM orders o
JOIN customer c
    ON c.customer_id = o.customer_id
WHERE o.status = 'late'
ORDER BY late_orders DESC;


-- VERIFIED RESULTS FROM THE COMPARISON QUERY
-- Original GROUP BY: 400 customers
-- Correlated subquery: 400 customers
-- Window function: 400 customers
-- Mismatches: 0
--
-- All three queries returned identical customer IDs
-- and late-order counts.
