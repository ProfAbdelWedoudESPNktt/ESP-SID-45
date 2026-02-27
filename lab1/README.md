# SID45 — Big Data Lab Environment

Complete Docker-based environment for Lab1 (Batch ETL) and Lab2 (Streaming) labs.

**Check [INSTALL.md](INSTALL.md) for detailed installation instructions.**

## Services

| Service | Port | Description |
|---------|------|-------------|
| **Kafka Broker** | 9092 (internal), 9094 (external) | Message broker for streaming |
| **Kafka UI** | 8080 | Web interface for Kafka monitoring |
| **Spark Master** | 7077, 8081 (UI) | Spark cluster master node |
| **Spark Worker** | - | Spark worker with 2 cores, 4GB RAM |
| **Jupyter Lab** | 8888 | Interactive Python environment with PySpark |