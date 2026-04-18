FROM debian:13.4-slim@sha256:4ffb3a1511099754cddc70eb1b12e50ffdb67619aa0ab6c13fcd800a78ef7c7a

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

COPY --from=ghcr.io/luzifer-docker/pnpm:v10.33.0@sha256:37421bf6d0c9bb40c8fc3471b2ed1f2e7947b4668692713c7db8877feb840d8a \
  / \
  /

COPY --from=ghcr.io/luzifer-docker/kubectl:v1.35.3@sha256:dd74f6d8227c858f1a8465e41d7d1c1ed54e680a91e16d098ba50573969aa6fd \
  /usr/local/bin/kubectl \
  /usr/local/bin/
