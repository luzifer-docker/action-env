FROM debian:13.3-slim@sha256:1d3c811171a08a5adaa4a163fbafd96b61b87aa871bbc7aa15431ac275d3d430

ARG GOLANG_VERSION=1.26.0 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.10.1 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.52.4 # renovate: packageName=yq/latest
ARG HELM_VERSION=4.1.1 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.13.1 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.2 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh

COPY --from=ghcr.io/astral-sh/uv:0.10.6@sha256:2f2ccd27bbf953ec7a9e3153a4563705e41c852a5e1912b438fc44d88d6cb52c /uv /uvx /usr/local/bin/
