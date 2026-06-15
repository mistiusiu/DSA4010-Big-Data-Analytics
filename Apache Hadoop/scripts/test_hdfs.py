from hdfs import InsecureClient
import pandas as pd
import io

# Connect using the internal Docker DNS name
client = InsecureClient('http://namenode:9870', user='root')

# 1. Create a dummy dataframe
df = pd.DataFrame({'id': [1, 2, 3], 'name': ['Misati', 'Python', 'HDFS']})

# 2. Write directly to HDFS as a CSV
with client.write('/user/data.csv', encoding='utf-8') as writer:
    df.to_csv(writer, index=False)

print("File written successfully!")

# 3. Read it back
with client.read('/user/data.csv') as reader:
    content = reader.read()
    print(f"Read from HDFS:\n{content.decode('utf-8')}")
