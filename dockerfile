# === Stage 1: terraform builder (alpine) ===
FROM alpine:3.20 AS terraform-builder

ARG TERRAFORM_VERSION=1.8.5

RUN apk add --no-cache curl unzip \
    && curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && chmod +x terraform \
    && mv terraform /terraform \
    && rm -f terraform.zip

# === Stage 2: docker and docker-compose builder (alpine) ===
FROM alpine:3.20 AS docker-builder

ARG DOCKER_COMPOSE_VERSION=2.28.0

RUN apk add --no-cache curl py3-pip \
    && curl -fsSL https://download.docker.com/linux/static/stable/x86_64/docker-24.0.5.tgz -o docker.tgz \
    && tar -xzvf docker.tgz -C /usr/local/bin --strip-components=1 docker/docker \
    && chmod +x /usr/local/bin/docker \
    && pip3 install --no-cache-dir "docker-compose==${DOCKER_COMPOSE_VERSION}" \
    && rm -rf /var/cache/apk/* docker.tgz

# === Stage 3: final stage based on cytopia/ansible:latest-tools ===
FROM cytopia/ansible:latest-tools

# 安装依赖工具（rsync, sshpass, pexpect 依赖包）
RUN apk add --no-cache rsync sshpass py3-pip \
    # 安装 python 库 jsondiff netaddr pexpect docker-compose
    && pip3 install --no-cache-dir jsondiff netaddr pexpect docker-compose \
    # 清理缓存
    && rm -rf /var/cache/apk/*

# 复制 terraform 可执行文件
COPY --from=terraform-builder /terraform /usr/local/bin/terraform

# 复制 docker 可执行文件
COPY --from=docker-builder /usr/local/bin/docker /usr/local/bin/docker

# docker-compose 已用 pip 安装，已在 python 环境中

# 验证版本
RUN terraform version && docker --version && docker-compose --version

WORKDIR /data

ENTRYPOINT ["/bin/bash"]
