#!/bin/bash
# install.sh — set up the computer-control stack for Hermes Agent on this Mac.
set -euo pipefail
DEST="${HERMES_HOME:-$HOME/.hermes}"
SRC="$(cd "$(dirname "$0")" && pwd)"

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
if [ ! -f "$DEST/computer-control-policy.md" ]; then
  HW=$("$SRC/scripts/detect-hardware.sh")
  perl -e "\$s=shift; \$h=join(q{}, <>); \$s=~s/\{\{HARDWARE_BASELINE\}\}/\$h/g; print \$s" \
    "$SRC/computer-control-policy.template.md" <<< "" > /dev/null # noop guard
  awk -v hw="$HW" '{ gsub(/\{\{HARDWARE_BASELINE\}\}/, hw) }1' \
    "$SRC/computer-control-policy.template.md" > "$DEST/computer-control-policy.md"
else
  echo "    policy exists — leaving untouched"
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
