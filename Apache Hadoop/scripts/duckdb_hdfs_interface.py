import duckdb
from fsspec.implementations.webhdfs import WebHDFS

# Connect to the HDFS NameNode with Host and Port
hdfs = WebHDFS(host="namenode", port=9870, user="root")

# Register the HDFS filesystem with DuckDB
duckdb.register_filesystem(hdfs)

# Query a CSV file directly from HDFS
df = duckdb.sql("SELECT * FROM read_csv('webhdfs:///user/course_score.csv')").df()

print(df)
