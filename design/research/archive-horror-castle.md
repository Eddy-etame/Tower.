# Horror Castle archive harvest — Runtime Studio's dead co-op horror concept (local docs: concept, v1-spec, ui-flow, decisions, figma-prompt, team-plan, README, plus rooms/echo-hall.md and monsters/the-choir.md)

> T5 research dossier - archive:HorrorCastle - generated 2026-07-06. Every finding: mechanism -> causal chain -> verdict -> Threshold translation -> where it lands -> source.

## Summary

Horror Castle was VYRE Studios' 4-player match-based co-op horror tower that died at kickoff — fully planned, every role owner "TBD", zero code committed — but its craft layer is dense and directly harvestable. Its centerpiece, the Echo Hall / Choir design, is a complete deception stack (counterfeit sigils, fake teammate NPCs, engineered false audio, a punishment FSM) whose fear engine is already Threshold-native: uncertainty about what is real. The single biggest lesson for Project 001: deception is only fair when every counterfeit carries consistent, learnable tells (85% speed, 0.5s pause cadence, ~100ms footstep desync, off-pitch hum) — that converts "the world lies" into "the world has a rule you haven't read yet," which is the only form of deception our trust law permits. Second lesson: dread lives in Pre-Hunt, the telegraphed window before the monster exists, and the entity literally not existing between events is both anti-exploit engineering and the horror thesis itself. We adapt the mechanisms into single-player language (the player's double, exposure scoring, observation-as-verb), and we refuse its musical telegraphs and its hidden mid-crisis rules.

## Findings

### 1. [ADAPT] The Hidden Presence (doubt -> dread -> revelation), Act II Discovery through Act III Escalation; server-side authenticity assignment system

- **Mechanism:** Counterfeit sigil system: 5 spawn points, 3 real / 2 fake assigned server-side each round; real sigils carry a warm glow plus an in-tune proximity hum, fakes are visually near-identical but hum slightly off-pitch; collecting a fake shatters it with a dissonant chord and triggers the Hunt punishment.
- **Causal chain:** Objective authenticity becomes ambiguous -> player must slow down, lean in, and listen before committing to any interaction -> every pickup becomes a wager, producing dread at the exact moment of choice rather than after it.
- **Threshold translation:** In The Threshold, counterfeits exist because the place reproduces things imperfectly — indifferent copying, not malice. Keep the deception but harden the fairness law: every counterfeit carries at least TWO independent tells on different senses (one visual-in-absence, one audio), because a pitch-only tell does not exist on a phone speaker. Deception becomes a learnable rule the world never lies about; players lose only to unread information, never unavailable information. Core question: 'do I trust this?'
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 4.1)

### 2. [ADAPT] The Silent Witness (paranoia/violation), Act III Escalation; also seeds The Hidden Presence

- **Mechanism:** Fake teammate NPCs with four fixed pathing tells: move at 85% of player speed, pause 0.5s every 4-6s in spots real players would not pause, footstep audio desynced ~100ms from the step animation, and never complete an objective (approach a sigil, stand near it, drift away). Following one for >12s triggers the Hunt.
- **Causal chain:** A familiar figure behaves 5% wrong -> the player starts studying movement instead of trusting identity -> uncanny paranoia; trusting the fake leads you into isolation where the Hunt targets you, teaching 'observation is survival' through consequence.
- **Threshold translation:** Single-player has no teammates, so the Threshold clones the PLAYER: a figure wearing your avatar walks your earlier route with the same tell family — slightly slow, wrong pauses, delayed footsteps, never finishing what you finished. Being studied and imperfectly reproduced is The Silent Witness's violation made flesh. One mobile correction: the 100ms desync tell is imperceptible on low-end devices, so tells must live at cadence scale (the 0.5s pause survives; the 100ms desync does not).
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 4.2)

### 3. [ADAPT] The Silent Witness (being recorded and studied); ambient audio system, Acts I-II

- **Mechanism:** Engineered false audio events with a locked mix ratio: FakeAudioSystem emits decoy footsteps and pre-recorded voice lines ('I found one', 'Over here') from unattended positions every 8-15s; explicit tuning rule that ~60% of audio events are fake and 40% are real teammate audio amplified through the same system; fake lines never carry player-controllable text.
- **Causal chain:** Sound stops guaranteeing presence -> the player must cross-verify hearing against sight -> every distant sound becomes a question, generating ambient paranoia with no monster on screen and zero assets spent.
- **Threshold translation:** Counterfeit the player's own evidence instead of teammates: your footsteps replayed seconds late from a room you already left, a door you opened closing again elsewhere. This honors 'sound is information' — the information the false sound carries is a TRUE fact: this place records and replays you. Keep the fake:real mix ratio as a first-class tunable. Refuse the voice lines outright (no other humans in the Threshold, and chat-style decoys read as the game itself lying).
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 4.3) and C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\monsters\the-choir.md (section 3.1)

