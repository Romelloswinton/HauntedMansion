# Midnight Manor Creative Direction

Living creative handoff for Mello, Codex, and Claude. This is a design brief, not yet the final implementation specification.

## Creative north star

Midnight Manor is a kid-friendly multiplayer horror experience that blends classic slasher tension, liminal-space unease, and playful Roblox accessibility.

The intended feeling is: spooky enough to make players scream and laugh, but not graphic or disturbing. Fear should come from atmosphere, sound, hiding, surprise, and pursuit—not blood or gore.

## Environment: The Midnight Grounds

The mansion sits in a clearing surrounded by tall, crooked trees and a readable forest boundary.

- Moonlight breaks through the branches in soft blue-white patches.
- A winding driveway, old gate, and lanterns frame the mansion entrance.
- Outdoor landmarks include an overgrown garden, abandoned shed, stone well, and wooden path.
- Low ground fog, wind, leaves, fireflies, and distant owl sounds add mood without obscuring play.
- The mansion remains the main arena; the forest is a smaller outer ring for short chases and hiding.
- Players should be able to recognize the mansion lights from outside so they do not become completely lost.

### Palette

- Deep navy sky
- Blue-gray shadows
- Warm yellow mansion windows
- Muted green trees and grass
- Occasional purple or amber accent lighting

## Antagonist: Mekayal

The approved name is **Mekayal**, pronounced “meh-kuh-yale.” He is an original, theatrical night caretaker rather than a direct copy of an existing horror character.

### Visual identity

- Tall, readable silhouette
- Long dark coat with blue-gray highlights
- Wide-brimmed hat that hides most of the face
- Warm glowing lantern
- Antique key ring
- Distinctive movement and audio silhouette

### Mekayal is a player

Decided 2026-10-04: Mekayal is always played by one of the players in the server, chosen at random once per game (see Game structure). He is never a computer-controlled monster. The game is a role-play: one player takes the Mekayal role and has to capture everyone else, and the rest play survivors.

The game says this openly, so nobody is surprised by it:

- **Lobby:** a sign explains that one player becomes Mekayal for each game and must capture all the survivors.
- **Before a game:** the intermission message says a player is about to be chosen as Mekayal.
- **Round start:** every player is told who Mekayal is and which round it is, for example "Alex is Mekayal. Round 2 of 3." The chosen player sees "You are Mekayal. Capture every survivor."
- **During the round:** the HUD keeps showing each player their own role.
- **Wording:** use "capture" and "caught", not "kill".

The server already records the chosen player's name (`KillerName`); the HUD does not show it yet.

### Game structure

Decided 2026-10-04: a game is 3 rounds. One player is picked at random as Mekayal when a game starts and keeps the role for all 3 rounds. A new Mekayal is picked at random only after the game is over.

- Caught survivors come back at the start of each new round.
- The HUD shows the round number ("Round 2 of 3").
- Each round stays at 5 minutes until the first playtest shows whether that is too long.

Not yet in the game: today the server picks a new Mekayal every round and has no concept of a game. Still to decide: what happens if the Mekayal player leaves or resets mid-game, whether a game has an overall winner, and whether the same player can be picked two games in a row.

### Behavior and scares

Because Mekayal is a player, the scares come from how that player moves: appearing at the end of a hallway, waiting behind a door, the lantern glow coming around a corner. The game supports this with his silhouette, lantern light, footsteps, and chase music.

Ambient effects (flickering lamps, wind, creaks) are atmosphere only. They must never show a fake Mekayal, such as a scripted silhouette in the trees, because players need to trust that any Mekayal they see is the real player.

Catches use a theatrical spectator transition and message rather than graphic violence.

## Player avatars

Survivors should use their own Roblox avatars, accessories, and body styles. This gives players ownership and keeps the game familiar.

Mekayal should remain a distinct fixed character model so the killer role is immediately readable and the game has a recognizable mascot.

## Team colors

Use Roblox's standard Teams system for server-controlled role assignment and the default player list.

- Survivors: soft teal
- Mekayal: warm amber or purple
- Spectators: neutral gray
- Automatic team assignment disabled; `GameServer` assigns roles
- No permanent glowing outlines, preserving hiding gameplay
- Optional temporary outlines may support spectators or accessibility settings

## Nameplates: none

Decided 2026-10-04: no in-world nameplates. Names above heads give away hiding survivors, so they stay hidden for everyone. This is what `GameServer` already does (`DisplayDistanceType = None`), so no code change is needed. Team colors appear only in the player list. Spectators identify who they are watching from the "WATCHING" label in the HUD.

## Kid-friendly content boundaries

- No gore, corpses, realistic blood, or graphic attack animations
- Prefer suspense, sound cues, shadows, environmental motion, and chase sequences
- Keep lighting readable enough for younger players and mobile screens
- Target Roblox's Minimal or Mild maturity range where practical

## Research references

Current Roblox horror patterns reviewed:

- [DOORS](https://www.roblox.com/games/6516141723/DOORS): clear room-to-room survival loop and mild fear presentation.
- [Dandy's World](https://www.roblox.com/games/16116270224/Dandys-World): cooperative objectives, collectibles, customization, and mascot horror.
- [Apeirophobia](https://www.roblox.com/games/5230740032/Apeirophobia): liminal exploration, puzzles, hiding, and Backrooms-inspired atmosphere.
- [Roblox Safety FAQs](https://about.roblox.com/safety-faqs): official maturity-label guidance.
- [Roblox Teams documentation](https://create.roblox.com/docs/players/teams): built-in team names, colors, and player-list behavior.
- [Roblox Humanoid documentation](https://create.roblox.com/docs/reference/engine/classes/Humanoid): name display controls, used to hide names.

## Open design questions

- Final survivor HUD and role-indicator style
- Mansion room themes and progression through the floor
- Mekayal's exact mask, lantern, and key-ring design
- Accessibility options for darkness, flashing effects, and audio intensity

## Collaboration status

Approved so far: kid-friendly horror blend, The Midnight Grounds, Mekayal as the antagonist name, Mekayal as an openly announced player role, player-owned survivor avatars, Roblox-standard team colors, and no in-world nameplates.
