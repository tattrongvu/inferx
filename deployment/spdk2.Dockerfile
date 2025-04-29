# Use Ubuntu as the base image
FROM inferx/spdk-container:v0.1.0

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

COPY entrypoint.sh /spdk/entrypoint.sh

# Set working directory
WORKDIR /spdk


# Set up entrypoint to provide SPDK CLI tools
ENTRYPOINT bash /spdk/entrypoint.sh
