
FROM cirepo/nix:2.2.1-bionic


ARG IMAGE_ARG_FILESERVER
ARG IMAGE_ARG_NODE_VERSION
ARG IMAGE_ARG_NVM_VERSION
ARG IMAGE_ARG_NVM_NODEJS_ORG_MIRROR
ARG IMAGE_ARG_NVM_IOJS_ORG_MIRROR


USER root


COPY docker /data


## install global node.js
RUN ls -l /data \
    && NODE_VERSION="v${IMAGE_ARG_NODE_VERSION:-10.15.3}" \
    && mkdir -p /opt \
    && if [ ! -f /data/node-${NODE_VERSION}-linux-x64.tar.xz ]; then \
           touch /data/downloadmark; \
           ${ARIA2C_DOWNLOAD} -d /data -o node-${NODE_VERSION}-linux-x64.tar.xz ${IMAGE_ARG_FILESERVER:-https://nodejs.org}/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz; \
       fi \
    && tar xf /data/node-${NODE_VERSION}-linux-x64.tar.xz -C /opt \
    && ln -sf /opt/node-${NODE_VERSION}-linux-x64 /opt/node \
    && if [ -f /data/downloadmark ]; then rm -f /data/node-${NODE_VERSION}-linux-x64.tar.xz; fi


USER ubuntu


## install node.js for current user
RUN set -ex \
  && echo "TODO fix git's 'Problem with the SSL CA cert' issue" \
  && git config --global http.sslverify false \
  && curl -o- https://raw.githubusercontent.com/creationix/nvm/v${IMAGE_ARG_NVM_VERSION:-0.34.0}/install.sh | bash \
  && touch ~/.profile \
  && echo 'export NVM_DIR="$HOME/.nvm"\n\
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm\n\
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion\
  ' | tee -a ~/.profile \
  && sudo cp /home/$(whoami)/.profile /root/.profile && sudo chown root:root /root/.profile \
  && . ~/.nvm/nvm.sh \
  && export NVM_NODEJS_ORG_MIRROR="${IMAGE_ARG_NVM_NODEJS_ORG_MIRROR:-https://nodejs.org/dist}" \
  && echo NVM_NODEJS_ORG_MIRROR ${NVM_NODEJS_ORG_MIRROR} \
  && export NVM_IOJS_ORG_MIRROR="${IMAGE_ARG_NVM_IOJS_ORG_MIRROR:-https://iojs.org/dist}" \
  && echo NVM_IOJS_ORG_MIRROR ${NVM_IOJS_ORG_MIRROR} \
  && sudo -E bash -l -c "nvm install ${IMAGE_ARG_NODE_VERSION:-10.15.3}" \
  && sudo chown -R $USER:$(id -gn $USER) /home/$(whoami)
