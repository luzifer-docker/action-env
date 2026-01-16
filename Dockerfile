FROM debian:13.3-slim@sha256:77ba0164de17b88dd0bf6cdc8f65569e6e5fa6cd256562998b62553134a00ef0

ARG GOLANG_VERSION=1.25.6 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.8.0 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.50.1 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.19.2 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.13.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.2 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
