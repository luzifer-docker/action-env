#!/usr/bin/env bash
set -euo pipefail

dist_packages=(
  ansible-core
  build-essential
  ca-certificates
  curl
  diffutils
  gawk
  git
  git-crypt
  git-lfs
  gnupg
  less
  make
  openssh-client
  rsync
  sudo
  tar
  unzip
  zip
)

function apt_install() {
  apt-get update
  apt-get install \
    --assume-yes \
    --no-install-recommends \
    "$@"
}

function log() {
  echo "[$(date +%H:%M:%S)] $@" >&2
}

CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"

## Base System

log "Installing distro-packages..."
apt_install "${dist_packages[@]}"

## Docker

log "Installing Docker CLI..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian ${CODENAME} stable" >/etc/apt/sources.list.d/docker.list

apt_install docker-buildx-plugin docker-ce-cli

## Golang

log "Installing Golang ${GOLANG_VERSION}..."
curl -sSfL "https://go.dev/dl/go${GOLANG_VERSION}.linux-amd64.tar.gz" |
  tar -C /usr/local -xz

log "Installing golangci-lint ${GOLANGCI_LINT_VERSION}..."
curl -sSfL "https://github.com/golangci/golangci-lint/releases/download/v${GOLANGCI_LINT_VERSION}/golangci-lint-${GOLANGCI_LINT_VERSION}-linux-amd64.tar.gz" |
  tar -C /usr/local/bin -xz --strip-components=1 --wildcards '*/golangci-lint'

## go-yq

log "Installing go-yq ${GOYQ_VERSION}..."
curl -sSfLo /usr/local/bin/yq "https://github.com/mikefarah/yq/releases/download/v${GOYQ_VERSION}/yq_linux_amd64"
chmod 0755 /usr/local/bin/yq

## Helm

log "Installing Helm ${HELM_VERSION}..."
curl -sSfL "https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz" |
  tar -C /usr/local/bin -xz --strip-components=1 --wildcards '*/helm'

## Nodejs

curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION%%.*}.x nodistro main" >/etc/apt/sources.list.d/nodesource.list

apt_install nodejs

## Trivy

curl -sSfL https://aquasecurity.github.io/trivy-repo/deb/public.key | gpg --dearmor -o /etc/apt/keyrings/trivy.gpg
echo "deb [signed-by=/etc/apt/keyrings/trivy.gpg] https://aquasecurity.github.io/trivy-repo/deb ${CODENAME} main" >/etc/apt/sources.list.d/trivy.list

apt_install trivy

## Vault

vault_tmp=$(mktemp -d)
curl -sSfLo ${vault_tmp}/vault.zip "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip"
unzip ${vault_tmp}/vault.zip vault -d /usr/local/bin
rm -rf ${vault_tmp}

## Cleanup

log "Removing build-packages..."
apt-get remove \
  --assume-yes \
  --purge \
  "${build_packages[@]}"
apt-get autoremove \
  --assume-yes \
  --purge
apt-get clean \
  --assume-yes

## Unprivileged User
useradd -m -u 1000 -U ci
echo "ci ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/ci
