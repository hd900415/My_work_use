#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  cat <<'EOF'
Usage:
  CLOUDFLARE_API_TOKEN=... ./cloudflare-import-zones.sh domains.txt

domains.txt format:
  example.com
  example.net

Optional env vars:
  CLOUDFLARE_ACCOUNT_ID   Cloudflare account id. If omitted, script will query /memberships and use the first account.
  CLOUDFLARE_JUMP_START   true|false, defaults to false
  CLOUDFLARE_TYPE         full|partial, defaults to full

Required token permissions:
  - Zone Zone Edit
  - Zone DNS Edit
  - Account Account Settings Read (recommended, for account discovery)
EOF
  exit 1
fi

if [[ -z "${CLOUDFLARE_API_TOKEN:-}" ]]; then
  echo "CLOUDFLARE_API_TOKEN is required" >&2
  exit 1
fi

domains_file="$1"
zone_type="${CLOUDFLARE_TYPE:-full}"
jump_start="${CLOUDFLARE_JUMP_START:-false}"

if [[ ! -f "$domains_file" ]]; then
  echo "domains file not found: $domains_file" >&2
  exit 1
fi

api_base="https://api.cloudflare.com/client/v4"
auth_header="Authorization: Bearer ${CLOUDFLARE_API_TOKEN}"

cf_api() {
  local method="$1"
  local path="$2"
  local data="${3:-}"

  if [[ -n "$data" ]]; then
    curl -fsS -X "$method" \
      -H "$auth_header" \
      -H "Content-Type: application/json" \
      "$api_base$path" \
      --data "$data"
  else
    curl -fsS -X "$method" \
      -H "$auth_header" \
      -H "Content-Type: application/json" \
      "$api_base$path"
  fi
}

account_id="${CLOUDFLARE_ACCOUNT_ID:-}"
if [[ -z "$account_id" ]]; then
  account_id="$(cf_api GET "/memberships" | jq -r '.result[0].account.id')"
fi

if [[ -z "$account_id" || "$account_id" == "null" ]]; then
  echo "failed to determine Cloudflare account id" >&2
  exit 1
fi

echo "Using Cloudflare account: $account_id"

while IFS= read -r raw_domain || [[ -n "$raw_domain" ]]; do
  domain="$(echo "$raw_domain" | xargs)"

  if [[ -z "$domain" || "$domain" =~ ^# ]]; then
    continue
  fi

  payload="$(jq -nc \
    --arg account_id "$account_id" \
    --arg name "$domain" \
    --arg type "$zone_type" \
    --argjson jump_start "$([[ "$jump_start" == "true" ]] && echo true || echo false)" \
    '{account:{id:$account_id}, name:$name, type:$type, jump_start:$jump_start}')"

  echo "Adding zone: $domain"
  response="$(cf_api POST "/zones" "$payload" || true)"

  if [[ -z "$response" ]]; then
    echo "  failed: empty response"
    continue
  fi

  success="$(echo "$response" | jq -r '.success // false')"
  if [[ "$success" != "true" ]]; then
    echo "  failed:"
    echo "$response" | jq -r '.errors[]? | "    - \(.message)"'
    continue
  fi

  zone_id="$(echo "$response" | jq -r '.result.id')"
  nameservers="$(echo "$response" | jq -r '.result.name_servers[]?' | paste -sd ', ' -)"

  echo "  ok: zone_id=$zone_id"
  if [[ -n "$nameservers" ]]; then
    echo "  change nameservers at registrar to: $nameservers"
  fi
done < "$domains_file"