### 4. [ADAPT] The Violent Rhythm (panic -> understanding -> control); five-act mapping: Pre-Hunt = Escalation, Hunting/Catching = Climax, Dissipating = Resolution; monster FSM system

- **Mechanism:** Hunt-phase FSM where dread lives in Pre-Hunt: Dormant -> Pre-Hunt (1.5s: lights flicker, heartbeat one-shot, chord swell, monster NOT yet visible) -> Hunting (lights cut, spawn at center, glide at 110% sprint toward most-isolated player) -> Catching (4-stud lunge, death, 0.5s freeze) -> Dissipating (1.5s dissolve) -> Dormant. The Choir model exists in the workspace ONLY during Hunting and Catching.
- **Causal chain:** A telegraphed window before the threat exists -> the player experiences known-consequence, unknown-target anticipation -> dread peaks BEFORE the monster appears; the chase itself is resolution, not the scare. The entity's literal nonexistence between events means searching for it finds nothing — absence implemented as architecture.
- **Threshold translation:** Keep the state grammar, invert the proportions: co-op compressed Pre-Hunt to 1.5s for pacing, but single-player Threshold makes Pre-Hunt the LONGEST state (30-90s of accumulating environmental wrongness) with the active phase brief and legible. Replace the heartbeat and choral swell (musical scare grammar — banned by the audio directive) with world-information telegraphs: ventilation stops, room tone drops, light cadence changes. Adopt 'the entity does not exist between events' as literal design law.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\monsters\the-choir.md (sections 4-5)

### 5. [ADAPT] The Violent Rhythm and The Hidden Presence escalation logic; a reusable server ExposureTracker system for every encounter

- **Mechanism:** Server-side isolation scoring as the targeting rule: IsolationTracker continuously computes each player's distance-to-nearest-teammate; the Hunt always targets the highest scorer (ties random); being >15 studs from any teammate for >25s is itself a Hunt trigger. All thresholds are named constants.
- **Causal chain:** A legible targeting rule keyed to player-controllable behavior -> players learn 'aloneness is the danger variable' and change positioning -> panic converts to understanding converts to control — the exact Violent Rhythm arc, produced by a targeting function.
- **Threshold translation:** No teammates, so redefine the score as EXPOSURE: server tracks time since the player last anchored to understood space — light, mapped rooms, deliberate observation acts (stopping to look and listen). The entity's attention keys to exposure, so reckless venturing raises risk and deliberate observation lowers it: survival literally equals observation + adaptation, no reflexes. The rule must be discoverable in-world through the entity's behavior, never shown as a meter.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\monsters\the-choir.md (section 4, targeting pseudocode) and echo-hall.md (section 10 tuning table)

### 6. [ADAPT] The Moral Collapse (guilt -> helplessness -> moral weight), Act IV Climax

- **Mechanism:** Verification has a cost: fake teammates can be destroyed by holding E for 2s, but doing so makes the room 'scream' and triggers a Hunt — testing the deception is itself punished, so certainty is never free.
- **Causal chain:** The player can resolve doubt only by paying risk -> doubt lingers because certainty is expensive -> sustained ambiguity; and destroying something that looked human leaves emotional residue regardless of what it was.
- **Threshold translation:** This is a Moral Collapse seed in single-player: a figure that might be another survivor. You can act against it to be sure — and the act has consequences whether it was real or not, because the Threshold is indifferent to your guilt. One core question: 'what did I just destroy?' Keep the trust law: interacting with counterfeits ALWAYS provokes, the consequence is never randomized, and the provocation is telegraphed the first time it happens.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 4.2, death-of-a-fake)

### 7. [ADOPT] All four archetypes, Act III Escalation; lighting and ambience server system

- **Mechanism:** Escalating environmental telegraph: wall sconces flicker for 1-2s every 8-15s as baseline, and flicker FREQUENCY increases as Hunt triggers approach — the lighting system is the warning system, driven by server room state.
- **Causal chain:** An ambient environmental rhythm carries threat state -> attentive players read the room's pulse without any HUD element -> tension scales smoothly, and information-rich players feel earned control instead of ambushed.
- **Threshold translation:** Directly Threshold-native: the world's indifferent systems (lights, air handling, machinery hum) change cadence as an encounter escalates — 'all survival information exists somewhere' implemented as environmental rhythm. Pair with silence-as-signal: the cadence STOPPING is the loudest telegraph available under the no-music directive.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (sections 3 and 7)

