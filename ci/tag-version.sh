#!/usr/bin/env bash
set -euo pipefail

readonly image='ghcr.io/luzifer-docker/action-env'
readonly base="$(date -u +%G.%V)"
readonly calverPattern='^[0-9]{4}[.][0-9]{2}[.][0-9]+$'

function digestForTag() {
  local tag=$1

  skopeo inspect "docker://${image}:${tag}" |
    jq -r '.Digest'
}

function getCounterValue() {
  local counter=$(
    listCalverTags |
      sed -nE "s/^${base//./\\.}\.([0-9]+)$/\1/p" |
      sort -nr |
      head -n1
  )

  [[ -z $counter ]] && printf '0' || printf '%d' "$((counter + 1))"
}

function getLatestCalverTag() {
  listCalverTags |
    sort -Vr |
    head -n1
}

function listCalverTags() {
  skopeo list-tags "docker://${image}" |
    jq -er '.Tags[]' |
    awk -v pattern="${calverPattern}" '$0 ~ pattern'
}

function log() {
  echo "[$(date +%H:%M:%S)] $@" >&2
}

function main() {
  log "Fetching master tag..."
  local master
  master=$(digestForTag master)

  log "Fetching latest calver-tag..."
  local latestCalver
  latestCalver=$(getLatestCalverTag)

  local calver=""
  if [[ -n $latestCalver ]]; then
    log "Found version '${latestCalver}', fetching digest..."
    calver=$(digestForTag "${latestCalver}")
  fi

  if [[ $calver == $master ]]; then
    log "Latest calver tag equals master: ${master}"
    return 0
  fi

  log "Getting next calver tag..."
  local nextTag="${base}.$(getCounterValue)"

  log "Re-tagging 'master' as '${nextTag}'..."
  skopeo copy --all --preserve-digests "docker://${image}@${master}" "docker://${image}:${nextTag}"
}

main
