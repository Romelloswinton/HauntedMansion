# AGENTS.md — Midnight Manor

Instructions for any AI coding agent (Codex, Claude) working in this repo. Read this first, then `NOTES.md` for the latest status.

## What this is
A Roblox horror prototype. One player is the killer (Michael Myers); up to nine survivors hide and run through a single-floor mansion. Survivors win as a team if anyone is alive when the 5-minute timer ends; the killer wins only by catching everyone before then.

Full design: `docs/haunted-mansion-design.md`. Player-facing rules and how to open the game: `README.md`.

## Layout
| Path | What it is |
|---|---|
| `src/RoundRules.luau` | Pure rules (roster, timer, capture, winner). No Roblox services, so it runs in CLI tests. |
| `src/GameServer.server.luau` | Lobby, role assignment, touch validation, character appearance, round lifecycle. `Config` table at the top holds the timings. |
| `src/GameClient.client.luau` | HUD (role, timer, survivor count) and spectator camera. |
| `tools/build-place.mjs` | Builds the mansion map and packs `src/` into `Midnight-Manor.rbxlx`. Also checks walking clearance. |
| `tests/round-rules.spec.luau` | Rule tests for `RoundRules.luau`. |
| `Midnight-Manor.rbxlx` | **Generated output.** Do not read or edit it. Rebuild instead. |

## Current settings (keep in sync with `Config` in GameServer)
- Round: 300 s · Head start: 15 s · Intermission: 20 s · Max players: 10 (min 2)
- No respawning or reviving. Killer reset or disconnect cancels the round.

## Rules for agents
1. **Never open `Midnight-Manor.rbxlx`.** It's ~175 KB of generated XML and wastes context. Work only in `src/`, `tests/`, and `tools/`.
2. **The server decides everything.** Role assignment, captures, and the winner are server-side. The client only displays state and moves the camera.
3. **Put game logic in `RoundRules.luau` when possible** and add a test for it in `tests/round-rules.spec.luau`. Roblox-specific code (Players, touch events, characters) stays in `GameServer`.
4. **Keep the scope small.** No escape objectives, abilities, inventory, progression, paid assets, or plugins unless asked.
5. **After changing `src/` or `tools/`,** rebuild: `node tools/build-place.mjs`. Warn the user that this overwrites `Midnight-Manor.rbxlx`, so any map edits made only in Studio should be saved under another filename first.
6. **Keep diffs focused.** Change only what the task needs, and don't reformat untouched code. Indentation is 4 spaces.
7. **When you finish,** add a 1–2 line dated entry to `NOTES.md`: what changed and what still needs testing in Studio.

## Who does what
- **Codex:** writes and edits code, runs the build and tests.
- **Claude:** plans features, reviews diffs, debugs from pasted Studio output, writes test cases.
- **Mello:** leads, runs Studio playtests, and decides what gets built next.

## Not yet verified
No live multiplayer playtest has been done. Untested in Studio: head-start release, touch capture, spectator camera, reset/disconnect handling, deadline and all-caught wins, a second consecutive round, and mobile HUD. See the checklist in `README.md`.
