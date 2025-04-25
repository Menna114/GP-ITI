FROM docker:24-dind

USER root

# Install dependencies
RUN apk add --no-cache \
    bash \
    curl \
    unzip \
    python3 \
    py3-pip \
    groff \
    less \
    libc6-compat \
    libffi-dev \
    git \
    sudo \
    build-base

# Install Terraform
ARG TERRAFORM_VERSION=1.7.5
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/ && \
    chmod +x /usr/local/bin/terraform && \
    rm terraform.zip

# ✅ Install AWS CLI v1 (works with Alpine)
RUN pip3 install awscli --break-system-packages

# Verify tools
RUN aws --version && terraform -version && docker --version