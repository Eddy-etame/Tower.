# EXPERIENCE: The Hidden Presence

**Archetype:** The Hidden Presence — doubt → dread → revelation
**Designer:** Eddy + Claude · **Date:** 2026-07-06 · **Status:** Stage 2 draft — Gate B verification in progress (Gate A APPROVED by Eddy, 2026-07-06)
**Target playtest utterance (pass criterion):** *"it was HERE?"* — unprompted, at least once per playtest.

> **AS-BUILT (2026-07-09):** a playable MVP SLICE of this encounter is implemented (server-authoritative, blockout, stub audio) — see the 2026-07-09 entry in [decisions.md](../decisions.md). This doc is the fuller design INTENT; the build is the MVP truth (the tape reveal + paced silence are in; the "presence sits between you and the goal" routing is deferred). Reconcile when render-tuned.

---

## STAGE 1 — THE WHITEBOARD

**Inspiration** — P.T.'s Lisa (physically attached to the player's back the entire game — every cue a TRUE emission, hidden only by camera framing), Phasmophobia's instruments-confirm-what-senses-suspect loop, the sound-shadow technique (a presence known by what *stops*), Darkwood's two-pool audio grammar — extracted into the studio's own law: **simulate the presence for real from Act I and hide it only from the senses, never from the simulation.** Ambiguity is a property of the player's perception, not of the world's truth. (Research: [craft-hidden-presence.md](../research/craft-hidden-presence.md) findings 4, 6, 7, 10.)

**Emotion** — **Doubt curdling into dread, resolved by revelation that makes it worse.** Studio law honored: sometimes learning the truth should make an encounter MORE terrifying — here, certainty is the climax and the cost.

**Hook** — Act I teaches the room's breath: vents, pipes, a low mechanical hum — the Threshold's constant bed (no music, ever). Then the player walks through a patch of corridor where the bed just... **stops.** Three steps of nothing. Then it returns. Nothing visible changed. The first evidence is an *absence* — the one cue that reproduces perfectly on every phone speaker on earth, even nearly muted.

**Memorable Moment** — The player finds a tape recorder (the room's one instrument — incorruptible, per trust law: our instruments never lie, they only have limits). They record the empty, silent room. They play it back. Under their own recorded footsteps: **a second set — half a step behind, stopping when theirs stopped, one beat late.** The room was silent. The tape is not. And because the presence is simulated server-side from Act I, the tape is *true* — on replay, players who track where they walked can reconstruct where it walked. It has been pacing them the entire encounter.

**Experience in one sentence** — *You record an empty room, play the tape back, and hear the second set of footsteps.*

**Replayability** — Theory-testing at its purest: the presence's position is real each run, so the evidence (silence patches, tape captures, the hum gradient) genuinely varies. Players replay to map it, bait it, or beat the encounter WITHOUT ever confirming it exists — and discover that not-knowing follows them out.

**Multiplayer** — *What changes when a second human is present?* Asymmetric knowledge: one player hears the silence move; the other is standing inside it. "It's next to YOU" is a sentence only multiplayer can produce. (Prototype: single-player; field carried per audit F13.)

**Runtime Test** — Deserves to exist because the platform's rising observation-horror wave (Exit 8 at 127M+ visits) still resolves every doubt visually. Nobody has shipped *audio-forensic* horror — doubt you investigate with your ears and a tape — and nobody has shipped a presence that is honestly simulated rather than staged.

### The Five Questions
1. **What inspired this?** Lisa's honest geometry + Phasmophobia's evidence loop + sound-shadow craft, fused into an encounter about *verification*.
2. **What emotion?** Doubt → dread → the worse-knowing.
3. **What question is the player answering?** **"Is something here with me?"** — and its razor edge: *do I actually want to find out?* (No other encounter asks this.)
4. **What is the unforgettable moment?** The tape playback.
5. **Why will players remember this?** Because the reveal is inevitable-in-hindsight: every earlier "false alarm" was true, and they can prove it — the honest simulation converts memory itself into the horror.

### Runtime Test checks
Curiosity: the silent patch demands investigation ✓ · Fun: active verification verbs (record, walk the hum gradient, corner-check) — doubt with homework, never passive waiting ✓ · Memory: the second footsteps ✓ · Conversation: "play it back. PLAY IT BACK." ✓ · Originality: audio-forensics + honest-in-geometry presence — unshipped on the platform ✓ · Purpose: embodies Pillar 4 — the world never lies, even about what it hides ✓

### Mechanical spine (for Gate A honesty — full design is Stage 2)
Presence instantiated server-side in Act I: real position, real movement, honest side-effects — hidden by framing, light, and assumption only · **silence radius**: the ambient bed ducks by proximity to it — absence is a true positional signal (walk the gradient of missing sound = triangulate by ear) · two-pool audio grammar (threat sounds: positional, intentful, consequential · ambient sounds: diffuse, consequence-free — the grammar is learnable, Darkwood-proven) · the recorder: confirms but never locates; using it costs stillness and time (verification = exposure) · every audio tell has a **visual sibling** (the recorder's needle jumps for the second footsteps; dust settles where the bed died) for muted/mobile players · confirmation-beat economy: doubt punctuated every few minutes by one small undeniable payout, escalating denominations, biggest note last (tension-curve law) · **REFUSED:** stated false rules (Amnesia's single-use lie), directorial beats the simulation can't truthfully deliver, pitch-only tells (dead on phone speakers — archive's named failure).

