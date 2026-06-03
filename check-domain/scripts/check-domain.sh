#!/usr/bin/env bash
set -euo pipefail

show_help() {
  cat <<EOF
Usage: check-domain.sh [OPTIONS] <domain> [domain ...]

Check domain availability via Cloudflare DNS-over-HTTPS.
NXDOMAIN (Status 3) = likely available | Resolves = taken.

Options:
  --help     Show this help message
  --json     Output results as JSON
  --quiet    Only show available domains

Examples:
  check-domain.sh example.com example.org
  check-domain.sh --json example.com
  check-domain.sh --quiet myproject.dev myproject.app
EOF
}

json_output=0
quiet=0
domains=()

for arg in "$@"; do
  case "$arg" in
    --help)  show_help; exit 0 ;;
    --json)  json_output=1 ;;
    --quiet) quiet=1 ;;
    -*)      echo "Unknown option: $arg" >&2; show_help; exit 1 ;;
    *)       domains+=("$arg") ;;
  esac
done

if [ ${#domains[@]} -eq 0 ]; then
  echo "Error: no domains specified" >&2
  show_help >&2
  exit 1
fi

check_domain() {
  local domain="$1"
  local response
  response=$(curl -sfH "Accept: application/dns-json" \
    "https://cloudflare-dns.com/dns-query?name=$domain&type=A" 2>/dev/null) || true

  if [ -z "$response" ]; then
    echo "error|$domain|query failed"
    return
  fi

  local status
  status=$(echo "$response" | jq -r '.Status')

  if [ "$status" = "3" ]; then
    echo "available|$domain|NXDOMAIN"
  elif [ "$status" = "0" ]; then
    local ip
    ip=$(echo "$response" | jq -r '.Answer[0].data // "none"')
    echo "taken|$domain|$ip"
  else
    echo "unknown|$domain|status=$status"
  fi
}

if [ "$json_output" -eq 1 ]; then
  results="["
  first=1
  for d in "${domains[@]}"; do
    IFS='|' read -r status domain detail <<< "$(check_domain "$d")"
    [ $first -eq 0 ] && results+=","
    first=0
    results+=$(jq -n \
      --arg domain "$domain" \
      --arg status "$status" \
      --arg detail "$detail" \
      '{domain: $domain, status: $status, detail: $detail}')
  done
  results+="]"
  echo "$results" | jq .
else
  for d in "${domains[@]}"; do
    IFS='|' read -r status domain detail <<< "$(check_domain "$d")"
    case "$status" in
      available)
        [ "$quiet" -eq 0 ] && echo "✅ $domain (likely available)" || echo "$domain"
        ;;
      taken)
        [ "$quiet" -eq 0 ] && echo "❌ $domain (taken, resolves to $detail)"
        ;;
      error)
        echo "⚠️  $domain (error: $detail)" >&2
        ;;
      unknown)
        echo "❓ $domain ($detail)" >&2
        ;;
    esac
  done
fi
