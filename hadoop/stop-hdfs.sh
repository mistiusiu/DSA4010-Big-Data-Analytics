# No hash bang here for MacOS/Linux compatibility

docker exec -it namenode hdfs dfsadmin -safemode enter
docker exec -it namenode hdfs dfsadmin -saveNamespace

docker exec -it datanode hdfs --daemon stop datanode

docker exec -it namenode hdfs --daemon stop namenode

docker compose down
