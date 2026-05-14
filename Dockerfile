FROM harbor.tuxgrid.com/docker.io/ubuntu:24.04

ARG PLATFORM_CA_B64=""
ARG HTTPS_PROXY
ARG HTTP_PROXY

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    ca-certificates \
    curl \
    jq \
    python3 \
    && rm -rf /var/lib/apt/lists/*

RUN [ -z "$PLATFORM_CA_B64" ] || \
    (printf '%s' "$PLATFORM_CA_B64" | base64 -d > /usr/local/share/ca-certificates/platform-build.crt \
    && update-ca-certificates)

CMD ["cat"]
