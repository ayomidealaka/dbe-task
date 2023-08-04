#!/bin/bash

echo "Stopping and removing existing PostgreSQL container..."

# Take down all existing containers in relation to this
docker-compose down
docker volume rm dbe-task_db

sleep 5

echo "Starting PostgreSQL container using docker-compose file..."

docker-compose up -d

# Wait 10s for the database to be ready
sleep 10

docker-compose up -d

echo "Initializing database with init.sql file..."

docker-compose exec -T db psql -U postgres -d ml-ecommerce <config/init.sql

echo "Creating user 'bob' and granting read-only permissions..."

# Create user 'bob' with read-only permissions
docker-compose exec -T db psql -U postgres -d ml-ecommerce <<EOF
CREATE USER bob WITH PASSWORD 'password';
GRANT SELECT ON ALL TABLES IN SCHEMA public TO bob;
EOF

echo "Creating user 'dave' and granting read-write permissions..."

# Create user 'dave' with read-write permissions
docker-compose exec -T db psql -U postgres -d ml-ecommerce <<EOF
CREATE USER dave WITH PASSWORD 'password';
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO dave;
EOF

echo "Getting list of users..."

# Prints the list of users to see bob and dave
docker-compose exec -T db psql -U postgres -d ml-ecommerce <<EOF
SELECT rolname FROM pg_roles;
EOF
