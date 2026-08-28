#!/usr/bin/env bash
# Packages the chart in the current directory and pushes it to an OCI repository.
# A version that already exists there is left alone: registries with immutable
# tags reject the overwrite with a 412, and a publish re-run must not fail on it.
set -euo pipefail
target=$1
out=$(mktemp -d)
helm package . --destination "$out" >/dev/null
tgz=$(ls "$out"/*.tgz)
name=$(helm show chart "$tgz" | awk '/^name:/ {print $2}')
version=$(helm show chart "$tgz" | awk '/^version:/ {print $2}')
if helm show chart "$target/$name" --version "$version" >/dev/null 2>&1; then
  echo "$name $version already exists at $target, skipping"
  exit 0
fi
helm push "$tgz" "$target"
