# BLUEPRINT — The Threshold: Tower of Experiences ("The First Descent")

**Status:** PROPOSAL — drafted by Claude from Eddy's direction (2026-07-09: the tower-of-floors reframe,
"experiences have no genre", the thread between rooms, waves, multiplayer analysis) + a 5-lens research
excavation (manhwa floor grammar, genre-whiplash games, carryover systems, multiplayer models, worldbuilding),
all filtered through the Master Bible and Project Bible. **Awaiting head ratification of §8.**
**Author of the direction:** Eddy (founder, above-canon call). Claude advises; the heads decide.

---

## 1. The reframe in one paragraph

The Threshold is not a horror game. It is **a tower of experiences you fell into, read downward** — and what
we have built is **Flight One of the First Descent**: its all-horror opening floor. From door to door the
experience is *completely different* (horror, adventure, comedy, mystery, roleplay, engineering — the Master
Bible's "experiences have no genre" made structural), the player never knows what the next door holds, and
rooms connect not by sameness but by **the Thread**: every room's ending gives you something — an object, a
mark, a piece of knowledge — that a later room quietly pays off. Floors chain into waves; clearing a wave
opens the next. The fiction that licenses all of it, one canon line: **"The Threshold keeps everything and
sorts nothing. A joke, a funeral, a battle, an afternoon — it keeps them all and cares for none of them.
Keeping is not caring."** A collection has no genre.

## 2. Structure — Tower > Descent (wave) > Flight (floor) > Door (room)

- **ROOM (a door):** one experience, one dominant memory, one question answered with actions, and exactly
  **one Thread notch** (grants one Keepsake OR pays one off — never zero, never several). Every room carries
  an energy tag (dread / wonder / laughter / thought / adrenaline), an intensity (1–5), and a duration budget
  by energy (laughter 1–2 min … dread 5–10; hard ceiling ~10 — a 10-minute comedy room is a design bug).
- **FLIGHT (a floor):** 3–6 rooms + its Landing ≈ one Roblox sitting (20–40 min). Composition law: exactly one
  **anchor** room (longest, heaviest — the flight's defining memory), at least one **relief** room, one
  authored mid-flight **setpiece** door (the nameable legend — DOORS' Door-50 grammar), and a **finale** room
  that pays off the flight's accumulated Keepsakes and opens the stair down. No two adjacent rooms share
  energy type or length class; every intensity-5 room is followed by intensity ≤2. *Genre unpredictable on the
  surface; the emotional score underneath is authored.*
- **DESCENT (a wave):** 2–3 flights = one arc (One Piece saga-scale). Clearing it triggers the **feast beat**
  at the Landing — gifts displayed, diegetic recap, the next wave's sealed stair grinding open. All thread
  exposition lives in feast beats, never in room climaxes. Waves escalate by **commitment and the tower's
  attention becoming personal** (wave 1 consequence-light; wave 2 remembers your choices; wave 3 gifts become
  losable, some doors one-way) — never by stats. Progression = wisdom, not power.
- **THE CONSTANT FRAME (~5% of runtime — the game's identity across every genre):** a ~10-second **Door
  Ritual** on every arrival (same interaction, held silence, one tower sound motif); a **Gift + Glimpse**
  ending ritual (every ending gives the Keepsake and one one-beat tease of something ahead); one 4–8-note
  audio motif quoted once per room, rearranged in that room's genre; the **Silent Administrator** (one
  non-verbal tower signature present in every room — it sets the condition, observes, never speaks); and the
  **Landing** as the persistent anchor space. The tower's silhouette is always visible (the sealed stair, the
  tallies, the depth below) — the contents never are.

## 3. Naming (Scheme A — "The Stair") — pending head lock

**Descend, don't climb.** The ascent shelf on Roblox is owned by obbies and Tower-of-___ clones; descent at
scale is empty, it inverts (rather than copies) the manhwa references, and our shipped line is already
"DESCEND AGAIN — OR DON'T." Player-facing lexicon: a wave is a **Descent** ("the First Descent"); a floor is a
**Flight**; the hub is the **Landing**; Thread carriers are **Keepsakes**; **doors are never named or numbered
by the world** — players name rooms after surviving them, written into their own record; the place engraves
nothing. Progress is read off the world (a stair unsealing, tallies scratched by unknown hands), never off a
bar. **Door grammar:** *provenance, not prophecy* — every door looks stolen from a different real building
(ballroom door, hospital door, submarine hatch): maximal distinctiveness, zero predictive value. The only
consistent door signals are state (visited / threaded / sealed). **The frame never lies**; subversion happens
inside rooms, never at the frame. ("The Threshold" stays as working title; a titling pass before public
release is logged — it collides with Backrooms-adjacent canon and an existing Roblox game.)

## 4. The Thread — the Keepsake Ledger

**The contract:** every room's ending publishes exactly one Keepsake (a typed, server-authoritative fact) plus
one Glimpse. Every room may consume at most one payoff, placed off-climax (arrival or aftermath — the Keepsake
seasons the meal; the room IS the meal). Every payoff is **recognition, never reward**.

**Four carrier types:** **MARK** (visible on the body; categorical; absolutely stat-free), **ITEM** (near-
unique by design — scarcity is what makes the tape sacred), **KNOWLEDGE** (never stored server-side — it lives
in the player's head, so it can never become a checkable key), **RELATION** (kept/spent-class states).

**Architecture (concept):** a pub/sub ledger — rooms publish typed facts at ending and subscribe *by type* at
beginning with a declared cold default; rooms never reference other rooms (correlation scales N, not N×N).
Commit-at-the-act (rejoin ≠ undo — generalizing Moral Collapse §8, the first Thread ever shipped). Two layers:
the **Descent Ledger** (resets each fresh descent) and the **Permanent Record** (that it happened — forever).
**Fairness invariant, lint-enforced:** no Keepsake read without a cold default, and the cold path must be a
COMPLETE experience — "possible but worse" is a gate in costume. **Presentation:** no menus, no toasts, no
logs — the Landing accretes fixtures (the tape on a shelf, a hook where a hum hovers or a husk hangs), marks
render on the avatar, and knowledge shows *nowhere* — which is where the baffled moment lives.

**Six seeded Flight-1 → Flight-2/3 Threads:** (1) **Your file travels** — a later clerk pulls YOUR record and
quotes one true fact from your Flight-1 run. (2) **The tower has one pulse** — the Violent Rhythm's time
signature is the tower's metabolism; later machinery keeps it; veterans recognize it in two bars. (3) **The
answering call** (flagship) — the companion kept/spent RELATION echoes for the rest of the descent: kept, far
hums answer you; spent, the same scenes run as consequence-by-absence. (4) **Trained instinct, paid off and
betrayed** — "it moves when you look away" gets one loyal payoff (an escortable ally-statue) and one comic
betrayal (a thing that moves only while watched). (5) **The tape** — one of the tower's only physical items;
its meaning is re-cut twice, and a later wave identifies the second walker. (6) **Marks on the body** — the
ember-ring at the collar (the spender's mark is absence); NPCs bow to it or roast it; caps at ~4 marks per
wave; the future multiplayer conversation engine ("what's that ring?" — the answer is a story, never a stat).

## 5. Floor One retrofit — document, don't rebuild

The existing build already fits the skeleton. The retrofit is frame and contract, not content: reclassify
(entrance = the threshold-crossing; the four rooms = Flight 1, Watcher as anchor, Moral Collapse as finale;
the ending room = THE Landing); fold the Door Ritual + Gift/Glimpse into the shared frame; retro-declare the
five Keepsakes Flight 1 already almost grants (file, pulse, call, tape, ember-ring — the seed vault); promote
the Landing to a persistent accreting space with the sealed stair visibly going DOWN; sweep player-facing
strings for numbered floors/doors (none allowed); backfill room metadata (energy, intensity, duration,
dominant-memory statement, one foreshadow leak per room from Flight 2/3). **Honest flag:** Flight 1 is four
dread rooms back-to-back — it violates the energy-alternation law as a standing floor. Recommended: ship it as
the all-horror anchor flight (the First Descent's tonal ground truth) with the variety detonating at Flight
2's first door; whether to later insert one relief room is a head decision (§8), and the architecture makes it
cheap either way.

## 6. Multiplayer — four phases, every phase passing the Ch.6 gate

*(The law: if another player doesn't fundamentally change the experience, the room stays solo — and that's
fine: witnessing a friend's solo room is itself multiplayer.)*

- **Phase 0 (now → Flight 1 ship):** ship SOLO. Land the Party Contract silently in the architecture (per-room
  CoopSpec; layered party/per-player session state; attributed events on every binding act; an AFK/disconnect
  resolver — after ~20s the tower "takes" the absent and the room re-solves; the fiction is already canon: an
  indifferent tower does not wait). Solo Descent stays first-class forever; friends-only parties (2–4), no
  stranger matchmaking.
- **Phase 1 (post-ship pilot):** **The Landing Fire** — parties run rooms as parallel solo runs seeded with
  DIFFERENT variants, reuniting at shared Landings, so landing talk is genuine information trade ("your room
  had WHAT?"). Plus the cheapest true co-op: the **duo attributed Moral Collapse** — first actor binds all,
  loudly attributed ("JEFFERSON chose for both of you") — shared blame in its smallest form.
- **Phase 2:** the **separation-beat doctrine** for horror rooms admitting a party — mechanically motivated
  splits inside ONE active stage, individualized threats (your own Watcher hunts YOU; grouping is priced),
  reunion always staged at the exit door (the door also promises your friend back). Wave-2 comedy/engineering
  rooms are authored 1–4 flexible from day one — co-op friction IS their joke.
- **Phase 3:** **The Interpreter** — the first multiplayer-FIRST flight, duo-locked: the server secretly picks
  which player perceives the threat; the seer talks the blind partner through; halfway, perception swaps
  without warning. Categorically impossible alone. Ships with **witness doors** (one enters; the party watches
  through a warped pane and controls exactly one lever) and **cross-player Keepsakes**.
- **Standing laws:** party caps by room type (2 for trust/moral/asymmetric-horror — blame is sharpest at 2;
  3 for odd-one-out designs; 4 only for comedy/engineering/Landings); no co-op difficulty scaling by power
  knobs — scale with information, roles, objectives; **no anonymous binding acts, ever** — attribution is the
  anti-grief system.

## 7. Extensibility — the unit of addition is ONE ROOM

One room = one stage file + one manifest entry (energy/intensity/duration, CoopSpec, GRANTS one Keepsake,
PAYS_OFF optionally by type with mandatory cold default, plus the four assets that define done: a provenance
door, an earned-name slot, one payoff hook, one dominant-memory statement — missing any = a labeled stub).
Rooms couple only to ledger *types*, never to each other, so adding a room never renumbers the world. The
shared frame is inherited free — a new room *physically cannot* deviate from the game's identity. A flight is
an ordered list the energy-alternation assembler validates; a wave is a list of flights + one Landing redress.
The fiction is extensible for free, forever: the Keeping simply kept one more thing. **The escape valve that
keeps quality above quota: a flight with only three baffling rooms ships with three.**

## 8. Refusals (what this blueprint will never do)

1. **The relic trap** — no Keepsake ever grants numeric power. One power-bearing thread turns the tower into a
   build game and breaks wisdom-not-power. Refused even once.
2. **The soft gate** — every payoff's cold path is a complete experience; "possible but worse" is a gate in
   costume.
3. **The toast trap** — no ACQUIRED! popups, no collection screens, no counters, no quest logs. The tower's
   memory is diegetic only. If the player ever sees a system label for the Thread, we failed.
4. **DOORS-speak and the ascent shelf** — never "Door 47" / "Floor 2" as player-facing nouns; never "Tower
   of ___"; never frame the game as a climb.
5. **Prophecy doors** — no door signal ever encodes content (wiki-decoded in days; curiosity dies). Doors
   signal provenance and state only. The frame never lies.
6. **The curator** — the place never explains itself, performs, or laughs. No mascot, no narrator, no origin
   dump. The full answer to "what IS the Threshold?" is permanently withheld.
7. **Co-presence multiplayer** — never spawn friends into unmodified solo rooms; never delete or matchmake
   over the solo experience.
8. **The filler room / frame creep** — never build a room because "the flight needs five"; the ritual frame
   stays ~10s; rooms never remap controls to sell their genre. One mediocre room taxes trust in every future
   door — and door-trust is the core loop's fuel.

## 9. Open head decisions (Eddy / Jefferson — the blueprint waits on these)

1. **Ratify the descent inversion** — the tower you FELL INTO, descended toward understanding (matches shipped
   text; inverts rather than copies the references).
2. **Lock the lexicon** — Descents / Flights / Landings / unnamed doors / Keepsakes; log the ship-titling pass
   ("The Threshold" collides with Backrooms-adjacent canon + an existing Roblox game; fine as working title).
3. **First Descent composition** — recommend 3 flights before the first wave-seal; and Flight 1 ships all-
   horror (variety detonates at Flight 2's first door) vs. retrofitting one relief room into Flight 1.
4. **Fresh-descent semantics** — can a player voluntarily restart a descent; recommend Landing fixtures grey
   out but remain (the tower remembers even what you reset).
5. **Permanent Record surfacing** — recommend never shown as a screen; only through world/NPC recognition.
6. **Multiplayer Phase 1 timing** — before or after Descent 2 content begins; confirm friends-only 2–4 as
   standing law.

---

*Sources: Eddy's direction (2026-07-09); Master Bible v3.0 (Ch. 3 "Experience Library"/"Every Door Is A
Promise", Ch. 4–7 Part II, Ch. 6 multiplayer law); Project Bible v1.0 (The Threshold, progression = wisdom);
excavation lenses: Tower of God's Administrator/test grammar, One Piece's 8-beat arc shell + feast beat, Made
in Abyss's irreversibility escalation + known-shape/unknown-substance, SAO's ambient macro-goal, Solo
Leveling's legible-then-violated telegraphs, Pick Me Up!'s cadence law, The World After the Fall's epistemic
macro-thread; WarioWare/Inscryption/Undertale/Stanley Parable/Regretevator/DOORS genre-whiplash anchors; Hades
keepsakes / Slay the Spire relics / Outer Wilds knowledge-keys / Tunic; plus our own shipped Moral Collapse
choice-echo (the first Thread).*
