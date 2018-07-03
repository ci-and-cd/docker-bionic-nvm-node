# docker-bionic-nvm-node

Node.js (nvm) for multi-stage docker image build.

Dockerfile [ci-and-cd/docker-bionic-nvm-node on Github](https://github.com/ci-and-cd/docker-bionic-nvm-node)

[cirepo/bionic-nvm-node on Docker Hub](https://hub.docker.com/r/cirepo/bionic-nvm-node/)

## Use this image as a “stage” in multi-stage builds

```dockerfile
FROM alpine:3.7
COPY --from=cirepo/bionic-nvm-node:9.11.1-archive /data/root /
RUN sudo chown -R $(whoami):$(id -gn) /home/$(whoami)
```
