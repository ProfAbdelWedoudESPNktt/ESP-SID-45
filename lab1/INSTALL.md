# SID45 Big Data Lab 1 - Complete Installation Guide

## What You're Installing

A complete Docker-based environment for Big Data labs including:
- **Kafka**: Distributed message broker for streaming
- **Spark**: Distributed computing engine (Master + Worker)
- **Jupyter Lab**: Interactive Python environment with PySpark
- **Kafka UI**: Web interface for monitoring Kafka

## Prerequisites

### System Requirements
- **OS**: Linux, macOS, or Windows 10/11 with WSL2
- **RAM**: Minimum 8GB (16GB recommended)
- **Disk**: 10GB free space
- **CPU**: 4 cores recommended

### Software Requirements
- **Docker Desktop** 4.0+ (includes Docker Engine + Docker Compose)
  - Download: https://www.docker.com/products/docker-desktop
- OR **Docker Engine** 20.10+ and **Docker Compose** 2.0+

## Installation Steps

### Step 1: Download Lab Files

**Option A: Git Clone (if available)**
```bash
git clone https://github.com/hweyin-ltc/backend.git sid45-lab
cd sid45-lab/lab1
```

**Option B: Manual Download**
1. Download all files to a folder named `sid45-lab/lab1`
2. Ensure you have all these files:
```
sid45-lab/lab1/
├── docker-compose.yml
├── docker/jupyter/Dockerfile
├── requirements.txt
├── .env
├── __init__.py
├── .gitignore
├── Makefile
├── setup.sh
├── validate.sh
└── README.md
```

### Step 2: Verify Docker Installation

```bash
# Check Docker
docker --version
# Expected: Docker version 20.10.x or higher

# Check Docker Compose
docker compose version
# Expected: Docker Compose version 2.x.x or higher

# Test Docker is running
docker ps
# Should show empty list or running containers (no error)
```

**If Docker is not installed:**
- **Linux**: Follow https://docs.docker.com/engine/install/
- **macOS**: Install Docker Desktop from https://www.docker.com/products/docker-desktop
- **Windows**: Install Docker Desktop with WSL2 backend

### Step 3: Run Automated Setup

```bash
# Navigate to lab directory
cd sid45-lab/lab1

# Make setup script executable
chmod +x setup.sh

# Run setup (takes 5-10 minutes first time)
./setup.sh
```

### Step 4: Verify Installation

```bash
# Run validation script
./validate.sh
```

### Step 5: Access Services

Open in your browser:

1. **Jupyter Lab**: http://localhost:8888
   - Token: `bigdata2026`
   - You should see Jupyter Lab interface

2. **Spark Master UI**: http://localhost:8081
   - Should show 1 worker registered
   - Status: ALIVE

3. **Kafka UI**: http://localhost:8080
   - Should show `local` cluster
   - Status: Connected

## Manual Installation (Alternative)

If automated setup fails, follow these steps:

### 1. Create Directories
```bash
cd sid45-lab
mkdir -p data/lab1/{raw,bronze,silver,gold}
mkdir -p data/lab2/{raw,checkpoints,output}
mkdir -p checkpoints notebooks docker/jupyter
```

### 2. Build Images
```bash
docker compose build
# Wait 5-10 minutes for images to build
```

### 3. Start Services
```bash
docker compose up -d
```

### 4. Wait for Services
```bash
# Wait 30 seconds for all services to start
sleep 30

# Check status
docker compose ps
```

All services should show `Up (healthy)`.

### 5. Test Connectivity

**Test Spark:**
```bash
docker exec jupyter python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('spark://spark-master:7077').getOrCreate(); print(f'✓ Spark {spark.version} ready'); spark.stop()"
```

**Test Kafka:**
```bash
docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

## Troubleshooting

### Issue 1: "Port already in use"

**Problem**: Port 8888, 8080, or 8081 is already in use

**Solution**: Change ports in `docker-compose.yml`
```yaml
# For Jupyter (change 8888 to 8889)
jupyter:
  ports:
    - "8889:8888"  # Change external port
```

Then restart:
```bash
docker compose down
docker compose up -d
```

### Issue 2: "Cannot connect to Docker daemon"

**Problem**: Docker is not running

**Solution**:
- **Docker Desktop**: Start Docker Desktop application
- **Linux**: `sudo systemctl start docker`

### Issue 3: "Out of memory" or slow performance

**Problem**: Not enough RAM allocated to Docker

**Solution**:
- **Docker Desktop**: Settings → Resources → Memory → Increase to 8GB+
- **Linux**: Docker uses all available RAM

Edit `docker-compose.yml` to reduce worker memory:
```yaml
spark-worker-1:
  environment:
    SPARK_WORKER_MEMORY: 2G  # Reduce from 4G
```

### Issue 4: "Build failed" or "Image pull failed"

**Problem**: Network issues or Docker Hub rate limit

**Solution**:
```bash
# Retry with verbose logging
docker compose build --no-cache --progress=plain

# Or pull images manually first
docker pull confluentinc/cp-kafka:7.5.0
docker pull bitnami/spark:3.5.0
docker pull jupyter/pyspark-notebook:spark-3.5.0
```

### Issue 5: Services start but are unhealthy

**Problem**: Services need more time to initialize

**Solution**:
```bash
# Wait longer
sleep 60

# Check logs
docker compose logs jupyter
docker compose logs kafka

# Restart unhealthy service
docker compose restart jupyter
```

### Issue 6: "Kafka connectivity test failed"

**Problem**: Kafka takes longer to start

**Solution**:
```bash
# Wait 30 more seconds
sleep 30

# Check Kafka logs
docker compose logs kafka

# Verify Kafka is ready
docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

## Post-Installation

### Create Your First Kafka Topic

```bash
docker exec -it kafka bash -lc \
  "kafka-topics --bootstrap-server localhost:9092 --create --topic test-topic --partitions 3 --replication-factor 1"
```

### Run Your First Spark Job

```bash
docker exec -it jupyter bash
cd /home/myname/work
python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('spark://spark-master:7077').getOrCreate(); df = spark.range(100); print(f'Count: {df.count()}'); spark.stop()"
```

### Test Jupyter Notebook

1. Open http://localhost:8888
2. Token: `bigdata2026`
3. Create new notebook: Python 3
4. Test PySpark:
```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("spark://spark-master:7077") \
    .getOrCreate()

print(f"Spark version: {spark.version}")
spark.range(10).show()
```

## Additional Commands

```bash
# View all logs
docker compose logs -f

# Stop services
docker compose down

# Restart services
docker compose restart

# Remove everything (including data)
docker compose down -v

# Rebuild after changes
docker compose up -d --build
```

## Getting Help

If you encounter issues:

1. **Check logs**: `docker compose logs <service-name>`
2. **Verify status**: `docker compose ps`
3. **Run validation**: `./validate.sh`
4. **Check resources**: `docker stats`

Common log commands:
```bash
docker compose logs kafka      # Kafka logs
docker compose logs spark-master  # Spark Master logs
docker compose logs jupyter    # Jupyter logs
```

---
