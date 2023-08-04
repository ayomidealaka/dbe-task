-- Benchmark file for pgbench

-- Find the top-selling products based on the quantity sold
SELECT p.product_name, sum(oi.quantity) AS total_quantity
FROM products p
JOIN order_items oi ON p.product_id = oi.product_id
GROUP BY p.product_name
ORDER BY total_quantity DESC
LIMIT 10;



