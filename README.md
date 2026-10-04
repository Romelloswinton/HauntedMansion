# Midnight Manor

A simple Roblox Studio horror prototype: one player controls Michael Myers, and up to nine survivors hide and run through a single-floor haunted mansion.

## Open the game

1. In Roblox Studio, choose **File → Open from File** and select `Midnight-Manor.rbxlx` in this folder. You can also try double-clicking the file.
2. Press **Play** to explore the mansion alone in Studio. Solo mode is for walking around; it does not run a competitive round.
3. Stop the solo test. Use Studio's **Server & Clients** testing mode with **2 players** to test a match. Each client is a separate player; switch between their windows to move the killer and survivor.

No Blender, paid assets, plugins, or external services are needed to run the place. It has not been published.

## Rules

- At least 2 ready players are needed; a full round has 10 players.
- A 20-second intermission precedes random killer selection.
- Survivors get a 15-second head start. The killer waits in the lobby, then enters the mansion.
- The chase lasts exactly 300 seconds. Touching a survivor's body eliminates them after server checks for proximity and an unobstructed path.
- Michael wins only if every survivor is eliminated **before** the deadline.
- If anyone is alive at the deadline, the **entire survivor team wins**, including eliminated teammates. A touch at the exact deadline cannot reverse that result.
- Eliminated players watch surviving players with the on-screen arrow buttons.
- Late joiners wait and can spectate. Survivor death/reset/disconnection removes them from the round. Killer death/reset/disconnection cancels an unfinished round.
- Everyone returns for the next round. Extra players beyond the 10-player roster wait until a future round.

For a published version, set the experience's maximum player count to **10** in Roblox's experience settings. Server code already limits each round to ten participants. Publishing and settings changes have not been performed.

## Edit in VS Code

Open the `HauntedMansion` folder, or the `Midnight-Manor.code-workspace` file inside it. Design notes are in `docs/`, and agent instructions are in `AGENTS.md`.

- `src/GameServer.server.luau`: lobby, roles, touch validation, character appearance, round lifecycle.
- `src/RoundRules.luau`: time limits, elimination and winner rules.
- `src/GameClient.client.luau`: HUD and spectator camera.
- `tools/build-place.mjs`: editable map construction and native place packaging.
- `tests/round-rules.spec.luau`: automated rule tests.

The `.rbxlx` file already contains the scripts. VS Code and Studio do **not** automatically synchronize. You can edit scripts directly in Studio's Explorer, or rebuild a new place from the source using Node.js:

```sh
node tools/build-place.mjs
```

Rebuilding replaces `Midnight-Manor.rbxlx` with the generated map and current source files. Save Studio-only map edits to a different filename before rebuilding. Node.js is only needed for rebuilding from source, not for playing or editing the supplied place in Studio.

## Testing status

The pure rule tests and Luau compilation checks run outside Studio. The generator also checks that all nine survivor spawn locations and all six central hallway entrances are reachable with a 3-stud-wide walking clearance.

An actual Roblox multiplayer playtest is still needed. Check: walking through doors, head-start release, killer appearance, touch capture, survivor spectator camera, reset/disconnect behavior, deadline victory, all-caught victory, and a second complete round. Also check the HUD on a mobile viewport. This is a prototype, not a production anti-cheat system.

Official references: [Studio testing modes](https://create.roblox.com/docs/studio/testing-modes), [Roblox character tools](https://create.roblox.com/docs/studio/rig-builder).
