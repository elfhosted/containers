#!/usr/bin/env bash
set -euo pipefail

channel="${1:-}"
repo="mhdzumair/MediaFusion"
headers=(-H "Accept: application/vnd.github+json")
token="${TOKEN:-${GITHUB_TOKEN:-${GH_TOKEN:-}}}"
if [[ -n "${token}" ]]; then
  headers+=(-H "Authorization: Bearer ${token}")
fi

case "${channel}" in
  main)
    # HOLD (2026-10-24): 6.2.0 adds /api/v1/stream/, which returns info hashes
    # while HIDE_TORRENT_INFO_HASHES is off. Held until infra #23905 (which
    # closes that route on the public host) is merged. Remove this block then.
    printf "%s" "6.1.6"
    exit 0
    # Stable only: upstream sometimes has prerelease-looking tags that are not
    # marked prerelease, so filter tag names too.
    version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/${repo}/releases?per_page=100"       | jq -r '[.[] | select(.draft == false) | select(.tag_name | test("beta|alpha|rc|pre"; "i") | not)] | sort_by(.created_at) | last | .tag_name')
    ;;
  dev)
    version=$(curl -fsSL "${headers[@]}" "https://api.github.com/repos/${repo}/releases?per_page=100"       | jq -r '[.[] | select(.draft == false)] | sort_by(.created_at) | last | .tag_name')
    ;;
  *)
    echo "Invalid channel specified: ${channel}" >&2
    exit 1
    ;;
esac

version="${version#*v}"
if [[ -z "${version}" || "${version}" == "null" ]]; then
  echo "ERROR: mediafusion latest release resolved empty/null for ${channel}" >&2
  exit 1
fi
printf "%s" "${version}"