# syntax=docker/dockerfile:1

#FROM nvidia/cuda:12.5.1-cudnn-devel-ubuntu22.04
FROM nvidia/cuda:12.5.1-cudnn-devel-ubuntu20.04
WORKDIR /
RUN apt-get -y update
RUN apt-get -y install libnuma-dev 
RUN apt-get -y install fuse3 
RUN apt-get -y install libkeyutils-dev 
RUN apt-get -y install libaio-dev 
# RUN apt-get -y install libssl3
RUN apt-get -y install libssl-dev

COPY onenode_logging_config.yaml /opt/inferx/config/onenode_logging_config.yaml
COPY node.json /opt/inferx/config/node.json
COPY libnvmedrv.so /usr/lib/libnvmedrv.so
COPY . .
CMD ["./onenode"]