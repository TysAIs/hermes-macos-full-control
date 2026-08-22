#!/bin/bash
# stamp-computer-control.sh — propagate the compact computer-control ladder
# from your policy file into EVERY agent SOUL.md (root + all profiles).
# Idempotent: safe to re-run. Backs up each SOUL.md first.
#
# Usage: scripts/stamp-computer-control.sh [HERMES_HOME]
set -euo pipefail

HERMES_HOME="${1:-${HERMES_HOME:-$HOME/.hermes}}"
POLICY="$HERMES_HOME/computer-control-policy.md"
[ -f "$POLICY" ] || { echo "ERROR: $POLICY not found" >&2; exit 1; }

VERSION=$(grep -m1 '^Version:' "$POLICY" | awk '{print $2}')
[ -n "$VERSION" ] || { echo "ERROR: no 'Version:' line in $POLICY" >&2; exit 1; }

BLOCK_START="<!-- BEGIN computer-control v$VERSION (generated — do not hand-edit) -->"
BLOCK_END="<!-- END computer-control -->"

LADDER='## Computer control (this machine)
You operate this Mac via a strict priority ladder: (1) a targeted CLI/skill if one exists — always cheapest and most reliable; (2) known AppleScript/JXA via osascript or mac.script(); (3) native-app GUI work via the macos-harness skill (`macos-harness <<'"'"'PY'"'"' ... PY` with mac.see/key/type/click/ax) — works on background windows without stealing focus or the cursor; (4) web tasks via your configured browser-automation workflow; (5) full-screen computer-use drivers as fallback only. Never move the physical cursor or force apps foreground. After one failed verified burst, switch approach — never repeat failed input. Permission errors: tell the user exactly which System Settings toggle to grant; do not retry.'

STAMP_ONE() {
  local soul="$1"
  [ -f "$soul" ] || { echo "SKIP (missing): $soul"; return; }
  cp "$soul" "$soul.bak-stamp-$(date +%Y%m%d-%H%M%S)"
  python3 - "$soul" <<'PYEOF'
import pathlib, re, sys
p = pathlib.Path(sys.argv[1])
t = p.read_text()
t = re.sub(r"\n?<!-- BEGIN computer-control v.*?<!-- END computer-control -->\n?", "\n", t, flags=re.S)
p.write_text(t.rstrip("\n") + "\n")
PYEOF
  { echo ""; echo "$BLOCK_START"; echo "$LADDER"; echo "$BLOCK_END"; } >> "$soul"
  echo "STAMPED v$VERSION -> $soul"
}

STAMP_ONE "$HERMES_HOME/SOUL.md"
for soul in "$HERMES_HOME"/profiles/*/SOUL.md; do
  STAMP_ONE "$soul"
done

echo "Done. SSOT: $POLICY (v$VERSION). Edit the policy, re-run this script."
