# hermes-macos-full-control

Give every Hermes Agent on a Mac the same, safe, layered ability to **see and operate
real apps** — without prompt bloat and without agents fighting over which automation
layer to use.

## The idea

Agents fail at desktop tasks for one of two reasons: they lack hands/eyes on the GUI,
or they have too many overlapping tools (CLI skills, AppleScript, computer-use drivers,
GUI harnesses) and pick the wrong one. This package fixes both with:

1. **A routing ladder** (single source of truth) — CLI first, then AppleScript, then
   [macos-harness](https://github.com/browser-use/macos-harness) GUI primitives,
   then full-screen vision drivers as fallback.
2. **One stamped block per agent SOUL.md**, generated from that single policy file by
   an idempotent script — so your whole fleet stays in sync and never drifts.
3. **Disambiguated skill descriptions** so models self-select the right layer.

~90 words of persistent context per agent. Everything else loads on demand
(progressive disclosure).

## What's inside

```
install.sh                              one-command setup
computer-control-policy.template.md     the SSOT policy (hardware auto-detected)
scripts/detect-hardware.sh              fills the hardware baseline automatically
scripts/stamp-computer-control.sh       propagates the ladder to every SOUL.md
skills/apple/macos-harness/SKILL.md     the skill (Hermes SKILL.md format)
```

## Requirements

- A Mac (Apple Silicon or Intel), macOS 14+
- [Hermes Agent](https://github.com/nousresearch/hermes-agent) (or any agent platform
  using `SOUL.md` + `SKILL.md` conventions)
- Homebrew (for `uv` install)

## Install

```bash
git clone https://github.com/TysAIs/hermes-macos-full-control.git
cd hermes-computer-control
./install.sh
```

Then grant permissions when prompted by macOS: **Accessibility** and
**Screen & System Audio Recording** for your terminal / agent-host app.

Verify:

```bash
macos-harness doctor                                  # expect all true
echo 'print(mac.see("Finder"))' | macos-harness       # expect frame dict
```

Restart your Hermes gateway so bots reload souls + skills.

## Changing policy later

Edit ONE file — `~/.hermes/computer-control-policy.md` — then re-run
`scripts/stamp-computer-control.sh`. Every agent updates atomically; backups are made
automatically.

## Safety notes

- The ladder forbids cursor movement, focus stealing, and blind input retries.
- Agents are told to stop at irreversible actions and ask.
- macOS TCC permissions are granted by you, to specific apps, revocable anytime.

MIT licensed. The underlying harness is
[browser-use/macos-harness](https://github.com/browser-use/macos-harness) (MIT).
