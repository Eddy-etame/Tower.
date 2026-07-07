# EXPERIENCE: The Moral Collapse

**Archetype:** The Moral Collapse — guilt → helplessness → moral weight
**Designer:** Eddy + Claude · **Date:** 2026-07-06 · **Status:** Stage 2 draft — Gate B verification in progress (Gate A APPROVED by Eddy, 2026-07-06; hum ruled diegetic SFX)
**Target playtest utterance (pass criterion):** silence, then — *"did I have to do that?"* — unprompted, at least once per playtest.

---

## STAGE 1 — THE WHITEBOARD

**Inspiration** — Papers, Please's care bootstrap (one benign interaction binds you to the future victim in under a minute) and mercy priced in survival currency; SOMA's unplug scene (both options are actions, both permanent, zero reward differential, zero judgment); This War of Mine's unresisting victim (nothing stops you — that's the horror); Undertale's consequence-by-absence — extracted through indifference: **The Threshold never scolds. It only remembers.** (Research: [craft-moral-collapse.md](../research/craft-moral-collapse.md) findings 3, 4, 6, 9; the study's master lesson: guilt is authored AFTER the choice, by a world that quietly re-presents your own act to you.)

**Emotion** — **Guilt → helplessness → weight.** Age-calibrated by construction: the transgression is *taking* and *abandoning*, never violence — regret is 9+, cruelty is not.

**Hook** — Somewhere in the dark early rooms, a small warm light finds the player. It isn't a tool and it isn't a pet: it's the only thing in the Threshold that has ever *responded* to them. It hums — softly, diegetically (not music; it is a creature sound). It drifts ahead at doorways. And once, in Act II, when something in the dark came close — **its light is what made that thing stop.** The player receives help before they know they'll have to pay for it. That is the care bootstrap, and it is mandatory-path: no player misses being saved.

**Memorable Moment** — The way out requires light to cross — and the only light that fits is the small thing that has been lighting the way. It settles into the socket **on its own** when carried close; it does not resist; it never resists. As the mechanism drains it, its hum slows, lowers... stops. The door opens. **The world does not react at all.** No sting, no darkness-surge, no acknowledgment — the Threshold simply continues. The player stands in an open doorway they no longer feel good about walking through. And one room later, the far-off answering hum they'd learned to listen for — the other one of whatever it was — calls once, and nothing answers it.

**Experience in one sentence** — *The only key to the way out is the small light that kept you alive — and it doesn't resist.*

**Replayability** — The other path haunts: cross the dark instead (real, survivable, and it *costs* — you arrive marked: your own light-source dimmer for the rest of the run, a capability price you feel in every later room). Restitution without absolution: the room stays re-enterable; what you spent stays spent, but what you abandoned can still be returned to — the world updates the victim's state and keeps one permanent mark either way. And the choice **commits server-side the instant it happens** — rejoining is not an undo; the Threshold remembers between visits. Almost no Roblox game uses per-player moral persistence: we'd own "the place that remembers what you did" nearly uncontested.

**Multiplayer** — *What changes when a second human is present?* The light can only be spent by one player's hand — and both must live with what one of them did. Or crueler: light enough for one crossing. Who carries it? (Prototype: single-player; field carried per audit F13.)

**Runtime Test** — Deserves to exist because Roblox horror has chase, hide, and solve — and essentially zero *carry*. Piggy's true ending proves this audience embraces mercy-vs-cost beats; nobody has built an encounter where the cost is something that trusted you.

### The Five Questions
1. **What inspired this?** The moral-weight canon (Papers Please, SOMA, This War of Mine, Undertale) compressed into one room, one companion, one door.
2. **What emotion?** Guilt carried, not performed — the world refuses to feel it for you.
3. **What question is the player answering?** **"What is my way out worth?"** (No other encounter asks this.)
4. **What is the unforgettable moment?** The hum stopping — and nothing in the world caring that it stopped.
5. **Why will players remember this?** Because both options were truly theirs (symmetrical cost, zero reward differential, zero judgment), the consequence is audible forever after, and the game still remembers next session.

### Runtime Test checks
Curiosity: what is this thing, and why does it help? ✓ · Fun: genuine dilemma with discoverable stakes — foreknowledge law: the true cost of BOTH paths is discoverable in the room before choosing ✓ · Memory: the stopped hum ✓ · Conversation: "I took it / I couldn't take it" — the comparison argument IS the design ✓ · Originality: unresisting cost + indifferent aftermath + cross-session memory — unshipped on this platform ✓ · Purpose: proves encounters can wound without violence, at zero gore, on a 9+ platform ✓

