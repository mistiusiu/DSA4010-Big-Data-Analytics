from hdfs import InsecureClient


client = InsecureClient('http://namenode:9870', user='root')


def run_hdfs_tasks():
    remote_path = '/user/python_test.txt'
    content = "Hello Misati, this is data sent from Python to HDFS!"

    print("--- 1. Writing data to HDFS ---")
    with client.write(remote_path, encoding='utf-8', overwrite=True) as writer:
        writer.write(content)
    print(f"Successfully wrote to {remote_path}")

    print("\n--- 2. Reading data back ---")
    with client.read(remote_path, encoding='utf-8') as reader:
        data = reader.read()
        print(f"Content from HDFS: {data}")

    print("\n--- 3. Checking Cluster Status ---")
    status = client.status('/')
    print(f"Root Directory Status: {status}")

    print("\n--- 4. Listing Files in /user ---")
    files = client.list('/user')
    print(f"Files: {files}")


if __name__ == "__main__":
    try:
        run_hdfs_tasks()
    except Exception as e:
        print(f"Error: {e}")
        print("\nNote: Ensure your Docker containers are running and 'localhost:9870' is accessible.")
