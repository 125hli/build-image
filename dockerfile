# ==== Build Stage ====
FROM alpine:3.20 as terraform-builder

ARG TERRAFORM_VERSION=1.8.5

RUN apk add --no-cache curl unzip gnupg \
    && curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && chmod +x terraform \
    && mv terraform /usr/local/bin/terraform

# ==== Final Stage ====
FROM cytopia/ansible:latest-infra as final

# 安装基础工具以支持 terraform 运行（curl、unzip已包含在builder中）
USER root

# 如果 final 镜像中未包含 bash，可加上 bash：
RUN apk add --no-cache bash

# 从 build stage 复制 Terraform 可执行文件
COPY --from=terraform-builder /usr/local/bin/terraform /usr/local/bin/terraform

# 验证版本
RUN terraform version

# 默认工作目录（可选）
WORKDIR /data

# 设置非 root 用户（如果需要）
USER ansible

ENTRYPOINT ["/bin/bash"]

