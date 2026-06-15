#!/bin/bash

# 1. Conditional Formatting
if [ ! -d "/opt/hadoop/data/nameNode/current" ]; then
    echo "Formatting NameNode for the first time..."
    hdfs namenode -format -force
    
    # 2. Run a background loop to initialize Hive folders ONLY on the first format
    (
        echo "Waiting for NameNode to fully boot to initialize Hive paths..."
        # Wait until port 9000 is awake
        while ! nc -z localhost 9000; do sleep 2; done
        
        # Wait a few extra seconds for HDFS to exit Safemode
        sleep 10 
        
        echo "Creating Hive HDFS directories..."
        hdfs dfs -mkdir -p /tmp
        hdfs dfs -mkdir -p /user/hive/warehouse
        hdfs dfs -chmod 777 /tmp
        hdfs dfs -chmod 777 /user/hive/warehouse
        echo "Hive HDFS directories initialized successfully."
    ) &
else
    echo "Found existing NameNode data. Skipping format..."
fi

# 3. Launch NameNode (this keeps the container running)
echo "Starting NameNode..."
hdfs namenode
