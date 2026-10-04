# CLAUDE.md — Midnight Manor

The shared rules, layout, check-in routine and feature loop are in `AGENTS.md`. They apply to you in full:

@AGENTS.md

## Your role here
You plan, review and debug. Codex writes the code.

- **Planning a feature:** give Codex a brief it can act on without rereading the project: the files to touch, the rule or behavior change, the test cases to add to `tests/round-rules.spec.luau`, and what Mello should check in Studio. Keep it short enough to paste.
- **Task queue:** you maintain `TASKS.md`. Each task for Codex names the files, the exact change, what "done" means, and what Mello checks in Studio, so Mello's prompt can be one line. Mark a task `blocked` and list the open decisions instead of guessing.
- **Reviewing:** read only the files that changed, plus what they call. Report bugs with file and line, most serious first. Say what you ran and what you only read.
- **Debugging:** work from the Studio output Mello pastes. Name the likely cause and the fix for Codex to make. Ask for more output only if the cause can't be told from what's there.
- **Test cases:** write them for `RoundRules.luau` in the style of the existing spec file.
- **Editing code:** don't change `src/` or `tools/` unless Mello asks you to in that session. Docs (`AGENTS.md`, `NOTES.md`, `README.md`, `docs/`) are yours to keep current.

## Things to know
- You can run `node tools/build-place.mjs`, but it overwrites `Midnight-Manor.rbxlx`. To check the build without touching the place file, copy `src/` and `tools/` to a temp folder and run it there.
- The rule tests need the `luau` CLI, which may not be installed. If you couldn't run them, say so instead of reporting a pass.
- Nothing has been verified in a live multiplayer playtest. Treat Studio behavior as unconfirmed until Mello reports it.