### 8. [ADAPT] Climax beats (Act IV) of The Violent Rhythm and The Hidden Presence; audio system

- **Mechanism:** Catch equals silence, not scream: the Choir's kill audio is a sudden cluster chord then a hard cut to total silence — the spec explicitly states 'no scream — silence is more effective' — followed by a false-relief resolution before ambience returns.
- **Causal chain:** The climax lands as an absence of sound -> the player's brain fills the void -> the scariest frame is authored by the player's own imagination rather than an asset, and it costs nothing to render on any device.
- **Threshold translation:** Adopt silence-as-climax wholesale; strip both chords (musical — banned). The Threshold's version: ALL ambient information stops at once, which on a phone speaker reads more violently than any loud sound. Keep the false-relief BEAT but express it as ambience returning slightly wrong (the hum restarts at a different pitch, the lights come back in a different order) — relief the player cannot fully trust.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\monsters\the-choir.md (sections 3.3-3.4)

### 9. [ADAPT] Art direction and UI for all encounters; studio-os / canon governance

- **Mechanism:** Direction G restraint with a built-in drift test: exactly 3 colors (pure black #000000, pure white #FFFFFF, single crimson #B91C1C), 2 fonts, zero ornamentation, one signature mark (2px crimson underline), and a written one-line failure detector: 'If a 4th color appears, the direction has drifted.'
- **Causal chain:** Near-monochrome starves the eye -> the single accent becomes a learned danger/meaning signal -> any appearance of the accent triggers an attention spike before cognition; restraint makes one color do the work of an entire VFX budget.
- **Threshold translation:** Extract the RESTRAINT BUDGET, not the palette: The Threshold defines its own near-monochrome world with ONE reserved accent that only ever means one thing, so its appearance lands in the stomach before the brain. Separately, adopt the drift-test sentence as canon governance: every locked direction in Project 001 ships with its own one-line failure detector, so 'has this drifted?' is a check anyone can run, not a debate.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\figma-prompt.md (section 2) and C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\decisions.md (2026-05-04 pivot entry)

### 10. [ADOPT] The Threshold's spatial language; Act I Arrival and Act II Discovery; The Hidden Presence

- **Mechanism:** Repetition architecture plus wrong reflections: every hallway deliberately identical (same architecture, length, textures, sconce placement) with only two landmarks (center crimson light, exit door); thin floor haze makes distant figures ambiguous; optional mirrors show fake reflections of teammates.
- **Causal chain:** The environment denies landmark memory -> disorientation makes the player doubt their own navigation -> self-doubt primes them to accept impossible things as their fault rather than the world's, deepening immersion in wrongness.
- **Threshold translation:** This is Threshold DNA that Horror Castle stumbled into: rooms that repeat, architecture without care for the visitor. Adopt directly — identical spaces with a single anchor, and push the mirror idea to single-player: a reflection that runs a half-second late, or shows you standing in a hallway you have not entered yet. The architecture is indifferent: it was not built to confuse you, it simply does not care that it does.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 3)

### 11. [ADOPT] HUD/UX system across all archetypes and screens

