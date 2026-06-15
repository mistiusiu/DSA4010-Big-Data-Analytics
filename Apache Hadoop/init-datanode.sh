#!/bin/bash

# Ensure the data directory exists
mkdir -p /opt/hadoop/data/dataNode

# Set permissions safely without wiping the data
chown -R root:root /opt/hadoop/data/dataNode
chmod 755 /opt/hadoop/data/dataNode

echo "Starting DataNode..."
hdfs datanode
