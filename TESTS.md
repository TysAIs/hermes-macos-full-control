# QA & Test Methodology

How this package is tested, what its known limits are, and how to extend the suite.

## Automated (runs on every push)

`.github/workflows/ci.yml` on macOS runners:

1. `bash -n` syntax check of all scripts
2. ShellCheck (best-effort, warnings surfaced)
3. Hardware-detector smoke test
4. **Full sandbox regression**: fake `HERMES_HOME` (path contains spaces), stubbed
   `macos-harness`, real `install.sh` run → asserts policy generated with hardware
   baseline and zero placeholders, exactly one ladder stamp per SOUL.md, second run
   is byte-identical (idempotent), truncated-SOUL recovery restores clean markers

## Manual probe suite (agent-level)

Run these against a live agent (`hermes --yolo -z "<probe>"`) after installing.
Each targets a different capability edge. Escalate in order:

| # | Probe | Tests | Expected |
|---|---|---|---|
| P1 | *"Determine whether `<toggle>` is currently on in System Settings > X. Use whichever control layer fits best."* | Ladder triage: should pick CLI/`defaults read` over GUI | Correct answer via cheapest layer |
| P2 | *"Capture the <App> window and report what's visible in it. No CLI can read rendered chrome."* | Forced harness use: vision + AX | Accurate reading; optionally cross-checks vs disk |
| P3 | *"GUI-only: create folder A on Desktop via Finder, verify visually, move it to Trash."* | Multi-step input sequencing + verification + cleanup | All steps verified; no debris |
| P4 | *"Open the app 'DefinitelyNotInstalledXYZ' and report its window title."* | Failure discipline: bounded search, then STOP | Refuses to invent; reports not-found; no retry spam |
| P5 | *"GUI-only: create folder A, navigate INTO it, create nested B, rename B, exit, Trash A."* (6 steps) | Long-chain endurance | See Known Limits |

## Known limits (measured)

- **Long GUI chains**: ~3-step GUI sequences complete reliably; 6-step chains can
  exceed practical one-shot time on slower local models. Mitigation: break long
  tasks into staged prompts, or use a faster model for GUI-heavy turns.
- **System Settings**: Apple's AX tree for some panes is unreliable/mis-scaled.
  Prefer `defaults` reads; keep a recipes skill for panes that must be clicked.
- **Raw clicks on inactive apps** may be rejected by macOS — one failure → switch
  mode (keyboard route or `mac.ax.perform`), per the harness invariants.

## Adding probes

Follow the existing pattern: one observable outcome, an explicit layer constraint
(or deliberate absence of one), and a cleanup step. If a probe finds a bug, add it
to CI before fixing.
