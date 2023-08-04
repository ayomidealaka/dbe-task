docker_container_id=$(docker ps -q -f name=db)
if [ -z "$docker_container_id" ]; then
    echo "The PostgreSQL container is not running. Please start the container using the setup.sh file before running this script."
    exit 1
fi

# clients=100
# transactions=1000
# threads=8

# Assign parameters to parameter variable to run queries with pgbench
parameters="$@"

if [[ $parameters = "" ]]; then
    echo "No parameters supplied."
    exit 1
fi

# Benchmarking using pgbench
echo "Starting pgbench benchamrk tests..."

echo "Running pgbench benchamark test with parameters: $parameters"

echo "Running pgbench for retrieve the names of customers who have placed orders in the last 30 days..."

# Retrieve the names of customers who have placed orders in the last 30 days.
docker-compose exec db pgbench -f /tmp/pgbench_names_of_customer_last_30_days.sql -n $parameters "host=localhost port=5432 dbname=ml-ecommerce user=postgres password=postgres"

echo "Running pgbench for Total revenue generated by the e-commerce shop for the month of July 2023-07-1 to 2023-07-31..."

# Calculate the total revenue generated by the e-commerce shop for a specific date range.
docker-compose exec db pgbench -f /tmp/pgbench_total_revenue.sql -n $parameters "host=localhost port=5432 dbname=ml-ecommerce user=postgres password=postgres"

echo "Running pgbench for Find the top-selling products based on the quantity sold..."

# Find the top-selling products based on the quantity sold.
docker-compose exec db pgbench -f /tmp/pgbench_top_selling_prod.sql -n $parameters "host=localhost port=5432 dbname=ml-ecommerce user=postgres password=postgres"
