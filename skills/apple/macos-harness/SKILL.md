---
name: macos-harness
description: "See and operate any Mac app from one Python session: background-window screenshots, PID-targeted clicks/keys/typing, Accessibility tree, Apple Events/JXA, filesystem. Use WHEN no CLI tool exists for the task, or you must click/type in a GUI (System Settings, dialogs, OAuth consent sheets, upload forms, Electron apps), or verify on-screen state visually. Works without moving the physical cursor or foregrounding apps. Prefer targeted CLI skills first when one exists."
version: 0.1.2
author: browser-use (skill packaging for Hermes Agent)
license: MIT
platforms: [macos]
metadata:
  hermes:
    tags: [automation, computer-use, macOS, accessibility]
prerequisites:
  commands: [macos-harness]
---

# macOS Harness

Use one CLI call per decision point, not per primitive:

```bash
macos-harness <<'PY'
app = "Spotify"
mac.see(app)
mac.key("cmd+k", app=app)
mac.type("Alessia Cara", app=app)
print(mac.see(app))
PY
```

The CLI preloads `mac`, `browser`, `Path`, and `subprocess`. Prefer bounded stdin
programs; reserve `macos-harness repl` for manual exploration and always exit it.

## Minimize round trips

- Bundle deterministic, reversible steps into one program, then verify once.
- Stop at a genuine decision boundary: ambiguous identity, new coordinates, an
  irreversible action, or unexpected state. Inspect once, then run the next burst.
- Do not screenshot merely to confirm a known shortcut opened a text field.
  Let the final screenshot verify the whole sequence.
- Poll exact AX or Apple Events state inside the same Python program when possible.
- Use the cheapest strong end-state check.

## Use the small surface

Think in six verbs: `see`, `key`, `type`, `click`, `ax`, `script`.

```python
frame = mac.see("Spotify")
mac.key("cmd+k", app="Spotify")
item = mac.ax.at(640, 420, app="Spotify")
mac.ax.perform(item["element_index"], "AXPress")
mac.script('tell application "Spotify" to play')
```

Use ordinary Python for local context and one-off logic. Do not add app-specific
helpers when a short program can resolve the task.

## Choose the lowest useful mode

1. When identity depends on local context, inspect that context and correlate
   stable fields; a loose text hit is not enough.
2. Use `mac.script()` for a known exact, focus-safe app command.
3. Otherwise use `mac.see(app)` and vision.
4. Prefer a known keyboard route; use a verified coordinate for a visible,
   low-risk target.
5. Use targeted `mac.ax` only when semantic identity or state matters.

After a failed verified burst, switch mode or stop. Never repair uncertainty with
repeated keys, clicks, deletion loops, or bulk input.

## Keep the invariants

- Input targets an already-running app PID and never requests activation or raise.
- A background target becoming frontmost raises `FocusChangedError`; never
  manipulate focus to restore it.
- The animated pointer is click-through and never moves the physical cursor.
- Inactive apps may reject raw clicks. After one verified failure, switch mode.
- Never launch a closed app or use a custom URL scheme when focus is forbidden.
- Screenshot coordinates come from the latest `mac.see()` and preserve window
  bounds and Retina scaling.

Secondary primitives are `mac.move`, `drag`, `scroll`, `show_pointer`, and
`hide_pointer`. `mac.ax.query()` returns compact matches; lower `max_nodes`
for especially large apps.

## Permissions

Run `macos-harness doctor` to inspect permissions without prompting. Run
`macos-harness doctor --request` only with user approval. Accessibility, screen
recording, and event posting are global; Apple Events Automation is per target.
If permission errors occur, stop and tell the user exactly which System Settings
toggle to grant — do not retry.
