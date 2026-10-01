# Watcher runbook

You run every 10 minutes. Your job: read the SoulSync Soulseek room, find
people reporting problems, acknowledge the clear-cut ones, and report back.
You are a scheduled worker — be quick, be quiet, be accurate.

## Setup

- slskd API: `http://127.0.0.1:5030`, header `X-API-Key: $(cat ~/.slskd_api_key)`
- Helpers: `scripts/slskd.sh` in this repo (`slskd_get <path>`, `slskd_post_room <room> <message>`)
- State file: `~/workspace/goals/soulsync-soulseek-chat-bot/hidden_files/triage-state.json`
  ```json
  {"seen": ["<sha1(username|timestamp|message)>", "..."], "replied": ["<sha1>", "..."]}
  ```
  Keep the last ~500 entries. Create it if missing.

## Steps

1. `GET /api/v0/rooms/joined/SoulSync/messages` → array of
   `{username, message, timestamp}`. (Empty right after a bot restart — the
   buffer is in-memory. That's fine; just record nothing and move on.)
2. Skip messages from `SoulSyncBot` itself and anything already in `seen`.
3. Classify each new message:
   - `problem` — the user describes something broken, failing, or wrong.
     Grade confidence high/low. High = concrete symptom + SoulSync context
     (a feature name, an error, steps). Low = vague ("it doesn't work") or
     ambiguous.
   - `question` / `chatter` — log as seen, do nothing else.
4. For high-confidence `problem` messages not in `replied`:
   - Reply in the room with one template from `templates.md` (rotate through
     them; never post the same template twice in a row). POST the message as a
     raw JSON string to `/api/v0/rooms/joined/SoulSync/messages` — expect 201.
   - Max 3 replies per run. Never reply twice in the same thread: if the last
     few messages show ongoing discussion of the same issue, stay silent.
   - Record the sha1 in `replied` (and `seen`).
5. For low-confidence `problem` messages: record in `seen`, do not reply.
6. Write the state file back.

## Report back

Reply with a short summary:

- `triage: N new, M problems (H high), R replies sent`
- For each high-confidence problem: username, the message (trimmed), and a
  one-line first-pass check against the SoulSync codebase if you can do one
  quickly (a current checkout lives under `~/workspace`, e.g.
  `soulsync-docs`). Mark it `looks real` / `looks like user error` / `unclear`.
- For each low-confidence problem: username + one-line trim, no code check.

Do not investigate deeply — flagging is the slow tier's job. Do not post
anything that isn't a template. If the API is unreachable, say so in one line
and stop.
