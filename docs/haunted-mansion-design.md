# Haunted Mansion — proposed first Roblox prototype

Status: first prototype source and native Studio place built in outputs/HauntedMansion. Thirteen rule tests, script compilation, XML packaging, and map connectivity checks pass. A live Roblox multiplayer playtest remains to be completed.

## Your game

A multiplayer horror game for ten players. One player controls Michael Myers. The other nine players hide or run through a haunted mansion. When Michael touches a survivor, that survivor is eliminated for the rest of the round and watches the remaining players.

## Recommended first version

Use repeated survival rounds. Randomly choose one killer from the players at the start of each round; everyone else becomes a survivor. Allow smaller groups of at least two players during development, with a full match consisting of one killer and nine survivors.

Confirmed win condition: survive a five-minute chase. Proposed setup timings: a 20-second intermission and a 15-second survivor head start. During the head start the killer stays in a separate spawn area. The killer wins when every survivor is eliminated. The entire survivor team wins if at least one survivor is still alive when the five-minute timer expires, including teammates who were already eliminated. Michael Myers wins only by eliminating all survivors before the timer expires. No mid-round respawning or reviving.

## Mansion

Create a playable mansion blockout before detailed decorations. The ground floor has an entrance hall, living room, dining room, kitchen, library, and rear corridor. Keep this first version to one floor. Connected hallways and two entrances to each main room let players change routes while being chased. Furniture and alcoves provide hiding places; hiding does not make a survivor immune to touch.

Use dim moonlight, subdued interior lamps, fog, and clear silhouettes. Players must still be able to read doorways and stairs. Start without licensed audio or imported character assets; visual and audio polish can follow the working game loop.

## Controls and spectator experience

Use Roblox's standard movement controls. Initially give all participants the same movement speed; tune balance after multiplayer testing. Survivors can use rooms, furniture, and route choices to break line of sight.

Display role, round timer, and surviving player count. On elimination, remove the survivor from active play and show an elimination message plus previous/next spectator buttons. Spectating follows living survivors. If the current target is eliminated or leaves, switch to another living survivor. At round end everyone returns to the lobby.

## Implementation approach

Recommended: an importable Roblox Studio prototype with Luau server scripts, a client HUD and spectator controller, and a generated mansion blockout. This makes the complete round loop testable before investing in art.

Alternative: build and decorate the mansion manually first, then add scripts. This gives more visual control early but delays testing the chase mechanics. A template-based game is another option, but would require adapting its rules and auditing its scripts.

The server owns role assignment, the timer, surviving players, and elimination decisions. Touch processing must confirm both participants are current round members, the attacker is the active killer, the victim is an active survivor, and they are physically close. Duplicate touch events must not eliminate twice. The client displays state and controls its camera; it does not decide who was caught.

Late joiners wait for the next round. A departing survivor leaves the surviving-player count. If the killer disconnects, end the round without awarding a killer victory. Character death or reset eliminates an active survivor; a killer reset ends the round. Clear all round connections and state before the next match.

## Validation before calling it playable

Test in Roblox Studio with multiple clients: role assignment, survivor head start, touch elimination, duplicate touches, camera switching, survivor and killer disconnects, character resets, late joining, timer victory, all-caught victory, and repeated rounds. Walk the mansion to check collision, hiding spaces, and connected escape routes. Check HUD and spectator controls on desktop and mobile screen sizes.

Official testing reference: https://create.roblox.com/docs/studio/testing-modes
Official collision reference: https://create.roblox.com/docs/workspace/collisions

## Confirmed direction

The entire survivor team wins if Michael Myers has not caught every survivor before the five-minute timer expires. Keep the first version simple: one floor, standard movement, touch elimination, and spectator switching. No escape objectives, special abilities, inventory, or progression in this prototype.



## Character creation

Use Roblox Studio for all character work in this first version. Survivors keep their standard Roblox avatars. Create a simple Michael Myers character using a Roblox rig, dark clothing, and a plain white mask made from Studio parts. Blender is not required or part of the setup. Character polish follows the working game loop.

