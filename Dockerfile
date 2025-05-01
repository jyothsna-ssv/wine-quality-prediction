# 1. Base image with OpenJDK and slim OS
FROM openjdk:8-jdk-slim

# 2. Install Python3, pip, wget
RUN apt-get update && \
    apt-get install -y python3 python3-pip wget && \
    rm -rf /var/lib/apt/lists/*

# 3. Install Spark
ENV SPARK_VERSION=3.5.1 \
    HADOOP_VERSION=3
RUN wget -qO spark.tgz \
      https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark.tgz -C /opt/ && \
    rm spark.tgz

ENV SPARK_HOME=/opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}
ENV PATH=$SPARK_HOME/bin:$PATH
ENV PYSPARK_PYTHON=python3
ENV PYSPARK_DRIVER_PYTHON=python3

# 4. Set working directory
WORKDIR /app

# 5. Install Python deps
COPY requirements.txt /app/
RUN pip3 install --no-cache-dir -r requirements.txt

# 6. Copy your prediction code and model
COPY wine_rf_prediction_docker.py /app/
COPY wine_rf_model /app/models/wine_rf_model

# 7. Declare /data as a mount point for input CSV(s)
VOLUME ["/data"]

# 8. Entrypoint + default CMD
ENTRYPOINT ["python3", "wine_rf_prediction_docker.py"]
CMD ["--input_csv", "/data/prediction.csv"]