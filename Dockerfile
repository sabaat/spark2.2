# Use an OpenJDK 8 base image
FROM openjdk:8-jdk

# Install git and wget (optional if you don't need git inside the container)
RUN apt-get update && apt-get install -y git wget && rm -rf /var/lib/apt/lists/*

# Set environment variables for Spark
ENV SPARK_VERSION=2.2.0
ENV HADOOP_VERSION=2.7
ENV SPARK_HOME=/opt/spark

# Download and extract Spark 2.2 (pre-built for Hadoop 2.7)
RUN wget -q "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" -O /tmp/spark.tgz && \
    mkdir -p ${SPARK_HOME} && \
    tar -xzf /tmp/spark.tgz -C ${SPARK_HOME} --strip-components=1 && \
    rm /tmp/spark.tgz

# Add Spark to PATH
ENV PATH="${SPARK_HOME}/bin:${PATH}"

# Copy the locally cloned repository into the container
COPY spark-homework-udf /opt/spark-homework-udf

# Set the working directory to your project folder inside the container
WORKDIR /opt/spark-homework-udf

# (Optional) If your project requires additional build steps, add them here.
# For example, if you have a build script, you can run:
# RUN ./build.sh

# Define the default command for your container (adjust as needed)
CMD ["bash"]
