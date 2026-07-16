# Steps to the Baffled Bar — Project 001 (Floor One → the Tower)

**The bar (Eddy, locked):** not "good", not "wow" — **"this cannot exist."** Every line, color, motion,
room, sound. If it looks average — if I can imagine better — it isn't done. Ship-thinking-100% = 20%.
**Written 2026-07-09, after playability was restored and verified in-game.** This is the honest map from
"a navigable blockout" to the bar.

---

## 1. Where we honestly are

Two different axes, and I will never again conflate them:

- **Functionally:** the full loop plays end to end — Beginning → four encounters → Ending → loop, server-
  authoritative, navigable, no soft-locks known. Call it **~40%** of a real single-player prototype.
- **On the baffled-bar quality axis:** **~15%.** It is gray-concrete blockout, stub audio (built-in samples),
  no environment art, no creature mesh, placeholder text framing. It is *playable*, which per Eddy's own law
  is NOT the same as *done* — "the prototype is playable only when we, at our level, get to 100%, not after."

The gap to the bar is not bugs anymore. It is **craft** — and most of it is code-controllable *right now*,
without waiting on the art or audio departments.

## 2. The hater pass — what each persona sees today (cited to what I've watched in-game this session)

- **The demanding art director:** every room is the same jittered gray concrete. No per-room visual identity,
  no deliberate composition, no silhouette design, no color story. The amber road reads, but the world around
  it is a warehouse. "Still template. Still blockout with a coat of fog."
- **The DOORS/Pressure veteran:** the *systems* are novel (the weeping-angel light-freeze, the surge, the
  companion choice) — but visually it reads as a hundred other Roblox horror blockouts. Nothing here yet makes
  them screenshot it.
- **The streamer:** the surge (lights blow, the Watcher lunges, sprint for the door) is the one clippable beat
  — and right now its *presentation* (a dim boom + parts going dark) undersells a genuinely great mechanic.
  The Ending — the beat players remember most (Bible Ch. 7) — is the thinnest room in the game.
- **The 9-year-old on a low-end Android:** navigable now (fixed), but the whole game is one dark tone with no
  relief, no wonder, no moment of awe or laughter — exhausting, and nothing that says "you have to try this."
- **The QA lead / exploiter:** the code floor is genuinely strong (triple-reviewed, server-authoritative,
  0/0 lint) — this tier is NOT the weakness. The weakness is entirely presentation + felt experience.
- **Eddy:** "did your thinking touch this?" — it has touched the *logic* deeply; it has barely touched the
  *surface*, which is where the bar lives.

## 3. The steps — ordered, code-first (what raises the bar fastest, with no new assets)

**A — Per-room visual identity (biggest lever, all code).** Kill "one gray warehouse." Each room gets its own
light temperature, palette, material discipline, and composition so the door-to-door *feels* like different
worlds (the whole point of the tower). Lighting as authored composition — key/fill/rim, pools of meaning,
negative space — not uniform fill. This alone moves blockout toward "how is this Roblox?"

**B — The signature beats, presented to kill.** The surge (I), the witnessed price (II), the second footsteps
(III), the hum stopping (IV) — each needs its *presentation* pushed to the bar with pure code craft: timing,
camera-independent tells, light choreography, procedural motion. One unforgettable moment per room, delivered.

**C — The Ending, rebuilt.** Highest memory-weight room, currently the thinnest. It carries the aftermath of
the choice and the "AGAIN?" pull — it deserves the most craft, not the least.

**D — Every line of text to the bar.** The rules cards, objectives, signs — currently functional, not
persuasive. Copy contextualized to The Threshold (indifferent, impossible), never interchangeable.

**E — Motion & micro-detail everywhere.** Procedural life on static geometry (the Watcher already does this) —
flicker, drift, settle, breath — so nothing is dead. Sub-perceptual until it matters.

**F — Mobile-first parity of all the above** (70% of players): every beat readable and performant on a phone.

**Dept-gated (real, not excuses — deferred by dependency):** real audio foley (the single biggest *felt*
jump), environment art / meshes, the creature model. These lift the ceiling further once assets exist; the
code craft in A–F is what we drive to 100% *at our level* first.

## 4. The shift — this is Floor One of a Tower

Per the ratified direction ([blueprint-the-first-descent.md](blueprint-the-first-descent.md)): what we've
built is **Floor One (the horror floor)** of **The Threshold — a tower of floors**, where a floor is a
*sequence of rooms* (related or not, by our design) and **every door is a completely new experience** — horror,
adventure, comedy, mystery, engineering. The player never knows what the next door holds; rooms connect by the
**Keepsake thread** (each ending gives something a later room pays off). Clear floors → a wave → the game
becomes the talk of the room, the school, the world.

**The bar applies to the tower's own language too** (Eddy: "even the lexicon"). The lexicon is drafted
(Descents / Flights / Landings / Keepsakes) but NOT yet at the bar — that's part of what we study together.

## 5. What we study together (the "at the end" session)

1. Ratify or sharpen the tower lexicon to the baffled bar (the drafted words are a starting point, not the
   ceiling).
2. The floor-authoring recipe: how we compose a *sequence of rooms* (the energy/intensity/variety rules), so a
   floor is designed, not assembled.
3. The first non-horror floor / the multiplayer adventure room (you asked for "an adventure section with lots
   of players") — designed multiplayer-first.
4. The six open head decisions in the blueprint (§9) — your calls.

## 6. Honest bottom line

Playability is restored and banked — that was the wall between us and *any* forward progress, and it's gone.
We are at **~15% on the bar.** The path from here is craft, most of it code, and I drive it in **verified
increments** — each beat elevated, then seen with my own eyes before it reaches you, never claimed done. No
more blind changes. Point me at the first room and I go, or we open the study session — your call.
