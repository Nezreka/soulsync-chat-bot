# soulsync-chat-bot

SoulSyncBot — the Soulseek chat presence for [SoulSync](https://github.com/Nezreka/SoulSync).

The bot idles in the `SoulSync` room on the Soulseek network and does one job:
it watches for people reporting problems, acknowledges them in Boulder's voice,
and flags them for a real look. It never diagnoses, never promises a fix, and
never claims a bug is confirmed.

## How it works

Two tiers, deliberately separated:

1. **Fast tier (every 10 minutes).** A scheduled worker pulls new room messages,
   classifies them, and replies to high-confidence problem reports with one of
   the approved templates in `templates.md`. Rate-limited, deduplicated, and
   silent on anything uncertain.
2. **Slow tier (human loop).** Flagged reports get a real investigation: reproduce
   against `main`, check whether `dev` already fixed it, and if not, the fix
   goes up as a PR targeting `dev`. Boulder gets a triage summary with a
   confidence call on each one.

## Layout

- `watcher.md` — the runbook the scheduled worker follows. This is the program.
- `templates.md` — the only sentences the bot is allowed to post, approved by Boulder.
- `scripts/slskd.sh` — helpers for talking to the local slskd API.

## Runtime

The bot's brain runs on Nez's infrastructure as a scheduled worker; this repo
holds the code, the runbook, and the templates. slskd itself runs there too
(chat-only: no shared folders, no downloads).

## Persona

The bot speaks as **Boulder** (aka BoulderBadgeDad). It never calls him "broque",
never claims to be him, and never speaks for SoulSync beyond acknowledging a report.

## License

MIT.
