#!/usr/bin/env bash
set -euo pipefail

project_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_root="$project_root/hackathon/upstream/apps/web/callproof"

mkdir -p "$package_root/rails" "$package_root/call_analyzer" "$package_root/contracts"

rsync -a --delete \
  --exclude '.bundle/' \
  --exclude '.env' \
  --exclude 'config/master.key' \
  --exclude 'coverage/' \
  --exclude 'log/*' \
  --exclude 'storage/*' \
  --exclude 'tmp/*' \
  --exclude 'vendor/bundle/' \
  "$project_root/apps/web/" "$package_root/rails/"

rsync -a --delete \
  --exclude '.env' \
  --exclude '.pytest_cache/' \
  --exclude '.venv/' \
  --exclude '__pycache__/' \
  --exclude '*.db' \
  "$project_root/services/call_analyzer/" "$package_root/call_analyzer/"

rsync -a --delete "$project_root/contracts/" "$package_root/contracts/"

printf 'Generated from the CallProof monorepo. Do not edit copied runtime files here.\n' \
  > "$package_root/.generated-from-monorepo"

