# DOORS (Roblox, LSPLASH) â€” genre archetype teardown for Project 001

> T5 research dossier - teardown:DOORS - generated 2026-07-06. Every finding: mechanism -> causal chain -> verdict -> Threshold translation -> where it lands -> source.

## Summary

DOORS (7.4B+ visits, 3rd-fastest Roblox game to 1B) is one repeated verb â€” open the next numbered door â€” hiding randomized outcomes governed by a strict entity grammar: every threat owns one signature sensory pre-cue, one correct response, one punishment, and sound/light are literally information. Its tutorial is death itself: Guiding Light names your killer on the death screen and escalates hint specificity with each repeat death to the same entity, while in-run it highlights stuck-progress items only after 20-70 seconds of player failure. Escalation works by rule mutation, not new rules â€” Ambush reuses Rush's grammar but breaks exactly one learned parameter (rebounds up to 6 times), forcing observation over memorization. The single biggest lesson for Project 001: fear scales with rule literacy â€” players get braver AND more scared as they learn, because knowing the grammar makes every ambiguous cue meaningful. We adopt the grammar-and-consequence-teaching architecture, adapt every signature into The Threshold's indifferent language, and refuse the startle payoffs, floor-length loss stakes, and 30-Robux death-screen revives.

## Findings

### 1. [ADAPT] Whole-session loop; Act I (Arrival) of every encounter

