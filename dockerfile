FROM alpine:3.18

# 安装 bash, jq, ca-certificates, coreutils, findutils
RUN apk add --no-cache \
    bash \
    jq \
    curl \
    ca-certificates \
    coreutils \
    findutils

# 安装 Mike Farah 的 Go 版 yq
RUN curl -L https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
    -o /usr/bin/yq && chmod +x /usr/bin/yq

WORKDIR /work


ENTRYPOINT ["/bin/bash"]