### Mechanical spine (for Gate A honesty — full design is Stage 2)
SOMA choice-architecture test applied verbatim: (a) every approach is an action, not an abstention; (b) each leaves a different permanent mark on the same world; (c) reward differentials are zero; (d) the world's tone stays identically indifferent while its facts diverge — if a player can identify the developer-approved option, the encounter has failed · care bootstrap mandatory-path in Acts I–II (received help before the price is known) · unresisting victim: taking is mechanically trivial, morally expensive · routed aftermath: the exit path passes what the choice cost, walking pace, no timer, no commentary · consequence readout is audio + absence (the hum that stops or persists; the answering call unanswered) — mobile-proof, zero triangles · server-side commit + DataStore persistence (rejoin ≠ undo) · **REFUSED:** forced complicity then blame (Spec Ops), fake branches (Telltale — Roblox players compare outcomes on YouTube within hours), moral meters, scolding, gore, and any consequence the player can't trace to their own act.

> **GATE A — APPROVED (Eddy, 2026-07-06). Hum ruled diegetic creature SFX — legal under the no-music directive.**

---

## STAGE 2 — THE DESIGN (Constitution climax-first order)

### 1. Climax Moment
**The small light settles into the socket by itself, and its hum slows and stops while the player watches the door open.**

### 2. World-Changing Lesson
**Nothing here will stop you.** (Exactly one thing — the Threshold's moral permission: it never prevents, never punishes, never comments. The *remembering* is not a second lesson; it is the mechanism paying off The Silent Witness's already-taught lesson — being seen becomes being recorded — panel fix for one-lesson purity and cross-doc uniqueness.)

### 3. Core Question
**"What is my way out worth?"** Unique across the four docs.

### 4. The Threat & Threat Ambiguity
Threat ambiguity from the Constitution's own list: **the exit is the problem.** The apparent threat is the shape in the dark passage (heard, never seen — a dry rattle and slow exhales); the actual threat is the choice the exit architecture forces. The shape is honest and rule-bound, **stated once, enforced identically everywhere (panel alignment):** it lunges at *fast motion and sustained noise*; slow, quiet movement is beneath its notice — and the light freezes it outright (taught by the Act II save). The speed-gradient is taught safely pre-choice: near the passage mouth in Act III, its rattle audibly and visibly tracks the player's own movement speed — slow = quiet, fast = frenzy — learned before anything depends on it. It is not evil; it is the reason the light matters.

### 5. Discovery Design
- **The care bootstrap is mandatory-path** (Papers, Please law: one prior positive contact + one stated stake): in Act I the light finds the player at the first junction where progress needs it — unmissable. In Act II it saves them — also unmissable.
- **Foreknowledge law (Mouthwashing adapted):** the true cost of BOTH paths is discoverable in the room before choosing: beside the socket, **one dried husk** of a light spent by someone before; by the dark passage mouth, a long-dead lantern and shallow scratch-marks in the floor's dust. The room states its prices without a word.
- **Its willingness is observable:** carried near the socket, the light drifts toward it. It was made for this. That discovery is the encounter's cruelest sentence and it arrives purely through behavior.