- **Mechanism:** The door-loop curiosity engine: one constant verb (open next door) with a visible numbered progress meter (door number doubles as threat clock â€” entity spawn tables key off door ranges), randomized room layouts per run, a knob-currency drip per door, and rare interrupt rooms (Jeff's Shop ~door 52, The Rooms secret subfloor behind door 60, Courtyard/Greenhouse at 90-99) that make any given door potentially special.
- **Causal chain:** Known goal + unknown contents behind an identical repeated action -> 'one more door' compulsion with anticipatory tension spike at every handle -> dread lives in the moment BEFORE the door opens, not after
- **Threshold translation:** The Threshold must not perform progress for the player â€” no numbered counter, the world is indifferent. Keep the loop skeleton: crossing a threshold is our one repeated verb, but progress legibility comes from architecture growing wrong (ceilings lower, geometry stops agreeing with itself) instead of a number. The pre-crossing beat â€” hand on the handle, world silent â€” is where our dread budget goes.
- **Source:** https://doors-game.fandom.com/wiki/DOORS ; https://doors-game.fandom.com/wiki/The_Rooms ; https://romonitorstats.com/experience/6516141723/

### 2. [ADAPT] Death/retry system; The Silent Witness archetype

- **Mechanism:** Guiding Light teaching-through-death: the death screen names the entity that killed you and gives a survival tip that grows MORE specific with each repeat death to that entity; in-run, it highlights required items (keys, fuses) only after 20-70 seconds of the player being stuck, and highlights correct paths/crouch points during Seek chases. Zero tutorial text anywhere in the game. It even deliberately withholds the hint on a first death to Eyes to preserve mystery.
- **Causal chain:** Death always pays out knowledge -> player re-enters the run with a hypothesis to test instead of resentment -> retry becomes an experiment, failure becomes tuition, and the game earns trust that every death was learnable
- **Threshold translation:** No benevolent guide character â€” The Threshold doesn't care. Re-express as the Silent Witness's own voice: the post-death text reads as the place's clinical observation log of your failure ('Subject looked at it for 4.2 seconds'), which teaches the rule while deepening the being-studied violation. Escalating specificity per repeat death stays â€” it is the trust law implemented as a system.
- **Source:** https://doors-game.fandom.com/wiki/Guiding_Light ; https://doors-game.fandom.com/wiki/Death_Screen

### 3. [ADOPT] All four archetypes; the sound-as-information system

- **Mechanism:** The entity telegraph grammar â€” every threat owns a unique cue channel, response, and punishment: Rush (lights flicker + distant scream ramping in volume ~3-5s -> hide in wardrobe/bed -> 100 dmg), Ambush (green glow + distinct deeper sound, rebounds 1-6 times -> hide/exit/re-hide cycles -> 100 dmg), Eyes (purple glow + chime on door open -> look down/away while walking -> DoT while looked at), Screech (dark rooms only, faint breath then 'psst' -> snap camera to face it -> 40 dmg bite), Halt (blue 'TURN AROUND' flash in a stretched hallway -> oscillate forward/back -> 60 dmg), Dupe (fake doors with wrong numbers emit faint rumble; real door silent -> read numbers, listen -> 40 dmg knockdown), Hide (red vignette + 'GET OUT' + accelerating heartbeat when camping a hiding spot -> leave -> 40 dmg ejection + 12.5s hiding lockout), Figure (blind, hears footsteps -> crouch-walk, hide -> instant death), Giggle (giggling from ceilings), Gloombats (light aggros them â€” carry glow sticks, not flashlights).
- **Causal chain:** Unique cue per threat -> player builds a sensory vocabulary where every flicker, color, and sound is a word -> silence and ambiguity become terrifying because the player is always parsing; fear comes from reading, not reacting
- **Threshold translation:** Adopt the GRAMMAR PRINCIPLE wholesale â€” it is our audio directive already shipped at scale: sound effects, light states, and silence carrying all survival information, no music, no text. Refuse the specific signatures (they're DOORS' content) and author Threshold-native ones: a room's hum dropping out, a door that casts no shadow, air pressure. One cue channel per threat, never reused, never lied about.
- **Source:** https://www.destructoid.com/all-doors-entities-guide-how-to-survive/ ; https://doors-game.fandom.com/wiki/List_of_Entities ; https://www.speedrun.com/roblox_doors/guides/l76ng

### 4. [ADOPT] The Violent Rhythm, Act III (Escalation)

- **Mechanism:** Escalation by rule mutation: Ambush is Rush with exactly one learned parameter broken â€” it comes back (1-6 rebounds), so the Rush response ('hide until the scream passes') now kills you via Hide's camping ejection; you must exit and re-hide between passes. Similarly Queen Grumble (Mines) is Grumble with stealth and stall-timing added; A-60/A-120 are Rush variants at different speeds and pathing.
- **Causal chain:** A mastered rule fails in ONE dimension -> panic (my knowledge betrayed me) -> re-observation -> new mastery -> the panic->understanding->control arc replays without adding tutorial burden
- **Threshold translation:** This IS The Violent Rhythm's spec, found in the wild. Design its Act III as a single-parameter mutation of the rule taught in Act II â€” the return-cycle idea re-expressed as the Threshold's rhythm changing time signature, never a brand-new undodgeable rule. Trust survives because the old cue still fires honestly; only the response window changed, and the change is observable before it is lethal.
- **Source:** https://doors-game.fandom.com/wiki/Ambush ; https://www.ginx.tv/en/roblox/doors-ambush

### 5. [ADAPT] The Silent Witness / The Hidden Presence; the shelter system

- **Mechanism:** Hide â€” safety itself is hostile: every hiding spot contains a timer entity; overstay triggers red vignette, 'GET OUT' flashes, accelerating heartbeat, then a 40-dmg ejection plus a ~12.5-second lockout from ALL hiding spots. Shelter is a window, never a state.
- **Causal chain:** The safe verb acquires a cost -> player can never relax inside the coping mechanism -> tension is continuous through the entire threat cycle instead of dropping to zero inside the wardrobe
- **Threshold translation:** Perfect Threshold material: shelter doesn't expel you because it's angry â€” the place simply notices you. Re-express as the hiding spot becoming an observation chamber (Silent Witness): stay too long and the sense of being catalogued escalates until staying is worse than leaving. Refuse the flashing 'GET OUT' UI text â€” our version communicates through the space itself (sound closing in, light dying).
- **Source:** https://doors-game.fandom.com/wiki/Hide ; https://doors-game.fandom.com/wiki/Hiding

### 6. [ADAPT] The Silent Witness (looking as violation) / The Hidden Presence (Act II Discovery)

- **Mechanism:** The Eyes/Screech attention-tax pair: Eyes punishes looking AT it (damage-over-time while in view -> look down and keep walking), Screech punishes NOT looking (spawns behind you in dark rooms, faint breath then 'psst', must snap-look at it or take 40 dmg). Two entities, opposite correct responses, teaching gaze itself as a resource.
- **Causal chain:** Where you point your eyes becomes a survival decision -> every dark room forces active attention management -> paranoia is mechanical, not scripted
- **Threshold translation:** Gaze-as-currency is core to an observation-driven game â€” adopt the tension between must-look and must-not-look. REFUSE Screech's payoff (a screamer to the face is a refund on dread, and its snap-camera response is reflex-gated and mobile-hostile). Our version: the thing you must not look at is learned through evidence, and the punishment for wrong gaze is dread-consistent â€” it gets closer, or it starts looking back â€” never a scream.
- **Source:** https://doors-game.fandom.com/wiki/Screech ; https://www.thegamer.com/roblox-doors-surviving-from-every-monster-guide/

### 7. [ADAPT] The Hidden Presence, Act II (Discovery); impossible-architecture system

- **Mechanism:** Dupe â€” contradiction as information: fake doors appear with WRONG numbers next to the real one; the tell is the number mismatch plus a faint rumble from fake doors while the real one is silent. The interface element players trusted most (the door number = progress) becomes the puzzle.
- **Causal chain:** A trusted environmental constant develops exceptions with a readable tell -> player starts verifying what they used to assume -> the world feels intelligent and the player feels smart when they catch it
- **Threshold translation:** This is The Threshold's native tongue â€” architecture that shouldn't connect. Adopt 'the wrong detail IS the tell' (a corridor that repeats, a room whose window shows the wrong side of the building) and 'absence of sound marks the true path.' REFUSE Dupe's punishment: the knockdown jumpscare (a literal meme soundboard exists of it) and its stacking with Rush into stunlock deaths. Wrong choice should cost position, information, or time â€” never a screamer.
- **Source:** https://doors-game.fandom.com/wiki/Dupe ; https://tuna.voicemod.net/sound/069cb25a-d31a-49e0-b78a-edeeb809fa8d

### 8. [ADAPT] Act IV (Climax) template for all archetypes; closest fit The Violent Rhythm

- **Mechanism:** Figure as the five-act climax template: foreshadowed environment (the Library), a blind entity with acute hearing, sound-based stealth (crouch = quiet, sprint = heard), a hold-your-breath heartbeat minigame while it stalks past your hiding spot, and a finale reprise at door 100 with raised stakes (elevator escape). Instant death on contact â€” the one entity with no health tax.
- **Causal chain:** All ambient rules (sound = information) invert onto the player (YOUR sound = death) -> a full room becomes one continuous decision under pressure -> the climax is describable in one sentence: 'the blind thing hunted me by my own footsteps'
- **Threshold translation:** Adopt the structure: climax = the encounter's own taught rule turned back on the player, staged in a foreshadowed set-piece, reprised once with a twist. REFUSE the heartbeat timing minigame â€” that is mechanical mastery; re-express breath/noise control as a costed CHOICE (move slow and loud-safe vs fast and heard) so survival stays observation + decision, not rhythm-game timing.
- **Source:** https://www.destructoid.com/all-doors-entities-guide-how-to-survive/ ; https://progameguides.com/roblox/roblox-doors-walkthrough-all-monsters-and-how-to-survive-them/

### 9. [REFUSE] Death/retry system; economy (refused)

- **Mechanism:** Death, retry, and the revive economy: checkpoints exist only at floor granularity (Hotel = 100 doors, Mines = doors 100-200, roughly 60-75 minutes); death without a revive returns you to the lobby to restart the floor. Revives sell for 30 Robux instantly on the death screen (sunk-cost peak) or 120 Robux for 5 in the lobby, limited to one per run and disabled in the last 10 doors of a floor. Knobs (earned currency) buy pre-run items and skins.
- **Causal chain:** Long runs raise stakes -> death at door 90+ is devastating -> the death screen offers a paid undo at the exact moment of maximum loss-aversion -> stakes are real but the fairness of loss is monetized
- **Threshold translation:** Refuse wholesale: no monetization in prototype, and more deeply â€” DOORS buys its dread with the player's TIME as collateral, then sells it back. Our fear source is uncertainty, not sunk time. Project 001 retries at encounter granularity, fast (seconds, not lobby round-trips), because a player who retries instantly will experiment, and experimentation is our whole survival model. The 'no revive in the last 10 doors' rule is the one honest part â€” climaxes must be uncheatable â€” and THAT we adopt.
- **Source:** https://doors-game.fandom.com/wiki/Revives ; https://www.thegamer.com/roblox-doors-revive-complete-guide/ ; https://doors-game.fandom.com/wiki/Knobs

### 10. [ADOPT] Act III (Escalation); The Moral Collapse (staying has a cost, leaving abandons something)

- **Mechanism:** Floor 2 (Mines) formula evolution: from flow-through corridors to DWELL-under-threat â€” generator objectives force players to find and enter codes at four anchor machines (A-D) while entities cycle; environmental hazards make the room itself the entity (flooding rooms that drown you, firedamp that suffocates on overstay); the minecart sequence converts the Seek chase into steering + crouch decisions with Guiding Light arrows marking correct tracks; new entities invert old assumptions (Gloombats punish carrying light).
- **Causal chain:** Objectives that hold you inside danger instead of pushing you through it -> threat cycles repeat while you are mid-task -> dread of the NEXT cycle while your hands are busy â€” occupancy under threat beats flight for sustained fear
- **Threshold translation:** Adopt dwell-under-threat as our Act III spine: The Threshold gives the player a reason to stay in a room that wants them to leave (or is indifferent to whether they ever leave). The room-as-entity idea (flood, firedamp) is purer than any monster for an indifferent world â€” the place doesn't hunt you, it simply has properties, and staying is your decision. Refuse the minecart-style vehicle setpiece for prototype scope.
- **Source:** https://doors-game.fandom.com/wiki/The_Mines ; https://doors-game.fandom.com/wiki/The_Mines_Update ; https://www.sportskeeda.com/roblox-news/beat-doors-floor-2-the-mines

### 11. [ADAPT] Encounter climaxes (all archetypes); marketing/shareability posture

- **Mechanism:** Clip culture engine: what players share are short, one-sentence-describable, reaction-generating beats â€” Screech 'psst' startles, the Dupe knockdown (memed into soundboards), Figure library squeezes, friends' hiding failures during Rush. Multiplayer schadenfreude does heavy lifting; the entities' cartoon-adjacent designs make them meme-able and merchandisable to a young audience.
- **Causal chain:** Legible rules + visible failure + a face you can draw -> spectators instantly understand what went wrong -> clips need no context -> free viral distribution loop feeding 7.4B visits
- **Threshold translation:** We are single-player-first with no startles, so our shareable unit cannot be a friend screaming. Adapt: the clip is the WORLD, not the scare â€” 'you won't believe what this room did' (architecture visibly betraying Euclid, the one-sentence climax of each encounter). This validates the constitution's one-unforgettable-climax law as a distribution strategy, not just a design nicety. Refuse mascot-cute entity design â€” The Threshold's threats should resist fan-art domestication or they stop being indifferent.
- **Source:** https://tuna.voicemod.net/sound/069cb25a-d31a-49e0-b78a-edeeb809fa8d ; https://doors-game.fandom.com/wiki/Screech ; https://roblox.fandom.com/wiki/LSPLASH/DOORS

### 12. [ADAPT] The Silent Witness, Act III/IV

- **Mechanism:** A-90 (The Rooms secret subfloor): a red-light/green-light entity that can spawn at ANY moment (not door-gated) and deals 90 damage if you make ANY input â€” movement, camera, even hiding â€” during its flash. Total stillness is the correct response.
- **Causal chain:** Threat decoupled from the door verb -> no moment is procedurally safe anymore -> ambient vigilance even mid-room -> stillness, a pure decision requiring zero skill, becomes the highest-tension verb in the game
- **Threshold translation:** Stillness-as-survival is the perfect no-mechanical-mastery mechanic â€” anyone can stop; the terror is choosing to keep being still while something regards you. Fits The Silent Witness exactly: freeze while being studied. Must fix DOORS' mobile sin â€” its cue window punishes touch players whose resting thumb reads as input; ours needs a generous, unambiguous pre-cue and input forgiveness tuned for touch.
- **Source:** https://doors-game.fandom.com/wiki/The_Rooms ; https://www.thegamer.com/roblox-doors-complete-rooms-guide/

### 13. [ADOPT] Baffled-bar review gate for all encounters and systems

- **Mechanism:** What LSPLASH would laugh at in a competitor's build (inverted from their craft): telegraphs that reuse a cue channel for two different threats; a hiding system with no anti-camping cost (hide-and-wait trivializes everything); teaching via text popups; a death that names nothing and teaches nothing; scares with no pre-cue (they'd call it a Screech clone without the counter-play); and safe rooms that are truly safe forever.
- **Causal chain:** Any un-owned cue or free safety valve -> players find the dominant boring strategy within a day -> tension collapses to routine -> the game is 'solved' and dies in a platform where retention is everything
- **Threshold translation:** Use as our pre-ship review checklist for every encounter: (1) does every cue belong to exactly one threat, (2) does every coping verb have a cost or window, (3) does every death teach, (4) does every scare have a readable pre-cue and a counter-play, (5) is there any spot where waiting forever wins? If yes to five, LSPLASH can't laugh at us.
- **Source:** Synthesis of https://doors-game.fandom.com/wiki/Hide + https://doors-game.fandom.com/wiki/Guiding_Light + https://www.speedrun.com/roblox_doors/guides/l76ng (analyst inference, flagged as such)

