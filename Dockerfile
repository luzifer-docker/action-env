FROM debian:12.11-slim@sha256:b1a741487078b369e78119849663d7f1a5341ef2768798f7b7406c4240f86aef

ARG GOLANG_VERSION=1.25.0 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.4.0 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.47.1 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.18.5 # renovate: packageName=helm/latest
ARG NODE_VERSION=22.18.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.20.2 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
