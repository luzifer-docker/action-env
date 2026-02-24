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

COPY --from=ghcr.io/astral-sh/uv:0.10.5@sha256:476133fa2aaddb4cbee003e3dc79a88d327a5dc7cb3179b7f02cabd8fdfbcc6e /uv /uvx /usr/local/bin/
