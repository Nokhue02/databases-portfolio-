
-- TASK 4: RELATIONAL ALGEBRA TO SQL

-- This query joins the orders and customer tables,
-- filters for late orders, and displays customer
-- IDs and names.

SELECT
    c.customer_id,
    c.name
FROM orders o
JOIN customer c
    ON c.customer_id = o.customer_id
WHERE o.status = 'late';

-- RELATIONAL ALGEBRA EXPLANATION
-- Selection: Keep only orders with status = 'late'
-- Join: Match orders to customers using customer_id
-- Projection: Display customer_id and name
--
-- The SQL query matches the relational algebra
-- operations of selection, join, and projection.