### 6. The Five Acts (progressively shorter)
- **Act I — Arrival:** dark rooms; the light finds the player; its hum vocabulary learned (brighter when close, a soft call answered — far off — by another of its kind, across the dark). ~3 min.
- **Act II — Discovery:** the save — something moves in the dark, the light flares, the rattle stops dead. Dependence is now bodily. Then the exit room: a massive door, a socket carved in the exact curl of a resting light, and the dark passage yawning beside it. The true threat understood. ~3 min.
- **Act III — Escalation:** foreknowledge gathering — the husk (taking's full price); **the dead lantern beside the passage now visibly half-drained, and a prior crosser's wall-mark on the far mouth drawn in weak, guttering strokes** (the dark's full price — the dimming is foreknown, not sprung); the shape audibly and visibly circling (rattle + dust-tremor tracking the player's speed); the light drifting toward the socket when carried close — **drift is range-limited, visible, and fully reversible: it strains, it hovers at the rim in a clear last-chance posture, and stepping back withdraws it at zero cost** — and carried toward the passage mouth instead, **it gutters and dims within steps** (observable foreknowledge: it cannot function in there; the Act II save visibly cost it a flicker — freezing drains it — so its limit is taught, not fiat). The player now knows everything. Nothing remains but the question. ~2 min.
- **Act IV — Climax:** the choice executes, **each with an explicit deliberate commit (panel contract):** **(a) Spend it:** commit fires only on a *held place-action at the socket itself* — proximity alone never commits. It settles, hums slower... stops, **its glow guttering in exact sync with the hum** (the climax's visual channel is stated, not implied). The door grinds open. The world does not react at all. **(b) Cross the dark:** a slow-walk ordeal between the shape's exhales — **exhale windows rendered visibly as dust and breath-fog stirring down the passage in cadence; the rattle-warning's visual twin is the companion light at the mouth pulsing exactly as it flared in the Act II save** (flare = danger, already the learned grammar). The light stays behind because it must — its guttering limit was taught in Act III. **Commit fires at crossing completion, the same frame the mark lands:** pre-completion retreat or death leaves the choice open, the light waiting at the mouth. The mark itself is **categorical, mobile-proof: the player's light RADIUS shrinks by one visible hard step for the rest of the run** (never a vignette gradient — bright-screen law), with a suite-level constraint: every load-bearing tell in every encounter renders inside the guaranteed remaining field. ~1–2 min.
- **Act V — Resolution (routed aftermath):** the exit corridor passes the consequence at walking pace, no timer, no threat: past the socket — the husk, the silence — or overlooking the passage — behind them, two hums still answering each other in the dark. One room later, the far call sounds once — **and its visual twin renders for muted players: across a dark gap, a distant second glow either rises in answer, or searches and dims, unanswered.** ~30 sec.

### 7. Choice Points (2 primary + the return — each viable, each costly)
1. **Spend the light** — exit whole; carry the silence. Its call is never answered again anywhere in the run.
2. **Cross the dark** — keep it alive and lose part of yourself: the permanent dimming, plus the crossing's real danger (see Failure).
3. **The return (post-choice, restitution without absolution):** the room stays re-enterable. Crossed the dark? You may come back and sit with it — it hums at you; it no longer follows (you are too dim to protect it now). Spent it? The husk is all there is: some things do not take returns. The world updates; the mark stays; there is no mechanical reward either way.

### 8. Information Map (Trust)
Light = safety and freezes the shape (taught by the save, never violated) · shape = fast-motion-and-noise hunter; slow and quiet is beneath its notice (speed-gradient taught at the mouth, Act III) · exhale rhythm = the crossing's timing — **two-channel: exhale sound + dust/breath-fog stirring in cadence** · rattle-rise warning = **two-channel: sound + the mouth-light pulsing in the learned flare grammar** · socket fit = visible foreknowledge · husk = taking's full price · half-drained lantern + guttering wall-mark = the dark's full price including the dimming · its drift = its willingness — range-limited, reversible, never a commit · **commit contract: (a) held place-action at the socket; (b) crossing completion** — nothing commits by proximity or accident · carry-through = visibly non-functional (it gutters dark within steps of the mouth — taught limit, not hidden wall) · **pricing honesty (panel fix — the doc claims what it builds):** rewards are zero for both paths; **costs are asymmetric in currency — capability vs. companion — and symmetric in permanence: every consequence lasts exactly the rest of this descent, and the RECORD of which story you told persists forever** (DataStore); on a fresh descent both costs reset, but that story stays told. **Functional equalizer:** the living light's far call remains a real information beacon — in one later room its distant answer warns of a motion-hunter's presence; spenders keep full vision but lose that warning forever. Neither path is developer-approved; if a player can identify one, this encounter has failed.

### 9. Failure Design
Only the dark crossing can kill: **running** (or sustained noise) in the passage — the rattle spikes first (telegraphed), then it takes you. Blackout, no gore; reset to the exit room. Fast, fair, self-attributable ("it told me — I ran"). Crucially: **the choice state persists through death** — the server committed it the instant the light left your hands. Failure never reopens the decision; it only re-teaches the walk.

### 10. Sound Design (no music — hum ruled diegetic SFX)
The encounter's instrument is the **call-and-answer pair**: near hum and far reply, mid-band (~500Hz–1kHz), mono-safe. The drain is expressed as **rhythm slowing + volume fading** (never pitch-only — phone-speaker law). The shape: dry rattle + slow exhales, loudness-coded. The door: stone-slow grind. The aftermath is a soundscape fact: the answering call, present or forever unanswered — SOMA's audible-victim device under our no-music rule. And the loudest moment is authored silence: the beat after the hum stops, when nothing in the world acknowledges it.

### 11. The Space
The socket room is the one warm-lit room in a dark encounter — and the warmth is the horror: the socket is *carved to fit*, polished by use. This room was built to spend these. It is routine. The Threshold's indifference made architectural.

### 12. Mobile Sanity Notes
Warm-vs-dark = maximum mobile contrast ✓ · hold-to-carry maps to touch ✓ · the crossing is slow-walk with generous exhale windows — zero reflexes ✓ · hum/rattle mid-band mono ✓ · consequence-by-absence renders on any device at zero cost ✓ · full arc inside one 8–12 min sitting; DataStore carries the mark to the next visit ✓.

### 13. The Cut List
**Cut:** many husks (ONE — scarier, and 9+ appropriate; a pile is grim decoration) · the creature struggling or crying during the drain (cruelty is not weight; willingness is the design) · any morality meter, ending rank, or reward differential · showing the shape (heard, never seen) · a third mid-drain "take it back" path (mechanically murky, dilutes both real choices — the return loop carries that emotion honestly instead) · any text naming the choice ("SACRIFICE?" prompts kill it dead; the socket's shape is the prompt).

---

## GATE B — run before heads review

- [x] Five acts, progressively shorter · one-sentence climax · one core question
- [x] Teaches exactly one thing · discovery organic · all info available (foreknowledge law) · 2 valid approaches + return loop · "what if" is the design itself
- [x] Replay-worthy (the other path haunts; cross-session persistence) · tellable ("I took it / I couldn't") · permanent shift · failure teaches without reopening the choice
- [x] Climax fast · consistent · zero mechanical mastery · respects time
- [x] Warden diff vs RULES.md 1–17: clean · Eight properties: present

### Self-flagged defects (Rule 11) + Gate B panel results (2026-07-07, see GATE-B-PANEL.md)
| # | Source | Defect | Status |
|---|---------|--------|--------|
| 1 | QA (self) | Never-bonds player: weightless encounter? | MITIGATED — bootstrap + save mandatory-path; playtest to confirm |
| 2 | Eddy (self) | Two primary approaches, not three | ACCEPTED BY DESIGN — Constitution allows 2–3; flagged for head review |
| 3 | 9-year-old (self) | Dimming attribution | FIXED — mark lands the same frame as commit (crossing completion), and it is foreknown in-room (§5-§6) |
| 4 | Streamer (self) | Choice (a) mechanically flat on stream | MITIGATED — drain duration + synced glow/hum carry the drama; tuning |
| 5 | Panel CRITICAL | Settle-on-proximity could execute the climactic choice UNCHOSEN | FIXED — drift reversible with last-chance posture; commit only on held place-action / crossing completion (§6, §8) |
| 6 | Panel CRITICAL | Dark crossing's entire survival ruleset was audio-only — muted player death | FIXED — dust/breath-fog cadence + mouth-light flare grammar + speed-keyed tremor (§6, §8) |
| 7 | Panel MAJOR | Light-stays-behind was untaught fiat blocking the cleverest legal plan | FIXED — guttering limit taught in Act III; Act II save visibly costs it (§5-§6) |
| 8 | Panel MAJOR | Path (b)'s true price (dimming) not foreknown; husk stated (a)'s price only | FIXED — half-drained lantern + weak-stroke wall-mark (§6 Act III) |
| 9 | Panel MAJOR | "Zero differential / SOMA symmetry" claim was false as designed (Papers-Please asymmetry) | FIXED — pricing restated honestly (asymmetric currency, symmetric permanence) + functional equalizer: the far call as a real later-room beacon (§8) |
| 10 | Panel MAJOR | Persistence asymmetry across sessions (one cost expired, one didn't) | FIXED — all costs last exactly the descent; the record persists forever (§8) |
| 11 | Panel MAJOR | Vignette dimming crushed on bright mobile screens; suite-wide readability risk | FIXED — categorical hard-step radius cost + suite-level constraint: all load-bearing tells render inside the remaining field (§6) |
| 12 | Panel MAJOR | Post-death lock contradiction; muted players missed the Act V payoff; lesson was two teachings | FIXED — commit at completion resolves the lock; distant-glow answer twin (§6 Act V); lesson compressed to permission (§2) |
| 13 | Panel (open) | Drain duration, radius step size, exhale windows = tuning; creature look/motion = asset risk | OPEN — playtest + art items |

### Honest %
**Design doc ~78%** — gaps to 100: tuning numbers; companion look/motion/behavior design (the doc's biggest asset dependency); no blockout; target-utterance playtest not run; head evaluation pending.

---

*Sources: [craft-moral-collapse.md](../research/craft-moral-collapse.md) (16 findings incl. the SOMA template, the care bootstrap, and One Chance's permanence), [archive-horror-castle.md](../research/archive-horror-castle.md) findings 6, 16 (verification-has-a-cost as moral seed; visible mistake ledger), [teardown-front-page-2026-07.md](../research/teardown-front-page-2026-07.md) (solo psychological demand-proof with no modern flagship).*
