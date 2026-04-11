#!/usr/bin/env bash
set -euo pipefail

FORK_PREFIX="github.com/ionawr/catppuccin-userstyles"
errors=0

# check url rewrites applied (spot-check one userstyle)
sample=$(ls styles/*/catppuccin.user.less | head -1)
if ! grep -q "$FORK_PREFIX" "$sample"; then
  echo "ERROR: URL rewrite failed in $sample"
  errors=$((errors + 1))
fi

# check palette was fetched and applied (upstream mocha has #1e1e2e for base, ours doesn't)
if grep -q '@base: #1e1e2e' lib/lib.less; then
  echo "ERROR: Palette replacement failed in lib/lib.less (still has upstream mocha)"
  errors=$((errors + 1))
fi

# check filters were replaced (spot-check mocha filter for fork-specific value)
if ! grep -q '@base: brightness(0) saturate(100%) invert(0%) sepia(48%)' lib/lib.less; then
  echo "ERROR: Mocha filter replacement failed in lib/lib.less"
  errors=$((errors + 1))
fi

# check codeberg fix applied (if codeberg style exists)
if [ -f styles/codeberg/catppuccin.user.less ]; then
  if ! grep -q '_urlAccent' styles/codeberg/catppuccin.user.less; then
    echo "ERROR: Codeberg fix failed"
    errors=$((errors + 1))
  fi
fi

# check flavour selectors were patched
if grep -q 'frappe:Frappé' "$sample"; then
  echo "ERROR: Flavour selector still contains frappe in $sample"
  errors=$((errors + 1))
fi

if [ "$errors" -gt 0 ]; then
  echo "FAILED: $errors validation error(s)"
  exit 1
fi

echo "All patches applied and validated successfully."
