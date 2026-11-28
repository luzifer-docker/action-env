FROM debian:13.8-slim@sha256:8aa5a7bf5a1955bddbe7d74fcdd0b91ab30e74362a8b73af672b0481b35b44a0 AS base

# We need those in the builder before setting up apt repos and we need
# those in the final image, so keep them in the base
RUN <<-EOF
  set -ex

  apt-get update
  apt-get install --assume-yes --no-install-recommends \
    ca-certificates \
    curl \
    gnupg \
    unzip

  apt-get autoremove --assume-yes --purge
  apt-get clean --assume-yes
EOF


FROM golang:1.27.4@sha256:5f1b98fa02fe396ebce2a0227a0e08309e11792915b9dd2e1f71053d7e7e6666 AS gobuilder

ENV CGO_ENABLED=0 \
    GOBIN=/rootfs/usr/local/bin \
    GOTOOLCHAIN=local \
    GOPRIVATE=git.luzifer.io

SHELL ["/usr/bin/env", "bash", "-euxo", "pipefail", "-c"]
RUN <<-EOF
  function goinst() {
    go install \
      -trimpath \
      -buildvcs=false \
      -ldflags="-s -w -buildid=" \
      "$@"
  }

  goinst git.luzifer.io/luzifer/runner-wrap@latest
EOF


FROM base AS builder

ARG GOLANG_VERSION=1.27.4  # renovate: packageName=golang datasource=golang-version
ARG GOLANGCI_LINT_VERSION=2.15.0  # renovate: packageName=golangci/golangci-lint datasource=github-releases
ARG GOYQ_VERSION=4.54.3  # renovate: packageName=mikefarah/yq datasource=github-releases
ARG HELM_VERSION=4.3.2  # renovate: packageName=helm/helm datasource=github-releases
ARG NODE_VERSION=26.13.1  # renovate: packageName=node datasource=node-version
ARG ORAS_VERSION=1.4.0  # renovate: packageName=oras-project/oras datasource=github-releases
ARG SYFT_VERSION=1.57.2  # renovate: packageName=anchore/syft datasource=github-releases
ARG VAULT_VERSION=2.2.2  # renovate: packageName=hashicorp/vault datasource=github-releases

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install uv and uvx from the OCI image
COPY --from=ghcr.io/astral-sh/uv:0.13.10@sha256:a3ea1357342c1a4bf9a0c53a3deb1b55379aefa037338d8113d5771efa01774f \
  /uv /uvx \
  /rootfs/usr/local/bin/

# Install pnpm from the OCI image
COPY --from=ghcr.io/luzifer-docker/pnpm:v11.29.0@sha256:4e5c519184be6cdf9056d91b87ceca366fdcf124d96c166a01ab8ddeebc17da9 \
  / \
  /rootfs/

# Install kubectl from the OCI image
COPY --from=ghcr.io/luzifer-docker/kubectl:v1.37.2@sha256:5f5c210896d967fde058727e13bf52148ccb423573b1ee820e714ff931ab2173 \
  /usr/local/bin/kubectl \
  /rootfs/usr/local/bin/

# Install Forgejo-Runner binary from the OCI image
COPY --from=code.forgejo.org/forgejo/runner:13.2.2@sha256:a8543a45fe62bebef0534d5c223cf485d3294e6dd2e42a82dbcbfd40c54a6a22 \
  /bin/forgejo-runner \
  /rootfs/usr/local/bin/

# Setup APT repos
RUN <<-EOF
  CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

  # Docker
  curl -fsSL https://download.docker.com/linux/debian/gpg |
    install -Dm0644 /dev/stdin /rootfs/etc/apt/keyrings/docker.asc
  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${CODENAME} stable" |
    install -Dm0644 /dev/stdin /rootfs/etc/apt/sources.list.d/docker.list

  # NodeJS through NodeSource
  curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key |
    gpg --dearmor -o /rootfs/etc/apt/keyrings/nodesource.gpg
  echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION%%.*}.x nodistro main" |
    install -Dm0644 /dev/stdin /rootfs/etc/apt/sources.list.d/nodesource.list

  # Trivy
  curl -sSfL https://aquasecurity.github.io/trivy-repo/deb/public.key |
    gpg --dearmor -o /rootfs/etc/apt/keyrings/trivy.gpg
  echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb generic main" |
    install -Dm0644 /dev/stdin /rootfs/etc/apt/sources.list.d/trivy.list
EOF

# Install Golang
RUN <<-EOF
  curl -sSfL "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" | \
    tar -C /rootfs/usr/local -xz
EOF

# Install golangci-lint
RUN <<-EOF
  curl -sSfL "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz" | \
    tar -C /rootfs/usr/local/bin -xz --strip-components=1 --wildcards '*/golangci-lint'
EOF

# Install go-yq
RUN <<-EOF
  curl -sSfL "https://github.com/mikefarah/yq/releases/download/v${GOYQ_VERSION}/yq_linux_amd64" |
    install -Dm0755 /dev/stdin /rootfs/usr/local/bin/yq
EOF

# Install Helm
RUN <<-EOF
  curl -sSfL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" |
    tar -C /rootfs/usr/local/bin -xz --strip-components=1 --wildcards '*/helm'
EOF

# Install oras
RUN <<-EOF
  curl -sSfL "https://github.com/oras-project/oras/releases/download/v${ORAS_VERSION}/oras_${ORAS_VERSION}_linux_amd64.tar.gz" |
    tar -C /rootfs/usr/local/bin -xz oras
EOF

# Install syft
RUN <<-EOF
  curl -sSfL "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_amd64.tar.gz" |
    tar -C /rootfs/usr/local/bin -xz syft
EOF

# Install vault
RUN <<-EOF
  vault_tmp=$(mktemp -d)
  curl -sSfLo ${vault_tmp}/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
  unzip ${vault_tmp}/vault.zip vault -d /rootfs/usr/local/bin
EOF

COPY --from=gobuilder /rootfs/ /rootfs/

# Install base files from local repo
COPY rootfs/ /rootfs/


FROM base

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    GOTOOLCHAIN=local \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin \
    PNPM_CONFIG_UPDATE_NOTIFIER=false

# Install compiled rootfs
COPY --from=builder /rootfs/ /

# Install the final list of packages
RUN set -ex \
 && apt-get update \
 && apt-get install --assume-yes --no-install-recommends \
      ansible-core \
      build-essential \
      diffutils \
      gawk \
      git \
      git-crypt \
      git-lfs \
      jq \
      less \
      make \
      openssh-client \
      pkg-config \
      python3 \
      python3-venv \
      rsync \
      skopeo \
      sudo \
      tar \
      zip \
      \
      docker-buildx-plugin \
      docker-ce-cli \
      nodejs \
      trivy \
 && apt-get autoremove --assume-yes --purge \
 && apt-get clean --assume-yes

# Create runner user
RUN useradd \
  --create-home \
  --home-dir=/home/ci \
  --shell=/usr/bin/bash \
  --uid=1000 \
  --user-group \
  ci
