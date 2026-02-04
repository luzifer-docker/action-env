FROM debian:13.3-slim@sha256:f6e2cfac5cf956ea044b4bd75e6397b4372ad88fe00908045e9a0d21712ae3ba

ARG GOLANG_VERSION=1.25.7 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.8.0 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.52.2 # renovate: packageName=yq/latest
ARG HELM_VERSION=4.1.0 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.13.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.2 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh

COPY --from=ghcr.io/astral-sh/uv:0.9.29@sha256:db9370c2b0b837c74f454bea914343da9f29232035aa7632a1b14dc03add9edb /uv /uvx /usr/local/bin/
