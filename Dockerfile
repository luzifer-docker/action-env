FROM debian:12.11-slim@sha256:2424c1850714a4d94666ec928e24d86de958646737b1d113f5b2207be44d37d8

ARG GOLANG_VERSION=1.24.6 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.3.1 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.47.1 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.18.4 # renovate: packageName=helm/latest
ARG NODE_VERSION=22.18.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.20.2 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
