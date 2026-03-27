FROM debian:13.4-slim@sha256:26f98ccd92fd0a44d6928ce8ff8f4921b4d2f535bfa07555ee5d18f61429cf0c

ARG GOLANG_VERSION=1.26.1 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.11.4 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.52.5 # renovate: packageName=yq/latest
ARG HELM_VERSION=4.1.3 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.14.1 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.4 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh

COPY --from=ghcr.io/astral-sh/uv:0.11.1@sha256:fc93e9ecd7218e9ec8fba117af89348eef8fd2463c50c13347478769aaedd0ce /uv /uvx /usr/local/bin/
