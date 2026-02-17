FROM debian:13.3-slim@sha256:f6e2cfac5cf956ea044b4bd75e6397b4372ad88fe00908045e9a0d21712ae3ba

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

COPY --from=ghcr.io/astral-sh/uv:0.10.4@sha256:4cac394b6b72846f8a85a7a0e577c6d61d4e17fe2ccee65d9451a8b3c9efb4ac /uv /uvx /usr/local/bin/
