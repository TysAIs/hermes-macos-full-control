# Optional companions

The core stack works standalone. These integrations are optional upgrades.

## ego-lite (parallel browser for agents)

[citrolabs/ego-lite](https://github.com/citrolabs/ego-lite) (MIT skill + docs; the
browser app is a separate free download) — a macOS Chromium browser where agents
work in isolated "Spaces" while you keep your own tabs, inheriting your real
logins. Hermes Agent is officially supported.

**Why it fits this stack**: it replaces the fragile part of web automation —
driving your daily browser — with a dedicated, login-inheriting, parallel browser.
In ladder terms it becomes your layer-4 web workflow.

**Install (skill only):**

```bash
npx skills add citrolabs/ego-lite
```

The first browser task walks you through installing the ego lite app.

**ToS-safety contract** (add to your policy file if you adopt it):

- Dedicated automation accounts on restrictive platforms; never your primary identity.
- Human-speed pacing; no bulk engagement actions.
- Approval gate before any publish/purchase/delete.
- Prefer official APIs where offered.

## Status

Untested in CI by design — it requires a signed desktop app and real accounts.
Evaluate manually before adopting; see TESTS.md for how we validate layers.
