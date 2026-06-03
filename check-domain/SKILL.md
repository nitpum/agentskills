---
name: check-domain
description: Check domain availability. Use when user asks if a domain is available or taken.
---

# check-domain

Check domain availability via Cloudflare DoH. NXDOMAIN (Status 3) = likely available, resolves = taken. This is DNS-based heuristic only, not WHOIS.

## Script

```bash
bash scripts/check-domain.sh [--json|--quiet] <domain> [domain ...]
```

## Fallback (inline)

If the script cannot run, use this one-liner per domain:

```bash
d="example.com"; s=$(curl -sfH "Accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=$d&type=A"); [ "$(echo "$s" | jq -r '.Status')" = "3" ] && echo "✅ $d" || echo "❌ $d"
```

## Gotchas

- DNS check only. A registered domain with no records will appear "available".
- Requires `curl` and `jq`.
- Cloudflare rate-limits DoH; add delays for bulk checks (>20 domains).
