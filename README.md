```Dockerfile
# set up port env var
ARG PORT
ENV PORT=$PORT
```

```bash
docker build --platform=linux/amd64 -t aws-node-app .
docker run -e PORT=80 -p 80:80 aws-node-app:latest

# --platform=linux/amd64
```