> **GATE A — APPROVED (Eddy, 2026-07-06).**

---

## STAGE 2 — THE DESIGN (Constitution climax-first order)

### 1. Climax Moment
**The tape plays the player's own footsteps back — with a second set underneath, half a step behind, stopping one beat late.**

### 2. World-Changing Lesson
**Silence here is not empty — it is occupied.** (One thing: absence is positional information. It inverts a learned instinct — the canon example "silence is more dangerous than noise" made mechanical — and it stays true for the whole game.)

### 3. Core Question
**"Is something here with me?"** — with its razor edge: *do I actually want to find out?* Unique across the four docs.

### 4. The Threat & Threat Ambiguity
The presence is **real from the first second of Act I** — a server-side entity with true position and movement, honest side-effects, hidden only by light, framing, and the player's assumptions (the P.T./Lisa proof: simulate the truth; control only what frames it). The ambiguity is never "does the world contain it" — it is "can the player's senses find it." It does not hunt. It **keeps distance** — it paces the player, maintains its gap, and its one intolerance is having its gap closed: **the rule is physical, never intentional** — ANY closing of the gap, deliberate or panicked, makes it yield, and the yielding is the warning (see Failure). Reconciliation of the Act I hook (panel fix): the dead patch the player first walks through is a **cooling absence** — the bed recovers slowly where it recently stood — never its live position; walking through residue was never an intrusion, so the taught rule has no exceptions. What the player first assumes is danger (the settling knocks, the groans — the ambient pool) is harmless; what they assume is safety (quiet) is the thing itself.

