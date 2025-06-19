FROM debian:bookworm-slim


RUN apt-get update && \
apt-get install -y --no-install-recommends \
    bash \
    curl \
    jq \
    tar \
    gzip \
    xz-utils \
    openssl \
    ca-certificates \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
ENTRYPOINT ["/bin/bash"]
