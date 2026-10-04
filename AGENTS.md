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
| `TASKS.md` | The work queue: ordered tasks with owner, status and brief. Maintained by Claude. |
| `NOTES.md` | Handoff log between Mello, Codex and Claude. Newest entry on top. |
| `docs/creative-direction.md` | Creative brief and design decisions. Not a build spec; build only what a task in `TASKS.md` says. |
| `CLAUDE.md` | Claude-only additions. Imports this file. |
| `Midnight Manor Saving with Claude + Codex.docx` | Mello's plan for splitting work and saving usage. Its roles, feature loop and usage rules are already in this file, so agents don't need to open it. |

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

## Check in (every session)
**Start:**
1. Read this file, then the top entries of `NOTES.md`.
2. If you were given a task ID, read that task in `TASKS.md`. Do only that task; anything else you notice goes in your `NOTES.md` entry, not in the diff.
3. Say in one line what you understand the task to be and which files you expect to touch. If the task belongs to the other agent's role (see below), or is marked `blocked`, say so and stop.

**End:**
1. Add your `NOTES.md` entry (rule 7), signed with your name: `- YYYY-MM-DD (Codex|Claude): ...`.
2. Update the task's status in `TASKS.md` (`playtest` when the code is ready for Mello, `review` if Mello asked for a Claude review first, `done` when the playtest passed).
3. If the next step belongs to someone else, end the entry with `Next: <who> — <what>`.
4. If you changed a timing, rule, or file layout, update this file and `README.md` in the same session.

## Who does what
- **Codex:** writes and edits code in `src/`, `tests/`, and `tools/`; runs the build and tests.
- **Claude:** plans features, reads the design notes, reviews Codex's changes, debugs from pasted Studio output, writes test cases. Does not edit `src/` or `tools/` unless Mello asks.
- **Mello:** leads, runs Studio playtests, decides what gets built next, and passes work between the two.

## Feature loop
1. **Mello** picks the next feature or bug.
2. **Claude** plans the change and writes it as a task in `TASKS.md`: files to touch, rule changes, test cases.
3. **Codex** codes it, then runs the build and tests.
4. **Mello** playtests in Studio.
5. **Works?** No: Mello pastes the failing output to Claude, Claude debugs from it and names the fix, Codex makes the fix, back to step 4.
6. Yes: **Codex** logs it in `NOTES.md` and marks the task `done`. Back to step 1 for the next feature.

Review is on request, not a step: Mello can ask Claude to review Codex's change before a playtest. It is worth asking for when a change touches `RoundRules.luau` or the round lifecycle in `GameServer`.

## Keeping requests cheap
- One small, specific task per request, naming the file and the error.
- Paste only the failing lines of a log, not the whole thing.
- Work only in `Desktop\HauntedMansion`. Don't read or create other copies of the project.
- Pick up from `NOTES.md` and `TASKS.md` instead of rereading the whole project. Read only the files the task names.

## Not yet verified
No live multiplayer playtest has been done. Untested in Studio: head-start release, touch capture, spectator camera, reset/disconnect handling, deadline and all-caught wins, a second consecutive round, and mobile HUD. See the checklist in `README.md`.
