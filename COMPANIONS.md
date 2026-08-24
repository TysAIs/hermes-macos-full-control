# Optional companions

The core stack works standalone. These integrations are optional upgrades.

## Web automation companions: browser-use + cua-driver

Web tasks use Hermes-native, open-source tooling — no third-party closed-source
browsers required:

- **browser-use** (`browser_exec` tool / `browser-use` CLI) — automates real
  browser sessions for page automation, extraction, form-filling, multi-step
  flows. Ships with Hermes (`hermes setup tools`).
- **cua-driver** (`computer_use` tool / `cua-driver` CLI) — full desktop +
  browser control for GUI-level pixel/coordinate work (consent dialogs, canvas
  apps, native UI). Ships with Hermes.
- **Brave CDP** (`~/bin/brave-cdp.sh`, port 9222) — for tasks that need the
  user's live logged-in Brave session. Brave is the browser of record; agents
  reuse its login state without tab-fighting.

**Why these over a dedicated agent browser (ego-lite):** ego-lite/citrolabs is
closed source and heavy (48+ processes, ~5.5GB RAM observed while idle). The
native browser-use/cua-driver stack is open source, lightweight, and already
wired into Hermes — nothing extra to install or babysit.

**ToS-safety contract** (applies to all browser automation):

- Dedicated automation accounts on restrictive platforms; never your primary identity.
- Human-speed pacing; no bulk engagement actions.
- Approval gate before any publish/purchase/delete.
- Prefer official APIs where offered.

## Status

Untested in CI by design — browser automation requires real sessions and
accounts. Evaluate manually before adopting; see TESTS.md for how we validate
layers.
