<div align="center">

# hermes-macos-full-control

**Give every agent on your Mac the same safe, layered ability to see and operate real apps — without prompt bloat or tool confusion.**

[![CI](https://github.com/TysAIs/hermes-macos-full-control/actions/workflows/ci.yml/badge.svg)](https://github.com/TysAIs/hermes-macos-full-control/actions/workflows/ci.yml)
![Platform](https://img.shields.io/badge/platform-macOS%2014%2B-black)
![License](https://img.shields.io/badge/license-MIT-blue)

*Built for [Hermes Agent](https://github.com/nousresearch/hermes-agent), works for any agent platform that uses `SOUL.md` / `SKILL.md` conventions.*

</div>

---

## The problem

AI agents fail at desktop work for two reasons:

1. **No hands or eyes.** They can run terminal commands, but if a task lives inside a GUI — System Settings, an OAuth consent sheet, an upload dialog, any app without a CLI — they're stuck.
2. **Too many overlapping tools.** Once you add GUI automation, agents waste turns picking the *wrong layer* (clicking through menus when one CLI command would do it).

## The fix: a routing ladder, stamped into every agent

```
┌─ Task arrives ───────────────────────────────────────────────┐
│                                                              │
│  1. Targeted CLI exists?  ────── yes ──► use it (cheapest)   │
│         │ no                                                 │
│  2. Known AppleScript?    ── yes ──► osascript / mac.script()│
│         │ no                                                 │
│  3. Native-app GUI work?  ── yes ──► macos-harness           │
│         │                        background screenshots,     │
│         │                         PID-targeted input, AX tree│
│  4. Web task?             ── yes ──► your browser automation │
│         │ no                                                 │
│  5. Fallback: full-screen computer-use vision drivers        │
└──────────────────────────────────────────────────────────────┘
```

The ladder lives in **one policy file** (single source of truth). A generator
script stamps a compact ~90-word version into every agent's `SOUL.md` — so your
whole fleet stays perfectly in sync and can never drift:

```
computer-control-policy.md  ──►  stamp script  ──►  SOUL.md (default bot)
      (edit here once)                              SOUL.md (profile A)
                                                    SOUL.md (profile B)
                                                    ...every agent
```

Everything else — detailed skill instructions, recipes — loads on demand
([progressive disclosure](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)),
costing under 100 words of persistent context per agent.

## Quick start

```bash
git clone https://github.com/TysAIs/hermes-macos-full-control.git
cd hermes-macos-full-control
./install.sh
```

The installer will:

| Step | What happens |
|---|---|
| 1 | Install the [`macos-harness`](https://github.com/browser-use/macos-harness) CLI via `uv` (skipped if present) |
| 2 | Register the skill into `~/.hermes/skills/` |
| 3 | Generate your policy file with this Mac's **auto-detected hardware baseline** |
| 4 | Stamp the ladder into every agent `SOUL.md` (backups made automatically) |

Then grant two macOS permissions when prompted — **Accessibility** and
**Screen & System Audio Recording** — to your terminal / agent-host app.

Verify everything:

```bash
macos-harness doctor                                # expect all true
echo 'print(mac.see("Finder"))' | macos-harness    # expect frame data
```

Restart your Hermes gateway so agents reload souls + skills. Done.

## Changing policy later

Edit **one file**, re-run **one script**:

```bash
$EDITOR ~/.hermes/computer-control-policy.md
~/.hermes/scripts/stamp-computer-control.sh
# optional, for running sessions:
launchctl kickstart -k gui/$(id -u)/ai.hermes.gateway
```

Every agent updates atomically. New profile agents get picked up automatically —
the stamper discovers all `profiles/*/SOUL.md` on its own.

## Safety model

- Input only goes to **already-running apps**; agents never move your physical
  cursor or steal focus — you can keep working while they do.
- One failed attempt → switch approach. No blind click-spamming, ever.
- Irreversible actions stop at decision boundaries.
- All OS access is gated by macOS TCC permissions **you** grant and can revoke.

## Troubleshooting

<details>
<summary><b>Permission errors ("Screen Recording permission is required")</b></summary>

System Settings → Privacy & Security → grant **Accessibility** and
**Screen & System Audio Recording** to the app that runs your agents (Terminal,
iTerm, or the Hermes desktop app). Then re-run `macos-harness doctor` — every
value should read `true`.
</details>

<details>
<summary><b>Agents don't seem to know about the harness</b></summary>

Skills load at session start. Restart your gateway (or start a fresh session).
Confirm discovery with <code>hermes skills list</code> — you should see
<code>macos-harness</code> as enabled.
</details>

<details>
<summary><b>Install failed midway</b></summary>

Re-run <code>./install.sh</code> — it's fully idempotent. Policy files are written
atomically; souls are backed up (<code>*.bak-stamp-*</code>) before every change;
partial states recover cleanly on the next run. CI runs this exact scenario on
every commit.
</details>

<details>
<summary><b>Does this work on Intel Macs?</b></summary>

Yes. The hardware detector reads real values via <code>sysctl</code>; nothing is
Apple-Silicon-specific.
</details>

## FAQ

**Why not just give agents a computer-use vision driver?**
You can — it's layer 5, the fallback. But full-screen vision clicking is the most
fragile, slowest tool. Agents that ladder up from CLIs → scripts → targeted GUI
primitives finish faster with fewer mistakes.

**Does this send my data anywhere?**
No telemetry in this package. (The upstream harness has opt-out telemetry; this
repo's docs cover disabling it.)

**Windows / Linux?**
Not yet — the harness and permissions model are macOS-native by design.

## Credits

Built on [browser-use/macos-harness](https://github.com/browser-use/macos-harness) (MIT).
Skill packaging and the fleet-policy system designed for [Hermes Agent](https://github.com/nousresearch/hermes-agent).

## License

MIT — see [LICENSE](LICENSE).