## Trust breaks (their haters are our free QA)

- Ambush spawn compression: if Ambush spawns at doors 2-4 or 2-3 rooms after a Seek chase, Halt, or door 50, there are fewer rooms behind the player, so it rebounds faster with far less reaction time â€” same entity, silently harsher rules depending on invisible spawn context (speedrun.com entity guide; DOORS wiki/Ambush).
- Ambush rebound count (1-6 passes) is pure hidden RNG â€” the player cannot know if it is finished, and guessing wrong in either direction (leave too early / camp too long) kills. Camping triggers Hide's ejection + ~12.5s hiding lockout, which during an active Ambush is frequently an unavoidable death: two individually fair rules collide into an unfair outcome (DOORS wiki/Ambush, /Hide).
- Ambush's raycast origin is higher than Rush's, so 'safe spots' the player verified against Rush silently fail against Ambush â€” the world lies about a learned rule, the definition of a trust break (speedrun.com guide).
- Dupe knockdown stacking with Rush/Ambush: getting jumpscared by a fake door while Rush arrives can chain into an unavoidable double-hit death (DOORS wiki/Dupe).
- Death economics: floor-only checkpoints mean a door-90+ death erases up to an hour, and the death screen sells a 30-Robux instant revive at the exact peak of sunk-cost pain â€” loss-aversion monetization aimed at a young audience (DOORS wiki/Revives; TheGamer revive guide).
- The Mines launch overtuning: developers publicly admitted they made Floor 2 too hard 'because they were used to the gameplay' and nerfed it post-backlash; community threads called it 'just horrible to play' and 'not fun at all,' with players considering quitting over the new achievements (DOORS wiki/The Mines Update; Fandom forum threads 'The mines was not it' and 'how doors' most anticipated update broke me' â€” quotes via search index, primary pages refused direct fetch, HTTP 402).
- Mobile jump-input delay caused mistimed Seek-chase and minecart deaths for roughly 2.5 years before being fixed on April 10, 2025 â€” an input-layer unfairness shipped to the platform's majority audience (DOORS wiki/Controls).
- Screech on mobile: the correct response is a fast camera snap, but swipe-to-look turns a decision into a dexterity test â€” mobile players take 40 damage for their input method, not their judgment (DOORS wiki/Screech + Controls).
- Guiding Light deliberately gives no hint on a first death to Eyes â€” mystery-preserving, but it violates the teaching contract the game itself established: that death always pays out the rule (DOORS wiki/Guiding_Light).
- Subtle-audio dependence: Dupe's faint rumble and Screech's breathing are near-inaudible on phone speakers in a bright room, making the 'information existed' defense technically true but practically false for the majority platform (DOORS wiki/Dupe, /Screech; platform reality).

## Mobile notes

Roughly 70% of DOORS' 7.4B visits happened on the hardware we target, and the game's survival there is instructive. What survives a small bright screen and a phone speaker: light-STATE telegraphs (flicker, color-coded glows â€” Rush white-flicker, Ambush green, Eyes purple â€” readable even with brightness crushed), loud ramping audio (Rush's scream carries on a phone speaker), binary decisions (hide/don't, look down/don't), big on-screen interact buttons, and Guiding Light's shimmer acting as a visual twin for audio information. What dies: faint audio tells (Dupe's rumble, Screech's breathing are lost to speaker compression and ambient noise), fast camera-snap responses (Screech via swipe-look), timing minigames (Figure's heartbeat), stillness checks that read a resting thumb as input (A-90), and pitch-dark rooms on a sunlit screen. DOORS also shipped a jump-input delay that caused unfair mobile deaths until April 2025 â€” proof that input latency is a fairness issue, not a polish issue. Our laws for Project 001: every audio cue gets a visual twin in light or geometry; every correct response is a decision expressible in one tap or one non-action, never a gesture race; dark means 'dark with readable silhouettes,' calibrated on a real phone at half brightness; and input forgiveness windows are part of the trust contract, tested on-device before any 'done' (ledger Rule 8).

## The surprise

The teaching system and the monetization system are the same machine viewed from two sides â€” and the community accepts one because of the other. Death in DOORS always pays out knowledge (Guiding Light's escalating per-entity death hints), which makes hour-long floor wipes emotionally survivable; that tolerance is then harvested by the 30-Robux revive placed on the death screen at peak sunk-cost. We expected the curiosity engine to be the deep finding; instead it's that DOORS made death itself the tutorial currency, then priced it. Second surprise: the most complained-about entities (Dupe, Screech) are simultaneously the most-clipped and most-memed â€” a literal Dupe jumpscare soundboard exists â€” meaning DOORS' unfairness and its virality flow from the same startle moments. That is a trap, not a model: we can take the grammar, the mutation-based escalation, and death-as-information without buying dread with either sunk time or screams.

