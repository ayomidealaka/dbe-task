-- Benchmark file for pgbench

-- Retrieve the names of customers who have placed orders in the last 30 days
SELECT c.first_name, c.last_name FROM customers c JOIN orders o ON c.customer_id = o.customer_id WHERE o.order_date >= current_date - interval '30 days';




