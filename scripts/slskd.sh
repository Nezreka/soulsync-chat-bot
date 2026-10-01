#!/usr/bin/env bash
# Helpers for talking to the local slskd API (verified against slskd 0.26.0 source).
#   slskd_get <path>              GET /api/v0/<path>
#   slskd_post_room <room> <msg>   POST a raw JSON string to the room; expect HTTP 201
set -euo pipefail

SLSKD_URL="${SLSKD_URL:-http://127.0.0.1:5030}"
SLSKD_KEY_FILE="${SLSKD_KEY_FILE:-$HOME/.slskd_api_key}"

_api_key() {
    cat "$SLSKD_KEY_FILE"
}

slskd_get() {
    curl -sm 15 -H "X-API-Key: $(_api_key)" "$SLSKD_URL/api/v0/$1"
}

slskd_post_room() {
    local room="$1" msg="$2"
    local body
    body="$(python3 -c 'import json,sys; print(json.dumps(sys.argv[1]))' "$msg")"
    curl -sm 15 -o /dev/null -w "%{http_code}" \
        -H "X-API-Key: $(_api_key)" -H "Content-Type: application/json" \
        --data "$body" \
        "$SLSKD_URL/api/v0/rooms/joined/$room/messages"
}
