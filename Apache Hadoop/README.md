# Hadoop Distributed File System in Docker Compose

## Note

Never use the `--force-recreate` flag since it causes metadata mismatch errors. Instead stop then start the stack.

```bash
docker compose down
docker compose up -d
```
