#!/bin/bash
# detect-hardware.sh — print a markdown hardware-baseline block for this Mac.
# Used by install.sh to fill the policy file with real specs.
set -euo pipefail

CHIP=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Apple Silicon")
MODEL_ID=$(sysctl -n hw.model 2>/dev/null || echo "unknown")
CORES=$(sysctl -n hw.ncpu 2>/dev/null || echo "?")
RAM_GB=$(( $(sysctl -n hw.memsize) / 1073741824 ))
OS_VER=$(sw_vers -productVersion)
OS_BUILD=$(sw_vers -buildVersion)
DISK_FREE=$(df -g /System/Volumes/Data | awk 'NR==2{print $4}')

BETA=""
[[ "$OS_BUILD" =~ [a-z]$ ]] && BETA=" (beta)"

cat <<EOF
- **Machine**: ${MODEL_ID}, ${CHIP}, ${CORES} cores
- **Memory**: ${RAM_GB} GB unified
- **Disk**: ~${DISK_FREE} GB free
- **OS**: macOS ${OS_VER}${BETA}
EOF
