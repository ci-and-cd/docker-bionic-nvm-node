#!/usr/bin/env bash

set -e

docker version
docker-compose version

WORK_DIR=$(pwd)

if [ -n "${CI_OPT_DOCKER_REGISTRY_PASS}" ] && [ -n "${CI_OPT_DOCKER_REGISTRY_USER}" ]; then
    echo ${CI_OPT_DOCKER_REGISTRY_PASS} | docker login --password-stdin -u="${CI_OPT_DOCKER_REGISTRY_USER}" docker.io
fi

# IMAGE_TAG
export IMAGE_TAG=${IMAGE_ARG_NODE_VERSION:-9.11.1}
if [ "${TRAVIS_BRANCH}" != "master" ]; then export IMAGE_TAG=${IMAGE_TAG}-SNAPSHOT; fi

# Build builder image
BUILDER_IMAGE_NAME=tmp/builder
if [[ "$(docker images -q ${BUILDER_IMAGE_NAME}:${IMAGE_TAG} 2> /dev/null)" == "" ]]; then
    docker-compose build builder
fi

# Process builder image layers
LAYERS=()
docker save ${BUILDER_IMAGE_NAME}:${IMAGE_TAG} > /tmp/builder.tar
rm -rf /tmp/builder && mkdir -p /tmp/builder && tar -xf /tmp/builder.tar -C /tmp/builder
for layer in /tmp/builder/*/layer.tar; do
    echo layer: ${layer}
    tar -tf ${layer} | grep -E '^/dev(/)?.*/$' | sort -r -n
    for element in $(tar -tf ${layer} | grep -E '^dev/.*' | sort -r -n); do echo delete ${element}; tar --delete -f ${layer} "${element}" > /dev/null 2>&1 || echo error on delete ${element}; done
    #mkdir -p $(dirname ${layer})/layer && tar -xf ${layer} -C $(dirname ${layer})/layer
    if [ -n "$(tar -tf ${layer} | grep "opt/node-v${IMAGE_ARG_NODE_VERSION:-9.11.1}-linux-x64")" ]; then echo found node-v${IMAGE_ARG_NODE_VERSION:-9.11.1}-linux-x64 in ${layer}; LAYERS+=(${layer}); fi
    if [ -n "$(tar -tf ${layer} | grep "\\.nvm")" ]; then echo found .nvm in ${layer}; LAYERS+=(${layer}); fi
done
echo -e "merge layers '${LAYERS[@]}' into one\n"
if [ ${#LAYERS[@]} -gt 0 ]; then tar Af ${LAYERS[@]}; fi
echo -e "layers merged into ${LAYERS[0]} $(du -sh ${LAYERS[0]})\n"

# Build dumper image
echo copy ${LAYERS[0]} to $(pwd)/data/layer.tar
cp -f ${LAYERS[0]} data/layer.tar

#echo find empty directories
#tar_entries=($(tar tf data/layer.tar))
#tar_directories=($(tar tf data/layer.tar | grep -E '.*/$' | sort -r -n))
#tar_empty_directories=()
#for directory in ${tar_directories[@]}; do
#    if [ -z "$(printf -- '%s\n' "${tar_entries[@]}" | grep -E "${directory}.+")" ]; then tar_empty_directories+=(${directory}); fi
#done
#echo tar_empty_directories
#printf -- '%s\n' "${tar_empty_directories[@]}"
#tar --delete -f data/layer.tar "${tar_empty_directories[@]}"
docker-compose build dumper

# Build final image
docker-compose build bionic-nvm-node
docker-compose push bionic-nvm-node
