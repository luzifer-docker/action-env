FROM debian:13.1-slim@sha256:9b6ccd28f4913155f35e10ecd4437347d86ebce4ecf5853b3568141468faec56

ARG GOLANG_VERSION=1.25.3 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.6.0 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.48.1 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.19.0 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.11.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.0 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
