FROM debian:13.4-slim@sha256:cedb1ef40439206b673ee8b33a46a03a0c9fa90bf3732f54704f99cb061d2c5a

ARG GOLANG_VERSION=1.26.2  # renovate: packageName=golang datasource=golang-version
ARG GOLANGCI_LINT_VERSION=2.12.1  # renovate: packageName=golangci/golangci-lint datasource=github-releases
ARG GOYQ_VERSION=4.53.2  # renovate: packageName=mikefarah/yq datasource=github-releases
ARG HELM_VERSION=4.1.4  # renovate: packageName=helm/helm datasource=github-releases
ARG NODE_VERSION=24.15.0  # renovate: packageName=node datasource=node-version
ARG VAULT_VERSION=2.0.0  # renovate: packageName=hashicorp/vault datasource=github-releases

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

RUN --mount=type=bind,source=build.sh,target=/usr/sbin/build.sh,readonly \
  bash /usr/sbin/build.sh

COPY --from=ghcr.io/astral-sh/uv:0.11.8@sha256:3b7b60a81d3c57ef471703e5c83fd4aaa33abcd403596fb22ab07db85ae91347 \
  /uv /uvx \
  /usr/local/bin/

COPY --from=ghcr.io/luzifer-docker/pnpm:v10.33.2@sha256:11b50efc9a57a215c6e33f6d20f27cf42004d06919a451bffae86a314db6fee8 \
  / \
  /

COPY --from=ghcr.io/luzifer-docker/kubectl:v1.36.0@sha256:d562d5e6b15fcf38626f81c5696ff1e47b281aa1800ce946e4a1ec6f9e3497bc \
  /usr/local/bin/kubectl \
  /usr/local/bin/
