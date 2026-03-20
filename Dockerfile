FROM debian:13.4-slim@sha256:26f98ccd92fd0a44d6928ce8ff8f4921b4d2f535bfa07555ee5d18f61429cf0c

ARG GOLANG_VERSION=1.26.1 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.11.3 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.52.4 # renovate: packageName=yq/latest
ARG HELM_VERSION=4.1.3 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.14.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.4 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh

COPY --from=ghcr.io/astral-sh/uv:0.10.12@sha256:72ab0aeb448090480ccabb99fb5f52b0dc3c71923bffb5e2e26517a1c27b7fec /uv /uvx /usr/local/bin/
