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
├── docker/
│   ├── jupyter/
│   │   └── Dockerfile
│   └── spark/
│       └── Dockerfile
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
mkdir -p checkpoints notebooks docker/jupyter docker/spark
```

### 2. Build Images
```bash
docker compose build
# Wait 5-10 minutes for images to build
```

The Spark image (master and worker) is built from `docker/spark/Dockerfile` using
`apache/spark:3.5.0` as the base image. The Jupyter image is built from
`docker/jupyter/Dockerfile`.

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
docker exec jupyter python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('spark://spark-master:7077').getOrCreate(); print('Spark ' + spark.version + ' ready'); spark.stop()"
```

**Test Kafka:**
```bash
# Use the internal hostname kafka:9092 (not localhost:9092)
docker exec kafka kafka-broker-api-versions --bootstrap-server kafka:9092
```

## Network and Port Reference

| Service      | Internal address  | Host address         | Notes                        |
|--------------|-------------------|----------------------|------------------------------|
| Kafka broker | kafka:9092        | not exposed          | Used by other containers     |
| Kafka host   | -                 | localhost:9094       | External access from host    |
| Kafka UI     | kafka-ui:8080     | localhost:8080       | Web UI                       |
| Spark Master | spark-master:7077 | localhost:7077       | RPC port                     |
| Spark Web UI | spark-master:8080 | localhost:8081       | Web UI                       |
| Spark App UI | -                 | localhost:4040       | Active job UI                |
| Jupyter      | jupyter:8888      | localhost:8888       | Token: bigdata2026           |

> Note: Kafka's internal listener is bound to the container hostname `kafka`, not
> `localhost`. Always use `kafka:9092` when connecting from inside the Docker network.

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
- **Docker Desktop**: Settings -> Resources -> Memory -> Increase to 8GB+
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

# Or pull base images manually first
docker pull confluentinc/cp-kafka:7.5.0
docker pull apache/spark:3.5.0
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

**Problem**: Kafka takes longer to start, or the wrong address is used

**Solution**:
```bash
# Wait 30 more seconds
sleep 30

# Check Kafka logs
docker compose logs kafka

# Verify Kafka is ready using the correct internal hostname
docker exec kafka kafka-broker-api-versions --bootstrap-server kafka:9092
```

> Important: Do not use `localhost:9092` inside the container. The Kafka broker
> listener is bound to `kafka:9092` (the container hostname). From the host
> machine, use `localhost:9094`.

### Issue 7: "Permission denied" writing Kafka logs

**Problem**: The Kafka data volume is owned by root but the container runs as `appuser`

**Solution**: This is fixed by using `/var/lib/kafka/data` as the log directory
(which the image owns). If you upgraded from an older setup that used
`/tmp/kraft-combined-logs`, remove the old volume and recreate it:
```bash
docker compose stop kafka
docker compose rm -f kafka
docker volume rm lab1_kafka-data
docker compose up -d kafka
```

## Post-Installation

### Create Your First Kafka Topic

```bash
docker exec -it kafka bash -lc \
  "kafka-topics --bootstrap-server kafka:9092 --create --topic test-topic --partitions 3 --replication-factor 1"
```

### Run Your First Spark Job

```bash
docker exec -it jupyter bash
cd /home/myname/work
python -c "from pyspark.sql import SparkSession; spark = SparkSession.builder.master('spark://spark-master:7077').getOrCreate(); df = spark.range(100); print('Count: ' + str(df.count())); spark.stop()"
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

print("Spark version: " + spark.version)
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

1. Check logs: `docker compose logs <service-name>`
2. Verify status: `docker compose ps`
3. Run validation: `./validate.sh`
4. Check resources: `docker stats`

Common log commands:
```bash
docker compose logs kafka          # Kafka logs
docker compose logs spark-master   # Spark Master logs
docker compose logs jupyter        # Jupyter logs
```
