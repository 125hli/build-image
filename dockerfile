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
    && tar -xzvf docker.tgz -C /usr/local/bin --strip-components=1 \
    && chmod +x /usr/local/bin/docker* \
    && pip3 install --no-cache-dir "docker-compose==${DOCKER_COMPOSE_VERSION}" \
    && rm -rf /var/cache/apk/* docker.tgz

# === Stage 3: final stage based on cytopia/ansible:latest-tools ===
FROM cytopia/ansible:latest-tools

RUN apk add --no-cache rsync sshpass py3-pip \
    && pip3 install --no-cache-dir jsondiff netaddr pexpect docker-compose \
    && rm -rf /var/cache/apk/*

COPY --from=terraform-builder /terraform /usr/local/bin/terraform
COPY --from=docker-builder /usr/local/bin/docker /usr/local/bin/docker

RUN chmod +x /usr/local/bin/terraform /usr/local/bin/docker \
    && terraform version \
    && docker --version \
    && docker-compose --version

WORKDIR /data

ENTRYPOINT ["/bin/bash"]
