#!/bin/bash

# SID45 Big Data Lab - Environment Validation Script
# Run this script to verify your environment is correctly configured

set -e

echo "================================================"
echo "SID45 Big Data Lab - Environment Validation"
echo "================================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

# Check function
check() {
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓${NC} $1"
        return 0
    else
        echo -e "${RED}✗${NC} $1"
        ((ERRORS++))
        return 1
    fi
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# 1. Check files exist
echo "1. Checking configuration files..."
[ -f "docker-compose.yml" ]; check "docker-compose.yml exists"
[ -f ".env" ]; check ".env exists"
[ -f "requirements.txt" ]; check "requirements.txt exists"
echo ""

# 2. Check directories
echo "2. Checking directory structure..."
[ -d "data/lab1/raw" ]; check "data/lab1/raw/ exists"
[ -d "data/lab1/bronze" ]; check "data/lab1/bronze/ exists"
[ -d "data/lab1/silver" ]; check "data/lab1/silver/ exists"
[ -d "data/lab1/gold" ]; check "data/lab1/gold/ exists"
[ -d "checkpoints" ]; check "checkpoints/ exists"
[ -d "notebooks" ]; check "notebooks/ exists"
[ -d "docker/jupyter" ]; check "docker/jupyter/ exists"
[ -d "docker/spark" ]; check "docker/spark/ exists"

if [ -f "docker/jupyter/Dockerfile" ]; then
    check "docker/jupyter/Dockerfile exists"
else
    warn "docker/jupyter/Dockerfile not found"
fi
echo ""

if [ -f "docker/spark/Dockerfile" ]; then
    check "docker/spark/Dockerfile exists"
else
    warn "docker/spark/Dockerfile not found"
fi
echo ""

# 3. Check Docker
echo "3. Checking Docker installation..."
if command -v docker &> /dev/null; then
    check "Docker is installed"
    DOCKER_VERSION=$(docker --version)
    info "Version: $DOCKER_VERSION"
else
    check "Docker is installed"
fi
echo ""

# 4. Check Docker Compose
echo "4. Checking Docker Compose..."
if command -v docker compose &> /dev/null; then
    check "Docker Compose is installed"
    COMPOSE_VERSION=$(docker compose version)
    info "Version: $COMPOSE_VERSION"
else
    check "Docker Compose is installed"
fi
echo ""

# 5. Check services
echo "5. Checking Docker services..."
if docker compose ps | grep -q "Up"; then
    check "Services are running"
    
    # Check individual services
    if docker compose ps | grep -q "kafka.*Up"; then
        check "Kafka is running"
    else
        warn "Kafka is not running"
    fi
    
    if docker compose ps | grep -q "kafka-ui.*Up"; then
        check "Kafka UI is running"
    else
        warn "Kafka UI is not running"
    fi
    
    if docker compose ps | grep -q "spark-master.*Up"; then
        check "Spark Master is running"
    else
        warn "Spark Master is not running"
    fi
    
    if docker compose ps | grep -q "spark-worker-1.*Up"; then
        check "Spark Worker is running"
    else
        warn "Spark Worker is not running"
    fi
    
    if docker compose ps | grep -q "jupyter.*Up"; then
        check "Jupyter is running"
    else
        warn "Jupyter is not running"
    fi
else
    warn "Services are not running (run: docker compose up -d)"
fi
echo ""

# 6. Check ports
echo "6. Checking port availability..."

check_port() {
    PORT=$1
    SERVICE=$2
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 || netstat -an 2>/dev/null | grep LISTEN | grep -q ":$PORT "; then
        check "$SERVICE port $PORT is in use"
    else
        warn "$SERVICE port $PORT is not in use (service may not be running)"
    fi
}

check_port 8888 "Jupyter"
check_port 8081 "Spark Master UI"
check_port 8080 "Kafka UI"
check_port 9094 "Kafka External"

echo ""

# 7. Test connectivity (if services running)
if docker compose ps | grep -q "Up"; then
    echo "7. Testing service connectivity..."
    
    # Test Spark
    if docker exec jupyter python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('spark://spark-master:7077').getOrCreate(); spark.stop()" &> /dev/null; then
        check "Spark connectivity works"
    else
        warn "Spark connectivity failed"
    fi
    
    # Test Kafka
    if docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 &> /dev/null 2>&1; then
        check "Kafka connectivity works"
    else
        warn "Kafka connectivity failed"
    fi
    
    echo ""
fi

# 8. Summary
echo "================================================"
echo "Validation Summary"
echo "================================================"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo ""
    echo "Your environment is ready for Lab1."
    echo ""
    echo "Access points:"
    echo "  - Jupyter Lab:     http://localhost:8888 (token: bigdata2026)"
    echo "  - Spark Master UI: http://localhost:8081"
    echo "  - Kafka UI:        http://localhost:8080"
    echo ""
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Validation completed with $WARNINGS warning(s)${NC}"
    echo ""
    echo "Your environment is mostly ready, but some optional components may need attention."
    echo "Review warnings above."
else
    echo -e "${RED}✗ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo ""
    echo "Please fix the errors above before starting the labs."
    echo ""
    echo "Common fixes:"
    echo "  - Run setup: ./setup.sh"
    echo "  - Start services: docker compose up -d"
    exit 1
fi

echo ""
