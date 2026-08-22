# Computer Control Policy — Single Source of Truth

Version: 2026-08-22.1
Owner: you. Edit ONLY this file, then run `scripts/stamp-computer-control.sh` to propagate the compact ladder into every agent's SOUL.md. Never hand-edit the stamped blocks inside SOUL.md files.

---

## Hardware baseline (this machine)

<!-- Filled automatically by scripts/detect-hardware.sh during install -->
{{HARDWARE_BASELINE}}

- **Role**: this Mac runs the agent fleet + desktop automation. Configure where heavy model inference lives (local server, cloud API) in your agent platform — not here.

## Routing ladder — strict priority order

1. **Targeted CLI/skill exists** → use it. Cheapest and most reliable.
2. **Known exact AppleScript/JXA** → `osascript`, or `mac.script()` inside the harness.
3. **Native-app GUI work** → **macos-harness** (skill `apple/macos-harness`): background-window screenshots, PID-targeted clicks/keys, Accessibility tree. No focus-stealing, no cursor movement.
   - System Settings / consent-sheet quirks: keep a recipes skill for the gnarly panes.
4. **Web tasks** → your configured browser-automation workflow (e.g., CDP against a real signed-in browser, or a parallel-space agent browser such as ego-lite if installed).
5. **Fallback only**: full-screen computer-use / vision drivers.

## Web automation safety rules

- Prefer official APIs over UI automation when they exist.
- Use dedicated automation accounts on platforms whose ToS restrict automation; keep personal identity out of automated flows.
- Rate-limit to human speeds; never automate engagement-farming or bulk actions.
- Human approval gate before: posting/publishing, purchasing, deleting, or any irreversible web action.
- When unsure about a site's rules, ask before automating.

## Safety invariants

- Input targets already-running app processes only.
- Never move the physical cursor; never force an app to the foreground.
- After ONE failed verified burst, switch approach. Never repeat-click, bulk-type, or loop blind input.
- Permission errors → tell the user exactly which System Settings toggle to grant; do not retry.
