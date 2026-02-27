FROM jupyter/pyspark-notebook:spark-3.5.0

USER root

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim \
    nano \
    git \
    build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directories as root
RUN mkdir -p /workspace/data && \
    mkdir -p /workspace/checkpoints && \
    mkdir -p /home/myname/work && \
    chown -R ${NB_UID}:${NB_GID} /workspace /home/myname/work

USER ${NB_UID}

# Install Python packages
RUN pip install --no-cache-dir \
    confluent-kafka==2.3.0 \
    pandas==2.1.3 \
    pyarrow==14.0.1 \
    numpy==1.26.2 \
    matplotlib==3.8.2 \
    seaborn==0.13.0 \
    plotly==5.18.0 \
    requests==2.31.0 \
    beautifulsoup4==4.12.2 \
    lxml==4.9.3 \
    jupyter-server-proxy==4.1.0 \
    jupyterlab==4.0.9

# Install Kafka packages for PySpark
RUN pip install pyspark==3.5.0

# Set working directory
WORKDIR /home/myname/work

# Expose Jupyter port
EXPOSE 8888

# Set environment variables
ENV PYSPARK_PYTHON=/opt/conda/bin/python
ENV PYSPARK_DRIVER_PYTHON=/opt/conda/bin/python
ENV SPARK_HOME=/usr/local/spark
ENV PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.9.7-src.zip:$PYTHONPATH

# Start Jupyter Lab
CMD ["start-notebook.sh", "--NotebookApp.token='bigdata2026'", "--NotebookApp.password=''"]