- **Mechanism:** Feel-don't-read danger channel: explicit UI law 'never show a monster distance meter — feel, don't read'; threat conveyed by a screen-edge vignette scaled to proximity plus escalating world cues, with the HUD spec framing horror as 'what the HUD is failing to fully describe.'
- **Causal chain:** Threat data delivered as sensation instead of numbers -> the player stays in the world instead of in the interface -> fear remains embodied; a meter would convert dread into resource management.
- **Threshold translation:** Adopt as a written HUD law for Project 001 and push one step further: prefer fully diegetic signals (world light, sound cadence, the entity's own behavior) with a minimal edge-vignette retained only as an accessibility fallback for the mobile player in a bright room with a muted phone — that player still deserves the information, per the trust law.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\ui-flow.md (sections 3.8 and 3.10)

### 12. [ADAPT] Core interaction verb across all encounters; The Silent Witness and The Hidden Presence

- **Mechanism:** The Watcher's REVEAL as deception counterplay: a scarce role ability (2 uses, 15-stud radius, 4s duration) that identifies real-vs-fake sigils and tints fake teammates — co-op's answer to the deception stack is rationed certainty held by one crew member.
- **Causal chain:** Certainty is a scarce consumable -> the crew coordinates around doubt instead of eliminating it -> tension is preserved even though a counter exists, because the counter is expensive and localized.
- **Threshold translation:** No roles in single-player, so convert the ability into a universal VERB with a time-cost instead of a use-count: sustained deliberate observation — standing still and watching a figure or object for several seconds — makes counterfeit tells legible, because fakes cannot hold the performance under direct attention. Certainty costs stillness while exposed (ties into the ExposureTracker). Survival = observation becomes mechanically literal, with zero reflex requirement.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (sections 4.1, 5, 11) and C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\concept.md (section 8)

### 13. [ADOPT] encounter-design process and playtest protocol for all four archetypes

- **Mechanism:** Single-sentence playtest criterion: the monster spec locks a success test — the encounter 'is not yet tuned correctly' until a playtest produces the exact unprompted utterance 'bro which one is real??' at least once per round — and even describes the composite moment to watch for (one player following a clone while another doubts it and a fake voice line plays in a third direction).
- **Causal chain:** Designing to a target player sentence -> tuning gets an observable, binary finish line -> the encounter converges on ONE emotion instead of diffusing across many, and 'done' stops being a matter of opinion.
- **Threshold translation:** Adopt as encounter-design QA for Project 001: every encounter's ONE core question gets a companion target utterance (Silent Witness: 'it's been watching me this whole time?'; Violent Rhythm: 'wait — I know when it comes now'; Hidden Presence: 'it was HERE?'; Moral Collapse: silence, then 'did I have to do that?'). A playtest passes only when the sentence — or its emotional equivalent — occurs unprompted.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\monsters\the-choir.md (section 8)

### 14. [ADOPT] luau-architect / server systems; every encounter's implementation

- **Mechanism:** One-file tuning constants: all 12 balance knobs for the room live in a single shared module (EchoHallTuning.lua — FAKE_NPC_SPEED_MULT 0.85, FAKE_NPC_PAUSE_INTERVAL 5, HUNT_CHASE_SPEED_MULT 1.10, ISOLATION_TRIGGER_SECONDS 25, etc.), so balance changes are one-file edits; same pattern mandated for role numbers (RoleTuning.lua).
- **Causal chain:** Centralized named knobs -> playtest-to-retune iteration takes minutes not days -> the knife-edge subtlety that fair deception requires (tells learnable but not obvious) can actually be reached through iteration.
- **Threshold translation:** Adopt directly into Project 001's Luau architecture: every encounter ships an EncounterTuning module from day one. Uncertainty-based horror lives or dies on tuning speed — the difference between 'unfair' and 'unforgettable' is often one constant, and it must never require a code archaeology session to change.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 10) and C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\v1-spec.md (section 14)

### 15. [REFUSE] Refused device — recorded as a trust-law counterexample for encounter-design

- **Mechanism:** Anti-camping depletion: during a Hunt, a targeted player can be saved by reaching a teammate only twice; after that they are 'committed to outrunning until the timer ends' — a hidden rule change mid-crisis that converts survival into a footrace against a monster moving at 110% sprint speed.
- **Causal chain:** A safety rule silently expires at the moment of highest panic -> the player who learned 'reach a teammate to survive' dies to a rule the world never taught -> the death reads as betrayal, not lesson; and outrunning-at-speed makes reflexes the survival check.
- **Threshold translation:** Refused on two counts of studio law: it is a hidden mid-crisis rule change (trust violation — once a player learns a rule, the world never lies about it) and it makes survival a matter of movement speed (mechanical mastery, banned). If escape options must deplete in The Threshold, the depletion is SHOWN — the world visibly changes state each time an option is spent, before the player needs it again.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 4.4, anti-camping rule)

### 16. [ADAPT] The Moral Collapse and encounter-wide escalation logic, Act III-IV; world-state persistence system

- **Mechanism:** Failure-budget wipe state: 5+ Hunt triggers without objective progress flips the room into 'lights go out permanently and Choir Hunts continuously' — an invisible patience counter that ends in an unwinnable state.
- **Causal chain:** A hidden mistake counter accumulates -> the room's forgiveness silently runs out -> players experience an abrupt, unexplained difficulty cliff and lose to information that was never available: classic 'that's bullshit' territory.
- **Threshold translation:** The underlying idea — the place stops pretending after repeated mistakes — is pure Threshold indifference and worth keeping. The fix is a VISIBLE mistake ledger: each failure permanently scars the world (a light that never comes back, a room that stays wrong), so the escalation toward the final state is readable in the environment. The player watching their world lose lights one mistake at a time is dread with full information — and it doubles as Moral Collapse fuel: you did this.
- **Source:** C:\Users\Mommy Jayce\Desktop\RuntimeStudio\discord\docs\rooms\echo-hall.md (section 4.6)

