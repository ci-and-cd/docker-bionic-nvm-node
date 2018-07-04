# docker-bionic-nvm-node

Node.js (nvm) for multi-stage docker image build.

Dockerfile [ci-and-cd/docker-bionic-nvm-node on Github](https://github.com/ci-and-cd/docker-bionic-nvm-node)

[cirepo/bionic-nvm-node on Docker Hub](https://hub.docker.com/r/cirepo/bionic-nvm-node/)

## Use this image as a “stage” in multi-stage builds

```dockerfile

FROM alpine:3.7
COPY --from=cirepo/bionic-nvm-node:9.11.1-archive /data/root /
RUN sudo chown -R $(whoami):$(id -gn) /home/$(whoami) \
  && touch /home/$(whoami)/.bash_profile \
  && echo '\
export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\
' >> /home/$(whoami)/.bash_profile

```
