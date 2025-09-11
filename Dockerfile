FROM debian:12.12-slim@sha256:df52e55e3361a81ac1bead266f3373ee55d29aa50cf0975d440c2be3483d8ed3

ARG GOLANG_VERSION=1.25.1 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.4.0 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.47.2 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.19.0 # renovate: packageName=helm/latest
ARG NODE_VERSION=22.19.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.20.3 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
