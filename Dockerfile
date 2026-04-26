FROM debian:13.4-slim@sha256:cedb1ef40439206b673ee8b33a46a03a0c9fa90bf3732f54704f99cb061d2c5a

ARG GOLANG_VERSION=1.26.2 # renovate: packageName=golang/latest
ARG GOLANGCI_LINT_VERSION=2.11.4 # renovate: packageName=golangci-lint/latest
ARG GOYQ_VERSION=4.53.2 # renovate: packageName=yq/latest
ARG HELM_VERSION=4.1.4 # renovate: packageName=helm/latest
ARG NODE_VERSION=24.15.0 # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=2.0.0 # renovate: packageName=vault/latest

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

COPY --chown=root:root --chmod=700 build.sh /usr/sbin/build.sh
RUN /usr/sbin/build.sh

COPY --from=ghcr.io/astral-sh/uv:0.11.7@sha256:240fb85ab0f263ef12f492d8476aa3a2e4e1e333f7d67fbdd923d00a506a516a \
  /uv /uvx \
  /usr/local/bin/

COPY --from=ghcr.io/luzifer-docker/pnpm:v10.33.2@sha256:11b50efc9a57a215c6e33f6d20f27cf42004d06919a451bffae86a314db6fee8 \
  / \
  /

COPY --from=ghcr.io/luzifer-docker/kubectl:v1.36.0@sha256:d562d5e6b15fcf38626f81c5696ff1e47b281aa1800ce946e4a1ec6f9e3497bc \
  /usr/local/bin/kubectl \
  /usr/local/bin/
