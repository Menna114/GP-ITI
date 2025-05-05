FROM docker:dind

USER root

# Install dependencies
RUN apk add --no-cache aws-cli curl wget

# Download Trivy release binary manually (Alpine-compatible)
ENV TRIVY_VERSION=0.50.1
RUN wget https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
    tar zxvf trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz && \
    mv trivy /usr/local/bin/ && \
    rm -f trivy_${TRIVY_VERSION}_Linux-64bit.tar.gz

# Verify install
RUN trivy --version
