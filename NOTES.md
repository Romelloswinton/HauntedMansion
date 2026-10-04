# NOTES — Midnight Manor

Running handoff log between Mello, Codex and Claude. Newest entry at the top, 1–2 lines each.

- 2026-10-04 (Claude): Aligned `AGENTS.md` with Mello's "Saving with Claude + Codex" plan: the feature loop now matches its diagram (no mandatory Claude review; Codex logs), and Mello's remaining setup steps are T0 in `TASKS.md`. Next: Mello — T0, then send Codex T1.

- 2026-10-04 (Claude): Added `TASKS.md` (work queue, T1–T5) and wired it into the check-in in `AGENTS.md` and `CLAUDE.md`. Mello decided round length stays 300 s until playtested. Next: Codex — T1 (rename to Mekayal and announce the role).

- 2026-10-04 (Claude): Mello changed the game to 3 rounds (was 4); `docs/creative-direction.md` updated. Round length under discussion: Claude recommends 180 s, currently 300 s.

- 2026-10-04 (Claude): Mello decided: a game is 4 rounds; Mekayal is picked at random once per game, not per round. Added "Game structure" to `docs/creative-direction.md`. Not built yet; `haunted-mansion-design.md` and `README.md` still say per-round. Next: Mello — decide Mekayal leave/reset mid-game, overall winner, and repeat picks; then Codex implements.

- 2026-10-04 (Claude): Mello decided: Mekayal is always a player (role-play), and the game announces it openly. Added "Mekayal is a player" to `docs/creative-direction.md`; no fake scripted Mekayal sightings. Next: Codex — rename Michael Myers to Mekayal, show who was chosen in the HUD, update the lobby sign and messages to "capture" wording.

- 2026-10-04 (Claude): Mello decided: no in-world nameplates. Updated `docs/creative-direction.md`; the code already hides names, so nothing to build. Still open: Mekayal's scripted-vs-player scares, the Grounds scope, hat vs mask.

- 2026-10-04 (Claude): Reviewed `docs/creative-direction.md`; doc unchanged. Main gaps: Mekayal's scares read as scripted but he is player-controlled, the Grounds conflict with the one-floor scope and equal-speed chase, nameplates would weaken hiding (code hides names today), mask vs hat is inconsistent. Next: Mello — decide those four, then the Michael Myers → Mekayal rename can go to Codex.

- 2026-10-04 (Codex): Created `docs/creative-direction.md` as a shared living brief covering the kid-friendly tone, Midnight Grounds, Mekayal, player avatars, and team/nameplate standards. No code changed; open design questions remain for Claude’s review.

- 2026-10-04 (Codex): Confirmed the Midnight Manor repo, current handoff status, and agent responsibilities. No code changes; awaiting Mello’s first feature or bug task.

- 2026-10-04 (Claude): Added `CLAUDE.md` (imports `AGENTS.md`, adds Claude's role). `AGENTS.md` gained the check-in routine, feature loop and request rules. Code unchanged. Next: Mello — start a fresh Codex session in this folder and confirm it follows the check-in.
- 2026-10-04 (Claude): Read-through bug review of `src/`, `tests/`, `tools/`. No blocking bugs; code unchanged. Low-severity: unprotected main loop (MaxPlayers > 10 or empty SurvivorSpawns would halt rounds), killer can reset to cancel a losing round, lobby teleports stack players. Playtest: catching survivors standing on counter/bed, touch at killer release. Rule tests not run (no luau CLI installed).
- 2026-10-04 (Claude): Moved the project from the Codex output folder to `Desktop\HauntedMansion`. Design notes and the starter zip now live in `docs/`. Added AGENTS.md, NOTES.md and .gitignore. Code unchanged.
- 2026-10-04 (Codex): Built the first prototype. 13 rule tests, script compilation and map connectivity checks pass. Live multiplayer playtest in Studio still needed.
