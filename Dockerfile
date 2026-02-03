FROM debian:13.3-slim@sha256:bfc1a095aef012070754f61523632d1603d7508b4d0329cd5eb36e9829501290

ARG GOLANG_VERSION=1.25.6 # renovate: packageName=golang/latest
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

COPY --from=ghcr.io/astral-sh/uv:0.9.28@sha256:59240a65d6b57e6c507429b45f01b8f2c7c0bbeee0fb697c41a39c6a8e3a4cfb /uv /uvx /usr/local/bin/
