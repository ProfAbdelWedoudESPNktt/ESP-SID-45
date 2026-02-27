.PHONY: help build up down restart logs clean test-spark test-kafka setup

# Default target
help:
	@echo "SID45 Big Data Lab - Available Commands:"
	@echo ""
	@echo "  make setup        - Create required directories"
	@echo "  make build        - Build Docker images"
	@echo "  make up           - Start all services"
	@echo "  make down         - Stop all services"
	@echo "  make restart      - Restart all services"
	@echo "  make logs         - View logs from all services"
	@echo "  make logs-kafka   - View Kafka logs"
	@echo "  make logs-spark   - View Spark Master logs"
	@echo "  make logs-jupyter - View Jupyter logs"
	@echo "  make ps           - Show running containers"
	@echo "  make test-spark   - Test Spark connectivity"
	@echo "  make test-kafka   - Test Kafka connectivity"
	@echo "  make shell-jupyter - Enter Jupyter container"
	@echo "  make shell-kafka  - Enter Kafka container"
	@echo "  make clean        - Stop and remove all containers/volumes"
	@echo "  make clean-data   - Remove all generated data"
	@echo ""

# Setup directories
setup:
	@echo "Creating required directories..."
	mkdir -p data/lab1/{raw,bronze,silver,gold}
	mkdir -p data/lab2/{raw,checkpoints,output}
	mkdir -p checkpoints
	mkdir -p notebooks
	mkdir -p docker/jupyter
	@echo "Directories created"

# Build images
build:
	@echo "Building Docker images..."
	docker compose build
	@echo "Build complete"

# Start services
up:
	@echo "Starting services..."
	docker compose up -d
	@echo "Waiting for services to be healthy (30s)..."
	@sleep 30
	@echo "Services started"
	@make ps

# Stop services
down:
	@echo "Stopping services..."
	docker compose down
	@echo "Services stopped"

# Restart services
restart:
	@echo "Restarting services..."
	docker compose restart
	@echo "Services restarted"

# View logs
logs:
	docker compose logs -f

logs-kafka:
	docker compose logs -f kafka

logs-spark:
	docker compose logs -f spark-master

logs-jupyter:
	docker compose logs -f jupyter

# Show running containers
ps:
	@echo "Service Status:"
	@docker compose ps

# Test Spark connectivity
test-spark:
	@echo "Testing Spark connectivity..."
	@docker exec -it jupyter python -c "\
		from pyspark.sql import SparkSession; \
		spark = SparkSession.builder.master('spark://spark-master:7077').getOrCreate(); \
		print(f'Spark version: {spark.version}'); \
		print(f'Workers: {spark.sparkContext.defaultParallelism}'); \
		spark.stop()"

# Test Kafka connectivity
test-kafka:
	@echo "Testing Kafka connectivity..."
	@docker exec -it kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1 && \
		echo "Kafka is responding" || echo "❌ Kafka connection failed"

# Shell access
shell-jupyter:
	@echo "Entering Jupyter container..."
	docker exec -it jupyter bash

shell-kafka:
	@echo "Entering Kafka container..."
	docker exec -it kafka bash

# Clean up
clean:
	@echo "Stopping and removing all containers and volumes..."
	docker compose down -v
	@echo "Cleanup complete"

clean-data:
	@echo "Removing generated data..."
	rm -rf data/lab1/{bronze,silver,gold}/*
	rm -rf data/lab2/{checkpoints,output}/*
	@echo "Data cleaned"

# Create test topic
create-topic:
	@echo "Creating test Kafka topic..."
	docker exec -it kafka kafka-topics --bootstrap-server localhost:9092 \
		--create --topic test-topic --partitions 3 --replication-factor 1 \
		--if-not-exists
	@echo "Topic created"

# List Kafka topics
list-topics:
	@echo "Kafka topics:"
	@docker exec -it kafka kafka-topics --bootstrap-server localhost:9092 --list

# Full setup
full-setup: setup build up test-spark test-kafka
	@echo ""
	@echo "================================================"
	@echo "Lab environment is ready!"
	@echo "================================================"
	@echo ""
	@echo "Access points:"
	@echo "  - Jupyter Lab:     http://localhost:8888 (token: bigdata2026)"
	@echo "  - Spark Master UI: http://localhost:8081"
	@echo "  - Kafka UI:        http://localhost:8080"
	@echo ""
	@echo "Next steps:"
	@echo "  1. Open Jupyter Lab: http://localhost:8888"
	@echo "  2. Or enter container: make shell-jupyter"
	@echo ""
