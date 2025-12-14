FROM debian:13.2-slim@sha256:e711a7b30ec1261130d0a121050b4ed81d7fb28aeabcf4ea0c7876d4e9f5aca2

ARG GOLANG_VERSION=1.25.5 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.7.2 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.50.1 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.19.2 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.12.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.1 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
