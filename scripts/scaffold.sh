#!/usr/bin/env bash
# One-time setup of the Cloudflare Pages project.
# Safe to re-run — CF API returns an error if project exists, which we ignore.
#
# Usage:
#   ./scripts/scaffold.sh              # full setup
#   ./scripts/scaffold.sh --dry-run    # print actions without executing
#
# Requires: wrangler CLI (npx wrangler or global install), jq
# Values read from .env.local: CF_ACCOUNT_ID, CF_API_TOKEN, CF_PAGES_PROJECT, CF_CUSTOM_DOMAIN

set -euo pipefail

ENV_FILE=".env.local"
DRY_RUN=false

for arg in "$@"; do
  case $arg in
    --dry-run) DRY_RUN=true ;;
    --env=*) ENV_FILE="${arg#--env=}" ;;
  esac
done

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Error: $ENV_FILE not found. Copy .env.example to .env.local and fill it in." >&2
  exit 1
fi

# --- Parse env file ---
declare -A ENV
while IFS= read -r line; do
  [[ "$line" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${line// }" ]] && continue
  if [[ "$line" =~ ^([A-Za-z_][A-Za-z0-9_]*)=(.*)$ ]]; then
    key="${BASH_REMATCH[1]}"
    val="${BASH_REMATCH[2]}"
    val="${val#\"}" ; val="${val%\"}"
    val="${val#\'}" ; val="${val%\'}"
    ENV["$key"]="$val"
  fi
done < "$ENV_FILE"

get() { echo "${ENV[$1]:-}"; }

CF_ACCOUNT_ID="$(get CF_ACCOUNT_ID)"
CF_API_TOKEN="$(get CF_API_TOKEN)"
CF_PAGES_PROJECT="$(get CF_PAGES_PROJECT)"
CF_CUSTOM_DOMAIN="$(get CF_CUSTOM_DOMAIN)"

for var in CF_ACCOUNT_ID CF_API_TOKEN CF_PAGES_PROJECT; do
  if [[ -z "${ENV[$var]:-}" ]]; then
    echo "Error: $var not set in $ENV_FILE" >&2; exit 1
  fi
done

export CLOUDFLARE_API_TOKEN="$CF_API_TOKEN"
export CLOUDFLARE_ACCOUNT_ID="$CF_ACCOUNT_ID"

WRANGLER="npx wrangler"

cf_api() {
  local method="$1" path="$2" body="${3:-}"
  if $DRY_RUN; then
    echo "  [dry-run] $method https://api.cloudflare.com/client/v4$path"
    [[ -n "$body" ]] && echo "            $body"
    return
  fi
  if [[ -n "$body" ]]; then
    curl -sf -X "$method" "https://api.cloudflare.com/client/v4$path" \
      -H "Authorization: Bearer $CF_API_TOKEN" \
      -H "Content-Type: application/json" \
      -d "$body"
  else
    curl -sf -X "$method" "https://api.cloudflare.com/client/v4$path" \
      -H "Authorization: Bearer $CF_API_TOKEN"
  fi
}

# ============================================================
# 1. Create Pages project
# ============================================================
echo "==> Creating CF Pages project '$CF_PAGES_PROJECT'..."
if $DRY_RUN; then
  echo "  [dry-run] wrangler pages project create $CF_PAGES_PROJECT --production-branch=main"
else
  $WRANGLER pages project create "$CF_PAGES_PROJECT" --production-branch=main 2>&1 || \
    echo "  Project may already exist, continuing."
fi

# ============================================================
# 2. Custom domain
# ============================================================
if [[ -n "$CF_CUSTOM_DOMAIN" ]]; then
  echo ""
  echo "==> Adding custom domain: $CF_CUSTOM_DOMAIN..."

  ZONE_ID=$(cf_api GET "/zones?name=$(echo $CF_CUSTOM_DOMAIN | awk -F. '{print $(NF-1)"."$NF}')" \
    | jq -r '.result[0].id // empty')

  if [[ -z "$ZONE_ID" ]]; then
    echo "  Warning: zone not found for $CF_CUSTOM_DOMAIN — add the domain to your CF account first."
  else
    cf_api POST "/accounts/$CF_ACCOUNT_ID/pages/projects/$CF_PAGES_PROJECT/domains" \
      "{\"name\": \"$CF_CUSTOM_DOMAIN\"}" 2>/dev/null || \
      echo "  Custom domain may already be set."
    echo "  Done — CF will auto-provision SSL."
  fi
else
  echo ""
  echo "  Skipping custom domain (CF_CUSTOM_DOMAIN not set)"
fi

# ============================================================
echo ""
echo "Scaffolding complete."
echo ""
echo "Next steps:"
echo "  1. Run ./scripts/sync-secrets.sh to push CI secrets to GitHub"
echo "  2. Push to main to trigger your first deploy"
echo "  3. Preview URL: https://$CF_PAGES_PROJECT.pages.dev"
[[ -n "$CF_CUSTOM_DOMAIN" ]] && echo "  4. Custom domain: https://$CF_CUSTOM_DOMAIN (DNS may take a few minutes)"
