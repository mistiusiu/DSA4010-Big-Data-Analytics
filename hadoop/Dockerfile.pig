ARG HADOOP_VERSION=3.5.0
FROM apache/hadoop:${HADOOP_VERSION} AS hadoop

FROM eclipse-temurin:17-jre

ARG PIG_VERSION=0.18.0

LABEL org.opencontainers.image.title="Apache Pig"
LABEL org.opencontainers.image.description="Apache Pig with Hadoop client"
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        tar \
        bash && \
    rm -rf /var/lib/apt/lists/*

COPY --from=hadoop /opt/hadoop /opt/hadoop

RUN curl -fsSL \
    https://downloads.apache.org/pig/pig-${PIG_VERSION}/pig-${PIG_VERSION}.tar.gz \
    | tar -xz -C /opt && \
    mv /opt/pig-${PIG_VERSION} /opt/pig

ENV JAVA_HOME=/opt/java/openjdk
ENV HADOOP_HOME=/opt/hadoop
ENV HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop
ENV PIG_HOME=/opt/pig
ENV PATH="${PATH}:${HADOOP_HOME}/bin:${PIG_HOME}/bin"

WORKDIR /workspace

CMD ["pig"]