## Trust breaks (their haters are our free QA)

- Staffing fiction: team-plan.md promises 'V1 in ~2 weeks if we execute' across 5 roles — and every single role owner is 'TBD'. The plan was written for a team that never existed; the project died between planning and the first commit (v1-spec Day-1 checklist fully unticked, Definition of Done fully unchecked).
- Scope vs timeline: 3 rooms, 5 server-validated roles, full UI stack, matchmaking, DataStores, and monetization in 14 days — while concept.md itself admits 2 of the 3 rooms ('The Whisper', 'The Stalker') were 'redesign pending' and had no locked design. Two-thirds of the game's content was a known blank at 'locked spec' time.
- Decision thrash burned the runway: the decision log shows visual direction locked (Direction A) then overturned within 24 hours (Direction G), role pool changed 4 -> 5, and the lobby removed then reintroduced — all on 2026-05-03/04 — after which the log goes silent forever. Re-litigating locked decisions was the last activity the project ever had.
- Even the docs disagree about project state: README.md says 'Awaiting visual-direction pick + team kickoff' while decisions.md says the direction was locked on 2026-05-04. When the index doc and the decision log contradict each other, there is no single source of truth — a direct violation of what is now Runtime Studio law.
- Concept-hopping is the documented studio failure mode: VAULT was archived for Horror Castle, Horror Castle is now archived for Project 001 — the third concept. The archive itself is the warning: plans die at kickoff when scope is a fantasy and owners are TBD.
- Design-level trust break preserved as free QA: the fake-sigil tell is pitch-only and deliberately tuned 'subtle enough that careless players still get fooled' — on phone speakers (70% of the platform) that information effectively does not exist, meaning most players would lose to unavailable information. Any Threshold tell must survive the worst speaker in the audience.
- Hidden rules that would generate 1-star 'that's bullshit' moments: the anti-camping rule (teammate-saves silently capped at 2 per Hunt) and the invisible 5-Hunt permanent-wipe counter both change or end the game based on state the player cannot see.
- The headline mechanic was never validated at its own fallback conditions: lobbies start with 2-3 players on timeout, but isolation-distance targeting degenerates with 2 players (both are always equally isolated — targeting becomes a coin flip). The core system's math breaks exactly in the game's own declared fallback mode.
- Musical scare grammar throughout the audio spec (heartbeat one-shots, choral chord swells, major/minor key shifts as danger telegraphs) — legal then, banned now under the 2026-07-06 audio directive. Cautionary: this grammar is the industry default and will try to sneak back into Project 001 through any audio reference we study.

## Mobile notes

What survives the small bright screen and phone speaker: the black/white/one-accent restraint (high contrast is the most mobile-legible art direction possible), silence-as-climax (a hard cut to nothing reads violently even on a mono phone speaker), cadence-scale behavioral tells (the fake NPC's 0.5s pauses and never-finishing-objectives are readable at any frame rate), hold-to-interact verbs (map cleanly to touch-and-hold), the edge vignette danger channel, and the 8-15 minute encounter length (fits Roblox short-session behavior). What dies: pitch-only audio tells (the off-pitch sigil hum is inaudible on a phone speaker — every tell needs a second sense), left/right spatial audio direction (mono speakers reduce it to near/far and present/absent, so design directionality out of critical information), the 100ms footstep-animation desync (imperceptible on low-end devices with unstable frame rates), and dark 3D interiors generally (near-black world scenes wash out on a bright phone in daylight — Horror Castle's own UI direction thrived on black precisely because flat UI black survives where in-world darkness does not; The Threshold should express 'dark' through wrongness and emptiness, not low luminance).

## The surprise

The purest line of horror design in the entire archive was written as security engineering: 'The Choir model only exists during Hunting and Catching states — clients can't see where the Choir is between Hunts because there IS no Choir between Hunts.' Anti-exploit necessity accidentally stated Project 001's whole thesis — the entity is not hiding from you, it does not exist until the world decides it does — proving absence can be implemented literally in the architecture, not merely staged. More broadly, the dead co-op game was already converging on The Threshold before it died: footsteps that match no one's position, identical hallways with no landmarks, a monster 'heard, not seen... felt as paranoia.' Horror Castle did not fail because its craft was wrong; it failed because nobody was on the team.
