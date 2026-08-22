#!/bin/bash
# install.sh — set up the computer-control stack for Hermes Agent on this Mac.
set -euo pipefail
DEST="${HERMES_HOME:-$HOME/.hermes}"
SRC="$(cd "$(dirname "$0")" && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> 1/4 Installing macos-harness CLI (uv)"
command -v macos-harness >/dev/null || {
  command -v uv >/dev/null || brew install uv
  uv tool install --python 3.12 macos-harness
}

echo "==> 2/4 Copying skill into $DEST/skills/"
mkdir -p "$DEST/skills/apple"
rm -rf "$DEST/skills/apple/macos-harness"
cp -R "$SRC/skills/apple/macos-harness" "$DEST/skills/apple/macos-harness"

echo "==> 3/4 Generating policy file with detected hardware"
if [ ! -s "$DEST/computer-control-policy.md" ]; then
  "$SRC/scripts/detect-hardware.sh" > "$TMP/hardware.md"
  # Splice hardware block over the {{HARDWARE_BASELINE}} marker line.
  # awk getline-from-file: fully portable, no escaping pitfalls.
  awk -v hwfile="$TMP/hardware.md" '
    /\{\{HARDWARE_BASELINE\}\}/ { while ((getline line < hwfile) > 0) print line; next }
    { print }
  ' "$SRC/computer-control-policy.template.md" > "$TMP/policy.md"
  [ -s "$TMP/policy.md" ] || { echo "ERROR: policy generation produced an empty file" >&2; exit 1; }
  grep -q '^Version:' "$TMP/policy.md" || { echo "ERROR: generated policy has no Version line" >&2; exit 1; }
  mkdir -p "$DEST"
  mv "$TMP/policy.md" "$DEST/computer-control-policy.md"   # atomic: no zombie empty files
else
  echo "    policy exists and is non-empty — leaving untouched"
fi

echo "==> 4/4 Stamping ladder into all agent SOUL.md files"
"$SRC/scripts/stamp-computer-control.sh" "$DEST"

cat <<'EOF'

Done. Remaining manual steps:
  1. System Settings -> Privacy & Security -> grant Accessibility and
     Screen & System Audio Recording to your terminal / agent host app.
  2. Verify:        macos-harness doctor          (expect all true)
  3. Live test:     echo 'print(mac.see("Finder"))' | macos-harness
  4. Restart your Hermes gateway so agents reload souls + skills.
EOF
