FROM debian:13.7-slim@sha256:a72b4433de1cf7d6bae0c4cee74d0547f58601a643b3375f070c51600d63b6b2 AS base

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

ARG GOLANG_VERSION=1.27.4  # renovate: packageName=golang datasource=golang-version
ARG GOLANGCI_LINT_VERSION=2.15.0  # renovate: packageName=golangci/golangci-lint datasource=github-releases
ARG GOYQ_VERSION=4.54.3  # renovate: packageName=mikefarah/yq datasource=github-releases
ARG HELM_VERSION=4.3.1  # renovate: packageName=helm/helm datasource=github-releases
ARG NODE_VERSION=26.13.1  # renovate: packageName=node datasource=node-version
ARG ORAS_VERSION=1.3.6  # renovate: packageName=oras-project/oras datasource=github-releases
ARG SYFT_VERSION=1.57.1  # renovate: packageName=anchore/syft datasource=github-releases
ARG VAULT_VERSION=2.2.1  # renovate: packageName=hashicorp/vault datasource=github-releases

SHELL ["/bin/bash", "-euxo", "pipefail", "-c"]

# Install uv and uvx from the OCI image
COPY --from=ghcr.io/astral-sh/uv:0.13.8@sha256:5cc1805e2426484abca4ad46ea783bab281fdb225fd82d8ce6d66a81254bac85 \
  /uv /uvx \
  /rootfs/usr/local/bin/

# Install pnpm from the OCI image
COPY --from=ghcr.io/luzifer-docker/pnpm:v11.28.11@sha256:15f1cb193c684b105a6410d8dde0ac13fba77f100315311bfc7775b720b194d5 \
  / \
  /rootfs/

# Install kubectl from the OCI image
COPY --from=ghcr.io/luzifer-docker/kubectl:v1.37.2@sha256:5f5c210896d967fde058727e13bf52148ccb423573b1ee820e714ff931ab2173 \
  /usr/local/bin/kubectl \
  /rootfs/usr/local/bin/

# Install Forgejo-Runner binary from the OCI image
COPY --from=code.forgejo.org/forgejo/runner:13.2.1@sha256:568cea8c15ddc01fc8f330124892f572af7db37fa28344a2c1914405793bf61d \
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
