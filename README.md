# aws-node-app

===

- blueprint for node.js typescript fastify app
- deploy to AWS ECR via github actions by pushing to `production` branch

- setup terraform for installing AWS resource for the app.

[demo app site url](http://aws-node-app-load-balancer-384112307.eu-north-1.elb.amazonaws.com/)

[log: simple fastify app, deploy via github actions to AWS ECS](http://b-log-app-load-balancer-1189058679.eu-north-1.elb.amazonaws.com/posts/simple%20fastify%20app,%20deploy%20via%20github%20actions%20to%20AWS%20ECS.md)

## Run locally

```bash
docker build --platform=linux/amd64 -t aws-node-app .
docker run -e PORT=80 -p 80:80 aws-node-app:latest
```
