FROM harbor.tuxgrid.com/docker.io/ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    jq \
    python3 \
    && rm -rf /var/lib/apt/lists/*

CMD ["cat"]
