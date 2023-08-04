# Solutions to DBE task

This repository contains the solutions to the DBE Task found [here](https://github.com/mailergroup/dbe-task)

### docker-compose.yml

This file contains configuration to spin up a service of the postgres db using the config/init.sql file.

```yaml
   version: "3.8"
   services:
   db:
      image: postgres:14.1-alpine
      environment:
         POSTGRES_USER: postgres
         POSTGRES_PASSWORD: postgres
         POSTGRES_DB: ml-ecommerce
      ports:
         - "5432:5432"
      volumes:
         # Persist db data
         - db:/var/lib/postgresql/data
         # Mount the pgbench benchmark file (pgbench_names_of_customer_last_30_days.sql)
         - ./pgbench_names_of_customer_last_30_days.sql:/tmp/pgbench_names_of_customer_last_30_days.sql
         # Mount the pgbench file (pgbench_total_revenue.sql)
         - ./pgbench_total_revenue.sql:/tmp/pgbench_total_revenue.sql
         # Mount the pgbench benchmark file (pgbench_top_selling_prod.sql)
         - ./pgbench_top_selling_prod.sql:/tmp/pgbench_top_selling_prod.sql
   volumes:
   db:
      driver: local
```

- docker-compose version: 3.8
- postgres image: postgres:14.1-alpine
- username: postgres
- password: postgres
- database name: ml-ecommerce

There was a conscious effort to run the init.sql script after creating the conatiner rather than load it during creation as it is easier to see if there are errors in the init.sql script.

### setup.sh

This file contains all that is needed to automate the creation of the postgres db using the docker-compose file, waits till its creation is complete and then you can run the benchmarking script.

### benchamrk.sh

This file contains script to automate benchamrking using pgbench

### pgbench_names_of_customer_last_30_days.sql

### pgbench_top_selling_prod.sql

### pgbench_total_revenue.sql

## Setup

Clone the repository

```bash
  git clone https://github.com/ayomidealaka/dbe-task
  cd dbe-task
```

Make Bash script executable

```bash
  chmod +x setup.sh
```

Run script to create the postgres container

```bash
  ./setup.sh
```

## Tasks

## 1. Benchmark some common queries.

A script was created called benchmark.sh that automates benchamrking the queries. This script checks for the existence of a postgres container named dbe-task-db-1 before it runs.

You would need to supply pgbench parameters while running the benchmark.sh script. The parameters include:

-c: Number of concurrent clients (connections). Can be set based on the expected number of simultaneous users.
-j: Number of threads. Usually, this would be set to the number of cores on the machine.
-t: Number of transactions per client. Can be adjusted to run the desired total number of transactions.
-T: Duration of the benchmark in seconds. You can use this instead of -t if you want to run the test for a specific amount of time.

Running the script without parameters would prompt the error:

```bash
   No parameters supplied.
```

Before you run the script, you would need to make the make Bash script executable

```bash
  chmod +x benchamrk.sh
```

An example of a run would be:

```bash
   ./benchmark.sh -c 10 -T 10
```

These queries were benchmarked with the following simulations:

### Baseline Test

This helps to understand system performance under normal conditions or load.

- Clients (-c): 2 consurrent clients
- Transactions (-t): 500 transactions
- Threads (-j): 2 threads

#### Retrieve the names of customers who have placed orders in the last 30 days.

```sql
   SELECT cust.first_name, cust.last_name
   FROM customers cust
   JOIN orders ord ON cust.customer_id = ord.customer_id
   WHERE ord.order_date > CURRENT_DATE - INTERVAL '30 days';

   transaction type: /tmp/pgbench_names_of_customer_last_30_days.sql
   scaling factor: 1
   query mode: simple
   number of clients: 2
   number of threads: 2
   number of transactions per client: 500
   number of transactions actually processed: 1000/1000
   latency average = 6.041 ms
   initial connection time = 4.367 ms
   tps = 331.057205 (without initial connection time)
```

#### Calculate the total revenue generated by the e-commerce shop for a specific date range.

```sql
   SELECT SUM(ord.total_amount) AS total_revenue
   FROM orders ord
   WHERE ord.order_date BETWEEN '2023-07-1' AND '2023-07-31';

   transaction type: /tmp/pgbench_total_revenue.sql
   scaling factor: 1
   query mode: simple
   number of clients: 2
   number of threads: 2
   number of transactions per client: 500
   number of transactions actually processed: 1000/1000
   latency average = 1.372 ms
   initial connection time = 4.478 ms
   tps = 1457.851331 (without initial connection time)
```

#### Find the top-selling products based on the quantity sold.

```sql
   SELECT prod.product_name, SUM(oi.quantity) AS total_quantity_sold
   FROM products prod
   JOIN order_items oi ON prod.product_id = oi.product_id
   GROUP BY prod.product_name
   ORDER BY total_quantity_sold DESC;

   transaction type: /tmp/pgbench_top_selling_prod.sql
   scaling factor: 1
   query mode: simple
   number of clients: 2
   number of threads: 2
   number of transactions per client: 500
   number of transactions actually processed: 1000/1000
   latency average = 11.581 ms
   initial connection time = 3.536 ms
   tps = 172.696271 (without initial connection time)
```

### Stress Test

This helps to understand behaviours and identify limits under heavy load. This simulates 100 concurrent users, exceeded core of 8 and 10000 transactions.

- Clients (-c): 100 consurrent clients
- Transactions (-t): 10000 transactions
- Threads (-j): 8 threads

#### Retrieve the names of customers who have placed orders in the last 30 days.

```sql
   SELECT cust.first_name, cust.last_name
   FROM customers cust
   JOIN orders ord ON cust.customer_id = ord.customer_id
   WHERE ord.order_date > CURRENT_DATE - INTERVAL '30 days';

   transaction type: /tmp/pgbench_names_of_customer_last_30_days.sql
   scaling factor: 1
   query mode: simple
   number of clients: 100
   number of threads: 8
   number of transactions per client: 1000
   number of transactions actually processed: 100000/100000
   latency average = 163.610 ms
   initial connection time = 100.101 ms
   tps = 611.210641 (without initial connection time)
```

#### Calculate the total revenue generated by the e-commerce shop for a specific date range.

```sql
   SELECT SUM(ord.total_amount) AS total_revenue
   FROM orders ord
   WHERE ord.order_date BETWEEN '2023-07-1' AND '2023-07-31';

   transaction type: /tmp/pgbench_total_revenue.sql
   scaling factor: 1
   query mode: simple
   number of clients: 100
   number of threads: 8
   number of transactions per client: 1000
   number of transactions actually processed: 100000/100000
   latency average = 34.943 ms
   initial connection time = 79.973 ms
   tps = 2861.773288 (without initial connection time)
```

#### Find the top-selling products based on the quantity sold.

```sql
   SELECT prod.product_name, SUM(oi.quantity) AS total_quantity_sold
   FROM products prod
   JOIN order_items oi ON prod.product_id = oi.product_id
   GROUP BY prod.product_name
   ORDER BY total_quantity_sold DESC;

   transaction type: /tmp/pgbench_top_selling_prod.sql
   scaling factor: 1
   query mode: simple
   number of clients: 100
   number of threads: 8
   number of transactions per client: 1000
   number of transactions actually processed: 100000/100000
   latency average = 300.162 ms
   initial connection time = 85.781 ms
   tps = 333.153226 (without initial connection time)
```

### High Duration Test

This helps to understand behaviours and identify limits under sustained load. This time we use the time (-T) parameter instead of transactions (-t).

This simulates 20 consurrent users, core of 4 with a runtime of 1hr (3600s)

- Clients (-c): 20 consurrent clients
- Time (-t): 3600 transactions
- Threads (-j): 4 threads

#### Retrieve the names of customers who have placed orders in the last 30 days.

```sql
    SELECT cust.first_name, cust.last_name
   FROM customers cust
   JOIN orders ord ON cust.customer_id = ord.customer_id
   WHERE ord.order_date > CURRENT_DATE - INTERVAL '30 days';

   Running pgbench for retrieve the names of customers who have placed orders in the last 30 days...
   pgbench (14.1)
   transaction type: /tmp/pgbench_names_of_customer_last_30_days.sql
   scaling factor: 1
   query mode: simple
   number of clients: 20
   number of threads: 4
   number of transactions per client: 3600
   number of transactions actually processed: 72000/72000
   latency average = 32.798 ms
   initial connection time = 25.411 ms
   tps = 609.786520 (without initial connection time)
```

#### Calculate the total revenue generated by the e-commerce shop for a specific date range.

```sql
   SELECT SUM(ord.total_amount) AS total_revenue
   FROM orders ord
   WHERE ord.order_date BETWEEN '2023-07-1' AND '2023-07-31';

   Running pgbench for Total revenue generated by the e-commerce shop for the month of July 2023-07-1 to 2023-07-31...
   pgbench (14.1)
   transaction type: /tmp/pgbench_total_revenue.sql
   scaling factor: 1
   query mode: simple
   number of clients: 20
   number of threads: 4
   number of transactions per client: 3600
   number of transactions actually processed: 72000/72000
   latency average = 7.129 ms
   initial connection time = 21.826 ms
   tps = 2805.590794 (without initial connection time)
```

#### Find the top-selling products based on the quantity sold.

```sql
   SELECT prod.product_name, SUM(oi.quantity) AS total_quantity_sold
   FROM products prod
   JOIN order_items oi ON prod.product_id = oi.product_id
   GROUP BY prod.product_name
   ORDER BY total_quantity_sold DESC;

   Running pgbench for Find the top-selling products based on the quantity sold...
   pgbench (14.1)
   transaction type: /tmp/pgbench_top_selling_prod.sql
   scaling factor: 1
   query mode: simple
   number of clients: 20
   number of threads: 4
   number of transactions per client: 3600
   number of transactions actually processed: 72000/72000
   latency average = 60.533 ms
   initial connection time = 21.091 ms
   tps = 330.397473 (without initial connection time)
```

## 2. Create some roles and permissions

### Create a user for "bob" and grant read only permissions.

```sql
   CREATE USER bob WITH PASSWORD 'password';
   GRANT SELECT ON ALL TABLES IN SCHEMA public TO bob;
```

### Create a user for "dave" and grant read write permissions.

```sql
   CREATE USER dave WITH PASSWORD 'password';
   GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO bob;
```

## 3. Review the database schema and implement any improvements or optimizations, you could make for better performance and scalability.

#### Add foreign keys for relationships between tables.

- Added a foreign key constraint for customer_id in the **orders** table.
- Added a foreign key constraint for order_id and product_id in the **order_Items** table.
- Added a foreign key constraint for product_id in the **product** table.

#### Adjusted data types for more efficient storage.

- Changed price in products table from **INT** to **DECIMAL(10, 2)**. This was done to fit other currency datatypes like **subtotal** in the **order_Items** and **total_amount** in the **orders** table.

#### Add indexes on columns that are frequently searched, filtered, or sorted.

- Added index for orders(customer_id), order_Items(order_id) and order_Items(product_id)

```sql
   CREATE INDEX idx_orders_customer_id ON orders(customer_id);
   CREATE INDEX idx_orders_items_order_id ON order_Items(order_id);
   CREATE INDEX idx_order_Items_product_id ON order_Items(product_id);
```

## 4. Identify the tables that can benefit from partitioning based on their characteristics and usage patterns.

The tables that can benefit from partitioning are:

**orders**: This table can be partitioned by month to improve performance for queries that need to retrieve data for a specific month. For example, the query "Retrieve the names of customers who have placed orders in the last 30 days" would be more efficient if the orders table was partitioned by month.

## 5. Design a partitioning strategy for the selected tables, considering factors such as data distribution, query patterns, and data growth. Document and implement the partitioning strategy.

The partitioning strategy for the orders tables should be as follows:

**orders**: The orders table should bepartitioned by month. This will improve performance for queries that need to retrieve data for a specific month. The partitioning key should be the order_date column. The partitioning type to use would be range.

```sql
   ALTER TABLE orders
   ADD CONSTRAINT orders_pk PRIMARY KEY (order_id, order_date);

   ALTER TABLE orders
   ADD CONSTRAINT orders_uk UNIQUE (order_id, order_date);

   CREATE TABLE orders_01_23 PARTITION OF orders FOR VALUES FROM ('2023-01-01') TO ('2023-02-01');
   CREATE TABLE orders_02_23 PARTITION OF orders FOR VALUES FROM ('2023-02-01') TO ('2023-03-01');
   CREATE TABLE orders_03_23 PARTITION OF orders FOR VALUES FROM ('2023-03-01') TO ('2023-04-01');
   CREATE TABLE orders_04_23 PARTITION OF orders FOR VALUES FROM ('2023-04-01') TO ('2023-05-01');
   CREATE TABLE orders_05_23 PARTITION OF orders FOR VALUES FROM ('2023-05-01') TO ('2023-06-01');
   CREATE TABLE orders_06_23 PARTITION OF orders FOR VALUES FROM ('2023-06-01') TO ('2023-07-01');
   CREATE TABLE orders_07_23 PARTITION OF orders FOR VALUES FROM ('2023-07-01') TO ('2023-08-01');
   CREATE TABLE orders_08_23 PARTITION OF orders FOR VALUES FROM ('2023-08-01') TO ('2023-08-31');
```
