FROM debian:13.1-slim@sha256:66b37a5078a77098bfc80175fb5eb881a3196809242fd295b25502854e12cbec

ARG GOLANG_VERSION=1.25.3 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.5.0 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.48.1 # renovate: packageName=yq/latest
ARG HELM_VERSION=3.19.0 # renovate: packageName=helm/latest
ARG NODE_VERSION=22.21.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=1.20.4 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh
