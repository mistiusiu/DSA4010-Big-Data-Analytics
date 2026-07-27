# ==============================================================================
# Stage 1 - Hadoop Runtime
# ==============================================================================

ARG HADOOP_VERSION=3.5.0
FROM apache/hadoop:${HADOOP_VERSION} AS hadoop



# ==============================================================================
# Stage 2 - Build Apache Pig from Source
# ==============================================================================

FROM eclipse-temurin:8-jdk AS builder


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



# ------------------------------------------------------------------------------
# Hadoop libraries
# ------------------------------------------------------------------------------

COPY --from=hadoop /opt/hadoop /opt/hadoop


ENV JAVA_HOME=/opt/java/openjdk
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop

ENV PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${PATH}"



# ------------------------------------------------------------------------------
# Clone Pig
# ------------------------------------------------------------------------------

WORKDIR /build


RUN git clone \
        --depth 1 \
        --branch ${PIG_BRANCH} \
        https://github.com/apache/pig.git



WORKDIR /build/pig



# ------------------------------------------------------------------------------
# Build Pig for Hadoop 3
# ------------------------------------------------------------------------------

RUN ant \
        -Dhadoopversion=3 \
        clean \
        jar



# ------------------------------------------------------------------------------
# Verify Hadoop 3 artifact exists
# ------------------------------------------------------------------------------

RUN find . -name "pig-core-h3.jar"



# ------------------------------------------------------------------------------
# Install Pig layout
# ------------------------------------------------------------------------------

RUN mkdir -p /opt/pig/lib



#
# Pig scripts and configuration
#
RUN cp -r \
        bin \
        conf \
        /opt/pig/



#
# Pig libraries
#
RUN cp -r \
        lib/* \
        /opt/pig/lib/



#
# Generated Hadoop-specific jars
#
RUN find build \
        -name "*.jar" \
        -exec cp {} /opt/pig/lib/ \;



#
# Verify final Pig layout
#
RUN find /opt/pig -name "*pig-core*"



RUN chmod +x /opt/pig/bin/*



# ------------------------------------------------------------------------------
# Validate Pig before creating runtime image
# ------------------------------------------------------------------------------

RUN /opt/pig/bin/pig -version




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



# ------------------------------------------------------------------------------
# Hadoop runtime
# ------------------------------------------------------------------------------

COPY --from=hadoop /opt/hadoop /opt/hadoop



# ------------------------------------------------------------------------------
# Pig runtime
# ------------------------------------------------------------------------------

COPY --from=builder /opt/pig /opt/pig



ENV JAVA_HOME=/opt/java/openjdk


ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop


ENV PIG_HOME=/opt/pig



ENV PIG_CLASSPATH="${HADOOP_HOME}/etc/hadoop:${HADOOP_HOME}/share/hadoop/common/*:${HADOOP_HOME}/share/hadoop/common/lib/*:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/mapreduce/*:${HADOOP_HOME}/share/hadoop/yarn/*"



ENV PATH="${JAVA_HOME}/bin:${HADOOP_HOME}/bin:${PIG_HOME}/bin:${PATH}"



WORKDIR /workspace



CMD ["pig"]
