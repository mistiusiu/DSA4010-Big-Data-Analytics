# Hadoop Distributed File System in Docker Compose

## Note

Never use the `--force-recreate` flag since it causes metadata mismatch errors. Instead stop then start the stack.

On Windows:

```bash
docker compose down
```

On MacOS and Linux:

```bash
./stop-hdfs.sh
```

Bring the stack up.

```bash
docker compose up -d
```
