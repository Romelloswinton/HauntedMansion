# TASKS — Midnight Manor

The work queue. Do tasks in order, one per session. Claude writes and maintains this file; Codex and Mello update the status of their own tasks.

Status values: `ready` (can start now), `blocked` (needs a decision from Mello), `in progress`, `playtest` (waiting on Mello), `review` (Mello asked Claude to review first), `done`.

To start a task, Mello sends the owner the prompt shown under it.

---

## T0 — Finish the one-copy setup
**Owner:** Mello · **Status:** ready

From the "Saving with Claude + Codex" plan. Do these before T1 so Codex works in the right folder.

- [ ] Close Studio and reopen `Midnight-Manor.rbxlx` from `Desktop\HauntedMansion`
- [ ] Delete `Documents\Projects\HauntedMansion` and the original Codex output copy
- [ ] Start a new Codex session pointed at the Desktop folder
- [ ] Push the project to GitHub so Claude and Codex share one copy
- [ ] Install the pending Windows update so Claude can run builds and tests

---

## T1 — Rename Michael Myers to Mekayal and announce the role
**Owner:** Codex · **Status:** ready

Prompt: `Do task T1 in TASKS.md.`

Text changes only. No rule changes, so no new tests.

- `src/GameServer.server.luau`
  - Intermission message: "One player is about to be chosen as Mekayal."
  - Head-start message: "<DisplayName> is Mekayal this round. Survivors: find a hiding place!"
  - Win messages: "MEKAYAL WINS — every survivor was captured!" and "ROUND CANCELLED — Mekayal left or reset."
- `src/GameClient.client.luau`
  - Role label "MICHAEL MYERS" becomes "MEKAYAL".
  - Mekayal's own messages: "You are Mekayal. You will be released when this countdown ends." and "Capture every survivor before time runs out."
  - Caught survivors see "You were caught. Your team can still win!"
- `tools/build-place.mjs`: lobby rules sign becomes "ONE PLAYER IS MEKAYAL.\nMEKAYAL MUST CAPTURE EVERY SURVIVOR.\nONE SURVIVOR LEFT AT THE END = TEAM VICTORY."
- `README.md`, `AGENTS.md`, `docs/haunted-mansion-design.md`: replace Michael Myers with Mekayal; use "capture" and "caught" instead of "kill" and "eliminate" in player-facing descriptions.
- Do not rename internal identifiers (`Killer` role value, `killerId`, `KillerName`, `dressKiller`).
- Do not change the costume; that is T5.

Done when: no "Michael" or "Myers" remains outside `NOTES.md`, the existing tests pass, and the build succeeds.

Studio check for Mello: the lobby sign, the intermission message, the name announcement at round start, and both win messages.

---

## T2 — Stop one error from ending all rounds
**Owner:** Codex · **Status:** ready

Prompt: `Do task T2 in TASKS.md.`

From the 2026-10-04 review. Today any error in the main loop of `src/GameServer.server.luau` stops rounds until the server restarts.

- Move the body of one round into a function and call it with `pcall`. On error: `warn` the message, disconnect touches, set `round = nil`, return players to the lobby as the normal round end does, and continue the loop.
- If `SurvivorSpawns` is empty, warn and skip the round instead of indexing a missing spawn.
- Cap the roster at `math.min(Config.MaxPlayers, 10)` so a larger `MaxPlayers` cannot trip the 2–10 assert in `RoundRules.new`.

Done when: the existing tests pass and the build succeeds. No behavior change in a normal round.

---

## T3 — First multiplayer playtest
**Owner:** Mello · **Status:** ready (best after T1 and T2)

Studio, Server & Clients mode, 2 players, then 3 or more if possible. Work through the checklist in `README.md` under "Testing status". Also check:

- Can Mekayal catch a survivor standing on the kitchen counter or the bed?
- Does a survivor standing at the mansion entrance get caught when Mekayal is released?
- How many survivors does Mekayal catch in 5 minutes? This decides round length and speed.

Paste only the failing output to Claude.

---

## T4 — Three-round game with one Mekayal per game
**Owner:** Codex · **Status:** blocked

Needs Mello's decisions on:
1. Mekayal leaves mid-game. Claude recommends: the game ends and a new game picks a new Mekayal.
2. Mekayal resets mid-round. Claude recommends: that round counts as a survivor win.
3. Overall winner. Claude recommends: show a running score and announce the side with more round wins.
4. Repeat picks. Claude recommends: the same player is not picked two games in a row when someone else is available.

Claude writes the full brief and test cases here once these are decided.

---

## T5 — Mekayal costume
**Owner:** Codex · **Status:** blocked

Needs Mello's decision: wide-brimmed hat hiding the face, or a mask. Replaces the white mask built in `dressKiller`.

---

## Parked until after T3
- Team colors in the player list
- Sound and chase music
- The Midnight Grounds (outdoor ring)
- Round length (stays 300 s until playtested) and Mekayal's speed
