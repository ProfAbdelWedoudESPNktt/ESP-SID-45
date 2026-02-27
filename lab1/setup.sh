#!/bin/bash

# SID45 Big Data Lab - Setup Script
# Run this script to initialize the lab environment

set -e  # Exit on error

echo "=========================================="
echo "SID45 Big Data Lab - Environment Setup"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check Docker
echo -n "Checking Docker installation... "
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    docker --version
else
    echo -e "${RED}✗${NC}"
    echo "Docker is not installed. Please install Docker Desktop or Docker Engine."
    exit 1
fi

echo ""

# Check Docker Compose
echo -n "Checking Docker Compose installation... "
if command -v docker compose &> /dev/null; then
    echo -e "${GREEN}✓${NC}"
    docker compose version
else
    echo -e "${RED}✗${NC}"
    echo "Docker Compose is not installed. Please install Docker Compose v2."
    exit 1
fi

echo ""

# Create directory structure
echo "Creating directory structure..."
mkdir -p data/lab1/{raw,bronze,silver,gold}
mkdir -p checkpoints
mkdir -p notebooks

# Create .gitkeep files
touch data/lab1/raw/.gitkeep

echo -e "${GREEN}✓${NC} Directories created"
echo ""

# Build images
echo "Building Docker images..."
echo "This may take 5-10 minutes on first run..."
docker compose build

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Docker images built successfully"
else
    echo -e "${RED}✗${NC} Failed to build Docker images"
    exit 1
fi

echo ""

# Start services
echo "Starting services..."
docker compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC} Services started"
else
    echo -e "${RED}✗${NC} Failed to start services"
    exit 1
fi

echo ""

# Wait for services to be healthy
echo "Waiting for services to be healthy (30 seconds)..."
sleep 30

echo ""

# Check service health
echo "Checking service health..."
docker compose ps

echo ""

# Test Spark connectivity
echo -n "Testing Spark connectivity... "
set +e
docker exec jupyter python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('spark://spark-master:7077').getOrCreate(); spark.stop()" &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Spark connectivity test failed. Check logs with: docker compose logs spark-master"
fi
set -e

# Test Kafka connectivity
echo -n "Testing Kafka connectivity... "
set +e
docker exec kafka kafka-broker-api-versions --bootstrap-server kafka:9092 &> /dev/null
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗${NC}"
    echo "Kafka connectivity test failed. Check logs with: docker compose logs kafka"
fi
set -e

echo ""
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo "Access your lab environment:"
echo ""
echo "  Jupyter Lab:     http://localhost:8888"
echo "  Token: bigdata2026"
echo ""
echo "  Spark Master UI: http://localhost:8081"
echo "  Kafka UI:        http://localhost:8080"
echo ""
echo "Useful commands:"
echo "  - Enter Jupyter:    docker exec -it jupyter bash"
echo "  - View logs:        docker compose logs -f"
echo "  - Stop services:    docker compose down"
echo "  - Restart:          docker compose restart"
echo ""
echo "Or use the Makefile:"
echo "  - make help         Show all available commands"
echo "  - make shell-jupyter Enter Jupyter container"
echo "  - make logs         View all logs"
echo ""
echo "Ready to start your Big Data labs!"
echo ""
