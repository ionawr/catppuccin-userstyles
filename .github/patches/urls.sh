#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_ORG="catppuccin"
UPSTREAM_REPO="userstyles"
FORK_OWNER="ionawr"
FORK_REPO="catppuccin-userstyles"

UPSTREAM_PREFIX="github.com/${UPSTREAM_ORG}/${UPSTREAM_REPO}"
FORK_PREFIX="github.com/${FORK_OWNER}/${FORK_REPO}"

UPSTREAM_URL="https://${UPSTREAM_PREFIX}"
FORK_URL="https://${FORK_PREFIX}"

UPSTREAM_LIB="https://userstyles.catppuccin.com/lib/lib.less"
FORK_LIB="https://raw.githubusercontent.com/${FORK_OWNER}/${FORK_REPO}/refs/heads/main/lib/lib.less"

for file in styles/*/catppuccin.user.less; do
  sed -i \
    -e "s|${UPSTREAM_PREFIX}/styles/|${FORK_PREFIX}/styles/|g" \
    -e "s|${UPSTREAM_URL}/tree/main/styles/|${FORK_URL}/tree/main/styles/|g" \
    -e "s|${UPSTREAM_URL}/raw/main/styles/|${FORK_URL}/raw/main/styles/|g" \
    -e "s|${UPSTREAM_URL}/issues|${FORK_URL}/issues|g" \
    -e "s|${UPSTREAM_LIB}|${FORK_LIB}|g" \
    "$file"
done

sed -i \
  -e "s|${UPSTREAM_PREFIX}/styles/|${FORK_PREFIX}/styles/|g" \
  -e "s|${UPSTREAM_URL}/tree/main/styles/|${FORK_URL}/tree/main/styles/|g" \
  -e "s|${UPSTREAM_URL}/raw/main/styles/|${FORK_URL}/raw/main/styles/|g" \
  -e "s|${UPSTREAM_URL}/issues|${FORK_URL}/issues|g" \
  -e "s|${UPSTREAM_LIB}|${FORK_LIB}|g" \
  -e "s|${UPSTREAM_URL}/blob/|${FORK_URL}/blob/|g" \
  template/catppuccin.user.less

sed -i \
  -e "s|${UPSTREAM_URL}|${FORK_URL}|g" \
  -e "s|${UPSTREAM_PREFIX}/styles/|${FORK_PREFIX}/styles/|g" \
  scripts/lint/metadata.ts

sed -i \
  -e "s|${UPSTREAM_URL}/issues|${FORK_URL}/issues|g" \
  scripts/generate/templates/userstyle.md
