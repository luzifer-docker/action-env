FROM debian:13.5-slim@sha256:b6e2a152f22a40ff69d92cb397223c906017e1391a73c952b588e51af8883bf8 AS base

# We need those in the builder before setting up apt repos and we need
# those in the final image, so keep them in the base
RUN set -ex \
 && apt-get update \
 && apt-get install --assume-yes --no-install-recommends \
      ca-certificates \
      curl \
      gnupg \
      unzip \
 && apt-get autoremove --assume-yes --purge \
 && apt-get clean --assume-yes


FROM base AS builder

ARG GOLANG_VERSION=1.26.3  # renovate: packageName=golang datasource=golang-version
ARG GOLANGCI_LINT_VERSION=2.12.2  # renovate: packageName=golangci/golangci-lint datasource=github-releases
ARG GOYQ_VERSION=4.53.2  # renovate: packageName=mikefarah/yq datasource=github-releases
ARG HELM_VERSION=4.2.0  # renovate: packageName=helm/helm datasource=github-releases
ARG NODE_VERSION=24.16.0  # renovate: packageName=node datasource=node-version
ARG ORAS_VERSION=1.3.2  # renovate: packageName=oras-project/oras datasource=github-releases
ARG SYFT_VERSION=1.44.0  # renovate: packageName=anchore/syft datasource=github-releases
ARG VAULT_VERSION=2.0.1  # renovate: packageName=hashicorp/vault datasource=github-releases

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install uv and uvx from the OCI image
COPY --from=ghcr.io/astral-sh/uv:0.11.19@sha256:b46b03ddfcfbf8f547af7e9eaefdf8a39c8cebcba7c98858d3162bd28cf536f6 \
  /uv /uvx \
  /rootfs/usr/local/bin/

# Install pnpm from the OCI image
COPY --from=ghcr.io/luzifer-docker/pnpm:v11.5.0@sha256:a6a78bb8214c9ac7362f4f55c40ccd012b666a1a0dfa2ee7dd12f8471c86021e \
  / \
  /rootfs/

# Install kubectl from the OCI image
COPY --from=ghcr.io/luzifer-docker/kubectl:v1.36.1@sha256:ef0ef57ae86b6343338d5bf4b350b07ab3183055fa59c47b4988ecd4872552e9 \
  /usr/local/bin/kubectl \
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

# Install base files from local repo
COPY rootfs/ /rootfs/


FROM base

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/go/bin:/go/bin

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
      less \
      make \
      openssh-client \
      pkg-config \
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
