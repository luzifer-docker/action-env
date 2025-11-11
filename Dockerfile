FROM debian:13.1-slim@sha256:a347fd7510ee31a84387619a492ad6c8eb0af2f2682b916ff3e643eb076f925a

ARG GOLANG_VERSION=1.25.4 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.6.1 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.48.1 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.19.1 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.11.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.21.0 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
