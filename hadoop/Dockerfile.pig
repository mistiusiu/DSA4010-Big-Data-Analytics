ARG HADOOP_VERSION=3.5.0
FROM apache/hadoop:${HADOOP_VERSION} AS hadoop

FROM eclipse-temurin:17-jre

ARG PIG_VERSION=0.18.0

LABEL org.opencontainers.image.title="Apache Pig"
LABEL org.opencontainers.image.description="Apache Pig ${PIG_VERSION} with Hadoop ${HADOOP_VERSION} client"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.source="https://github.com/${GITHUB_REPOSITORY}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        curl \
        tar && \
    rm -rf /var/lib/apt/lists/*

COPY --from=hadoop /opt/hadoop /opt/hadoop

RUN curl -fsSL \
    "https://downloads.apache.org/pig/pig-${PIG_VERSION}/pig-${PIG_VERSION}.tar.gz" \
    | tar -xz -C /opt && \
    mv /opt/pig-${PIG_VERSION} /opt/pig

RUN find /opt/pig/lib -mindepth 2 -type f -name "*.jar" \
        -exec cp -n {} /opt/pig/lib/ \; && \
    find /opt/pig/lib -mindepth 1 -type d -exec rm -rf {} +

ENV JAVA_HOME=/opt/java/openjdk \
    HADOOP_HOME=/opt/hadoop \
    HADOOP_CONF_DIR=/opt/hadoop/etc/hadoop \
    PIG_HOME=/opt/pig \
    PATH=/opt/java/openjdk/bin:/opt/hadoop/bin:/opt/pig/bin:$PATH

WORKDIR /workspace

CMD ["pig"]
