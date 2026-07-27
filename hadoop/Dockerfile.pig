# ==============================================================================
# Stage 1 - Hadoop Runtime
# ==============================================================================

ARG HADOOP_VERSION=3.5.0
FROM apache/hadoop:${HADOOP_VERSION} AS hadoop


# ==============================================================================
# Stage 2 - Build Apache Pig from Source
# ==============================================================================

FROM eclipse-temurin:17-jdk AS builder

ARG PIG_BRANCH=branch-0.18

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        git \
        ant \
        ivy \
        maven \
        curl \
        python3 \
        ca-certificates \
        bash \
        unzip && \
    rm -rf /var/lib/apt/lists/*


# Hadoop runtime
COPY --from=hadoop /opt/hadoop /opt/hadoop


ENV JAVA_HOME=/opt/java/openjdk
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop

ENV PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"


WORKDIR /build


# ==============================================================================
# Clone Apache Pig source
# ==============================================================================

RUN git clone \
        --depth 1 \
        --branch ${PIG_BRANCH} \
        https://github.com/apache/pig.git


WORKDIR /build/pig


# ==============================================================================
# Build Pig against Hadoop 3
# ==============================================================================

RUN ant \
        -Dhadoopversion=3 \
        clean \
        jar


# ==============================================================================
# Prepare Pig installation
# ==============================================================================

RUN mkdir -p /opt/pig


#
# Copy Pig distribution
#
RUN cp -r \
        bin \
        conf \
        lib \
        /opt/pig/


#
# Copy generated jars
#
RUN find build \
        -maxdepth 2 \
        -name "*.jar" \
        -exec cp {} /opt/pig/ \;


#
# Ensure scripts executable
#
RUN chmod +x /opt/pig/bin/*


# ==============================================================================
# Stage 3 - Runtime
# ==============================================================================

FROM eclipse-temurin:17-jre


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        python3 && \
    rm -rf /var/lib/apt/lists/*


# Hadoop runtime
COPY --from=hadoop /opt/hadoop /opt/hadoop


# Pig runtime
COPY --from=builder /opt/pig /opt/pig


ENV JAVA_HOME=/opt/java/openjdk

ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop

ENV PIG_HOME=/opt/pig


ENV PIG_CLASSPATH="${HADOOP_HOME}/etc/hadoop:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/share/hadoop/yarn/*"


ENV PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${PIG_HOME}/bin:${PATH}"


WORKDIR /workspace


CMD ["pig"]
