FROM apache/spark:3.5.0

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    procps \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directories
RUN mkdir -p /workspace/data /workspace/checkpoints /opt/spark/logs && \
    chmod -R 777 /workspace /opt/spark/logs

# Expose ports:
#   8080 - Spark Master Web UI
#   7077 - Spark Master RPC
#   4040 - Spark Application UI
#   8081 - Spark Worker Web UI
EXPOSE 8080 7077 4040 8081