### 5. Discovery Design
- **Act I builds the bed:** the Threshold hum — vents, pipes, distant machinery (no music) — taught until the player stops hearing it. The two-pool grammar (Darkwood-proven) establishes by consequence-free repetition: ambient sounds are diffuse and harmless; positional, intentful sounds mean something.
- **First evidence is an absence:** a patch of corridor where the bed just stops — three steps of nothing. The **silence radius** is honest geometry: the bed ducks by proximity to the presence, so the quiet zone is literally centered on it. Walking the gradient of missing sound is triangulation by ear.
- **The instrument:** a tape recorder on a maintenance table — incorruptible (trust law: instruments never lie; they have LIMITS — the recorder's gain exceeds the human ear, which is precisely why the tape can hear what the player cannot).
- **Confirmation-beat economy** (tension-curve law): every few minutes of "maybe nothing," one small undeniable payout — the door you closed standing open; dust falling from nothing; a displacement knock — escalating denominations, biggest note last.

### 6. The Five Acts (progressively shorter)
- **Act I — Arrival:** corridor network, one anchor per identical corridor (archive repetition architecture); the bed taught; the grammar taught. ~4 min.
- **Act II — Discovery:** the dead patch — and on re-entry it has **moved**. An absence with a position is an occupant. The recorder found **with a previous occupant's tape already in it: playing that tape (one button, the taught verb) demonstrates footsteps-on-tape and hands the player the hypothesis without a word** — the Act IV experiment becomes the obvious next move, not an unprompted leap. First self-recording teaches the tool's honest limit on the player's own sounds. ~3 min.
- **Act III — Escalation:** triangulation play — the silence sits between the player and where they need to go; deliberate approaches produce **displacement warnings** (a knock ahead, dust, the patch shifting away — warnings one and two); the dread compounds: it is polite, and that is worse. ~3 min.
- **Act IV — Climax:** the player records themselves walking the long corridor, then plays the tape back in a quiet room. Under their own steps: the second set. Half a step behind. Stopping one beat late. The room was silent; the tape is not — and every earlier "false alarm" retroactively becomes evidence. ~90 sec.
- **Act V — Resolution:** the exit — with the silence sitting beside it. The player walks past an occupied quiet they can now read exactly, hearing precisely where it stands by what refuses to sound. Out. ~30 sec.

### 7. Choice Points (2–3, each viable but risky)
1. **Instrument route:** record and confirm — certainty, paid for honestly: **while the player stands still, its pacing gap closes** (a true consequence of the pacing simulation — stillness lets it drift nearer, and the quiet tightens around the recording spot). Verification is exposure, delivered by the simulation, not asserted.
2. **Ear/eye route:** read the gradient (sound or its stillness-twin) and never confirm — faster, and the encounter can be finished without ever knowing; the not-knowing follows the player out. **Its designed peak is the Act V exit-pass, promoted to a full climax beat for this route:** the bed dead, the lamps low, a hanging chain motionless at arm's length — walking past an occupied silence you can read exactly.
3. **Herding route:** spend the two warnings deliberately — press the silence's edge to move it off the exit path, each press scarring the world where it yielded. Advanced, fair, and one mistake from the third close.

### 8. Information Map (Trust)
Bed ducking = true positional signal, always — **with an always-on visual twin inside the radius: lamps lose confidence (dim to a steady low) and hanging/loose objects go dead-still** (the quiet is *visible as stillness*; the cut-list ban covers the presence's BODY, never its field) · live patch vs. cooling residue = full quiet + stillness vs. bed fading back in (learnable) · displacement warnings = **compound two-sense events with a signature no ambient sound shares**: the yield-knock always co-occurs with a visible source object reacting ahead (a door swinging, a hanging lamp jolting) AND the patch visibly/audibly shifting — warnings 1 and 2, always in order, **and each spent warning permanently scars the world at the intrusion point (a corridor lamp dies for the rest of the encounter): the count is readable in the environment, never hidden** (warnings re-arm on wake; scars remain as history) · tape = truth at gain the ear lacks, **with an honest stated LIMIT: a short capture radius** — in open rooms its pacing gap exceeds capture range (tapes stay clean); **the long corridor is the one space narrow enough to force its pacing line inside capture range** — the geometry, not a script, makes the climax possible · playback renders as **two visually separated impulse rows on the recorder face** — your steps on one row, the extra steps on the second, firing after yours stop: the muted player and the stream viewer both READ the climax, not just hear it · two-pool grammar: threat sounds positional/intentful/consequential, ambient sounds diffuse/consequence-free — learnable, never violated. **REFUSED:** stated false rules, pacing beats the simulation can't truthfully deliver, pitch-only tells, intent-classifying triggers.

### 9. Failure Design
Third gap-close = it **passes through you**: total sensory blackout — every sound gone, screen to black — ~1.5 seconds, then the player wakes at the act's start. No gore, no scream, no jump-cut face. The trigger is physical (proximity), never a judgment of intent; telegraphed twice by compound two-sense warnings; the spent-warning scars make the count visible between attempts. Instantly attributable ("it stepped aside twice — I pressed again"). It teaches the boundary rule and makes the next approach unbearable in exactly the right way.

### 10. Sound Design (no music)
This encounter IS the audio doctrine: a layered bed (mid-band, mono-safe) whose *subtraction* is the threat channel — absence reproduces perfectly on every phone speaker on earth, even nearly muted (physics-level argument from research) — and the subtraction is co-rendered visually as lamp-confidence and object-stillness, so the fully-muted player keeps every route including the ear route's visual twin. Tape playback mixed dry, close, mid-band, with the two-row impulse display carrying identity, not just existence. Directionality is never load-bearing (mono law): the gradient is volume-coded, not stereo-coded. Silence as the loudest tool is this encounter's entire thesis.

### 11. The Space
Identical corridors, one anchor each — the architecture denies landmark memory so the EAR becomes the map (self-doubt primes acceptance of wrongness). Fog, not darkness, for occlusion (raises luminance while hiding distance — Silent Hill's trick, mobile-native). The presence never gets a mesh: it is a position, a ducking radius, and a footstep emitter. Zero art budget where imagination outperforms it.

### 12. Mobile Sanity Notes
Absence survives every speaker and every volume ✓ · needle sibling for the deaf channel ✓ · fog over darkness (Roblox renders darker on mobile — documented DevForum issue) ✓ · full doubt→dread→revelation arc inside one 10–15 min sitting ✓ · volume-coded gradient, no stereo dependency ✓.

### 13. The Cut List
**Cut:** any visual manifestation, ever — silhouette, shimmer, distortion; the tape IS the sighting · voice phenomena (no voices in the Threshold; spirit-box residue reads as another game) · a second presence (one occupied silence, undiluted) · directional-audio puzzles (mono phones) · a "banish/repel" mechanic (it cannot be fought; it can only be known and given room).

---

## GATE B — run before heads review

- [x] Five acts, progressively shorter · one-sentence climax · one core question
- [x] Teaches exactly one thing · discovery organic · all info available · 3 valid approaches · "what if I never played the tape?" built in
- [x] Replay-worthy (its position is real each run — evidence genuinely varies) · tellable ("play it back. PLAY IT BACK.") · permanent shift · failure teaches
- [x] Climax fast · consistent · zero mechanical mastery · respects time
- [x] Warden diff vs RULES.md 1–17: clean · Eight properties: present

### Self-flagged defects (Rule 11) + Gate B panel results (2026-07-07, see GATE-B-PANEL.md)
| # | Source | Defect | Status |
|---|---------|--------|--------|
| 1 | QA (self) | Softlock: completable with zero recorder use? | VERIFIED — ear/eye route full path; exit never gates on confirmation |
| 2 | 9-year-old (self) | Tape playback as a verb for young players | FIXED beyond mitigation — previous occupant's tape teaches it by demonstration (§6 Act II) |
| 3 | Veteran (self) | Spirit-box adjacency | MITIGATED — no voices; your-own-footsteps differentiator loud |
| 4 | Exploiter (self) | Entity position replication | ENGINEERING RULE — position never replicates; server computes mix weights. For T8 |
| 5 | Panel CRITICAL | Warning count was an invisible counter — the archive's own REFUSED pattern | FIXED — each spent warning permanently scars the world (lamp dies); count readable in-world; re-arm semantics stated (§8, §9) |
| 6 | Panel CRITICAL | "Deliberate intrusion" required an intent classifier the simulation can't honestly run | FIXED — trigger is purely physical proximity; Act I hook reconciled as cooling residue, never live position (§4) |
| 7 | Panel CRITICAL | Fully-muted player lost the discovery gate, one route, and the warnings | FIXED — always-on stillness/lamp-confidence visual twin of the radius; compound two-sense warnings (§8) |
| 8 | Panel MAJOR | Recorder gain paradox: an unlimited recorder detonates the climax anywhere | FIXED — honest capture-radius limit + corridor geometry makes the climax possible; invariant written into §8 |
| 9 | Panel MAJOR | Ear-route players reached Act V with no climax | FIXED — exit-pass promoted to that route's designed climax beat (§7) |
| 10 | Panel MAJOR | Verification "cost" was asserted but the simulation delivered no risk | FIXED — stillness lets the pacing gap close; cost delivered by the simulation (§7) |
| 11 | Panel MAJOR | Needle showed existence, not identity; climax illegible muted/on-stream | FIXED — two-row impulse display on the recorder face (§8) |
| 12 | Panel (open) | Act timings 4/3/2.5/1.5/0.5; radii, gaps, and capture range are tuning-module numbers | OPEN — playtest items |

### Honest %
**Design doc ~78%** — gaps to 100: all radii/gap invariants need tuning + playtest; recorder UX unprototyped; no blockout; target-utterance playtest not run; head evaluation pending.

---

*Sources: [craft-hidden-presence.md](../research/craft-hidden-presence.md) (13 findings incl. the P.T. honest-geometry proof and the two-brain pacing caution), [archive-horror-castle.md](../research/archive-horror-castle.md) findings 1, 8, 10 (two-tell counterfeit law; silence-as-climax; repetition architecture + wrong reflections), [teardown-rooms.md](../research/teardown-rooms.md) (baseline-and-deviation as the whole fear engine).*
