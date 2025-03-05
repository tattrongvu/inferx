# syntax=docker/dockerfile:1

FROM nvidia/cuda:12.5.1-cudnn-devel-ubuntu20.04
#FROM nvidia/cuda:12.5.1-cudnn-devel-ubuntu22.04
WORKDIR /
RUN apt-get -y update
RUN apt-get -y install libnuma-dev fuse3 libkeyutils-dev libaio-dev

COPY onenode_logging_config.yaml /opt/inferx/config/onenode_logging_config.yaml
COPY node.json /opt/inferx/config/node.json
COPY libnvmedrv.so /usr/lib/libnvmedrv.so
COPY . .
CMD ["./onenode"]