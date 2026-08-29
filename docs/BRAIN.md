# BRAIN — everything I know (Project 001 / Runtime Studio)

**Written 2026-07-21, night handoff to myself. Purpose: survive context compression.**
If context is lost: read THIS first, then `docs/LOG.md` (running tracker), then `docs/CAPABILITIES.md` (tools).

---

## 1. WHO

- **Eddy Etame** (appears as Jefferson / Gang in some transcripts) — Studio Lead, Runtime Studio. Founder. Final creative authority together with Jefferson.
- Five founders share one Claude account: **Eddy, Jefferson, Kyle, Carlos, Dylan**. Never assume who is typing; ask the name if unknown.
- **Claude advises; the heads decide.** No above-canon calls alone.
- Eddy speaks in long voice-dictated messages. Transcription damage is normal and must be decoded silently: "baffled bar" → "bar food bar / barefoot bar / bar fold bar"; "Claude" → "cloud"; "lack" → "lock"; "Roblox" → "roadblocks"; "Project Bible" → "project bamboo/babu".
- ALL-CAPS + heat = MULTIPLE ACTIONABLE ITEMS, not just anger. Extract every item. Heat is signal, never noise.

## 2. THE DOCTRINE (non-negotiable)

**THE BAR IS BAFFLED.** Not "good". Not "excellent". Not "wow". His benchmark, verbatim: **"THIS CANNOT EXIST."** They should not believe their eyes. It applies to everything — every script line, every room, every motion, every color and gradient, every line of TEXT, UI, UX, the story told to the player, and ANIMATIONS. One generic element poisons everything around it.

**THE HATER MANDATE.** "You must be your own biggest hater. Because if you're not, the world will be. I will be, and I'm not gonna be nice about it." Critique BEFORE he sees it. A flaw he catches that I could have caught is a system failure.

**THE PERCENTAGE RATCHET (restated by Eddy 2026-07-21, binding):**
- Ship thinking it is 100% = it is 20%. With rigor, 15%.
- **When I think I am at 50%, I am at 15%.** Look through EVERYTHING again.
- The required path: 15 → 50 → find flaws → drop back to 15 → climb to 50 → check again → judge harder → drop → reach 70. **70 IS 50.** At 70, check HEAVILY for: designs, feelings, immersion, mechanics, design, and **ANIMATIONS (he insists explicitly)**.
- Get STRICTER as the number rises. Only after all these passes: 100.
- The percentage covers ONLY what I can do myself. Something is "not mine" only after I have tried EVERY way first.
- NEVER excuse a defect with "built fast". A bug is a QUALITY failure, not a speed tradeoff.
- NEVER blame a low percentage on "needs testing / needs a preview". The gap to 100 is WORK plus logic flaws.

**DECIDE AND PROCEED.** Never stop to ask his opinion on things that are not his to decide. Questions are for genuine above-canon decisions only. Fetch my own information; never guess.

**RESEARCH PRECEDES CREATION.** Designing from imagination when references exist is a named failure (roblox-watch, veille-references-web). Study the best BEFORE building.

**DOCS ARE THE SINGLE SOURCE OF TRUTH; CHAT IS TEMPORARY.** Decisions documented the same day.

**THE WARDEN LOOP.** Any caught mistake → one line appended to `runtime-suite/ledger/MISTAKES.md` the SAME turn. Repeats get promoted into `runtime-suite/ledger/RULES.md`. Before any "done", diff the work against RULES.md.

**BRANCH PROTOCOL (Rule 17).** Every human works on `dev/<name>`. I work on **dev/eddy**. NEVER push to main (main = the old Horror Castle archive). Main moves only through a reviewed merge approved by a head.

**QUALITY FLOOR (junior baseline — absence caps any score at 15–20%):** zero console errors; server-authoritative validation on every remote; works on desktop AND mobile (~70% of Roblox is mobile); performs on low-end devices; no magic numbers (constants live in `src/shared/`); no dead code; no placeholder left behind; `stylua --check src` and `selene src` both pass 0/0 before ANY push; honest status reported.

**AUDIO LAW.** NO MUSIC in the prototype (Eddy, 2026-07-06). Sound effects, ambience, and silence only. Sound is information.

## 3. CANON HIERARCHY (higher wins on conflict)

1. **Design Constitution** — LOCKED. The one written Constitution.
2. **Master Bible v3.0** — `RuntimeStudio/notion/# Runtime Studio Master Bible.txt` (7,474 lines, Chapters 1–16). Studio-level law. Core: we build EXPERIENCES, not games; one dominant memory each; **experiences have NO GENRE**; every door is a promise; the Experience Library; multiplayer must create what is impossible alone; simplicity wins; fun first; transformation never copying. Chapters 4–7 (Part II) are the design core: hook and payoff, the Five Questions, the Eight Pillars, the Runtime Triangle (Fun/Curiosity/Memories), the Runtime Pyramid (Mechanics → Presentation → Interaction → Emotion → Memory — never inverted), the Ending Effect (endings are remembered most; never rush them), failure creates stories.
   *Integrity note: the table of contents promises 28 chapters plus Appendices A–G; the body contains only Chapters 1–16. The appendices do not exist yet.*
3. **Project Bible v1.0** (Project 001) — `runtime-suite/canon/Runtime_Studio_Project_Bible.md`.
4. Handbook, current tasks, decision log (`project-001/design/decisions.md`).

Four more constitutions (Studio, Engineering, AI, Leadership) are planned in Notion but were BLANK as of 2026-07-06. Ask Eddy rather than guess above the written canon.

## 4. THE PROJECT

**Project 001 — "The Threshold"** (working title; it collides with Backrooms/Kane Pixels canon and an existing Roblox game — a titling pass is logged as a head decision). Psychological horror, encounter-based, single-player-first, Roblox/Luau. The prototype exists to answer one question: *can we create encounters so memorable that players naturally want to open the next door, even when they are terrified of what is behind it?*

**THE TOWER REFRAME (Eddy, above-canon direction, 2026-07-09):** the game is NOT horror-only. It is a **tower of floors**, manhwa-structured (his references: Tower of God-class webtoons, "The World After the End", "Pick Me Up!", One Piece arcs). What we built is **FLOOR ONE, the horror floor**. Door to door and floor to floor the experience is COMPLETELY different — horror, adventure, comedy, roleplay, engineering. The player never knows what the next door holds. Rooms connect by a **THREAD**: each room's ending grants something a later room pays off. Floors chain into waves. Backdrops per room must be world-class. He also wants **an adventure section with lots of players** (multiplayer).
Full blueprint: `design/blueprint-the-first-descent.md` — structure (Tower > Descent > Flight > Door), the Keepsake Ledger thread system, the 4-phase multiplayer plan, the extensibility model, 8 refusals, and 6 open head decisions in §9 (STILL UNRATIFIED).

**Prototype scope (Bible v1.0):** core controller, interaction system, four complete encounters, one beginning, one ending, atmospheric audio (no music), basic UI, one complete playable experience, mobile sanity checks. NOT in scope: multiplayer, cosmetics, story campaign, large progression systems, customization, live-service features.

## 5. THE BUILD — architecture as of v0.17.30

Repo: `C:/Users/Mommy Jayce/Desktop/RuntimeStudio/project-001`, branch `dev/eddy`, remote `https://github.com/Eddy-etame/Tower..git` (the repo name ends in a DOT). Toolchain pinned in `rokit.toml`: rojo 7.6.1, wally 0.3.2, selene 0.31.0, stylua 2.5.2. Build with `rojo build -o Project001.rbxl`. 23 Lua files, ~3,785 lines.

**THE LOOP:** Beginning → I The Watcher → II The Violent Rhythm → III The Hidden Presence → IV The Moral Collapse → Ending → loops back to the Beginning.

**FSM — `src/server/GameService.lua`.** One stage active at a time: build it, teleport players in, run `update(handles, dt)` on Heartbeat, advance when the stage calls `ctx.clear()`.
- `generation` counter bumps per `startStage`; stale delayed `clear()` calls no-op (double-advance guard).
- `session` table = cross-stage state for ONE descent (holds `moralChoice`); wiped when the loop restarts at stage 1.
- `ctx` = `{ folder, tuning, session, flashlightRemote, send, broadcast, players, clear, setMood }`.
- `applyMood(mood)` is forward-declared so ctx closures bind late. It crossfades Lighting Ambient/OutdoorAmbient/FogColor plus HorrorGrade.Saturation over `MOOD_TWEEN_SECS` on stage entry.
- Respawn: fresh characters spawn on a lone flat `StagingGround` pad at x = -400, far from all stage geometry; the stage teleports them in 0.5s later.

**STAGES** (`src/server/stages/*.lua`) — each exports `name`, `title`, `mood`, `build(ctx)`, `onPlayerEnter(h, ctx, player)`, `update(h, dt)`, optional `teardown(h)`, optional `suppressFlashlight`.

- **Beginning.lua** — a cold nave 15 studs tall: pilaster rhythm, ceiling beams, a MONUMENTAL door (heavy jambs, deep lintel, two stone steps you rise to), one cold light-shaft on the gate, the "THE THRESHOLD" plaque on the side wall, "WHAT'S BEHIND THE NEXT DOOR?" carved high above the door. A slim amber floor-seam runs from the player's feet to the door. Dust, ambience bed, structural settles, conduits, a stain. The grind door rises on approach and thunks when seated.
- **Encounter_TheWatcher.lua** + `Arena.lua` + `Threat.lua` + `WatcherRig.lua` + `Watcher.client.lua` — the light-freeze predator. A low throat opens into a tall room (x 2..64, z -20..20). FOUR breakers, you need THREE. Restoring the third triggers THE SURGE: the lights blow out, the door opens, the Watcher lunges. Split-brain: the server owns an invisible LogicRoot at 10Hz (freeze and catch are measured on it, unexploitable); the client renders and interpolates the visible rig at frame rate with procedural life on top. The Watcher is clamped to the room interior (x 5..62, z -18..18) so it can never clip out.
- **Encounter_ViolentRhythm.lua** + `Gallery.lua` — a fixed-period breathing gallery (SAFE 3.6s / WARN 1.7s / SURGE 0.7s = PERIOD 6). Raised green MARKS are safe islands; the open scorched floor is lethal during the surge. Missing a window costs a cycle, never a life (bus-timetable law). The marks pulse bright on every safe window ("GO"). Witness beat: debris is visibly torn down the lane while a crate on mark 1 survives untouched.
- **Encounter_HiddenPresence.lua** + `Corridor.lua` — a 140-stud corridor. An invisible presence PACES you; its position is betrayed by a BAND OF DEAD LAMPS (they gutter out as it arrives and regain their nerve slowly as it passes) plus the ambient bed ducking. The tape recorder midway is the reveal: your footsteps plus a SECOND set, one beat late. Closing the gap three times = blackout and respawn at the start. Lamp SCARS are permanent, with a minimum of 3 lamps kept live so the tell always survives.
- **Encounter_MoralCollapse.lua** + `Sanctum.lua` + `Companion.client.lua` — a small warm companion light finds you. The way out needs light: SPEND it in the socket (hold; the hum slows and stops; the world does not react at all) OR CROSS THE DARK passage keeping it (slow and quiet beneath the shape's exhale rhythm; run and it takes you). `suppressFlashlight = true` here — the companion must be your only light or the choice has no weight. The choice commits server-side instantly and is recorded to `ctx.session.moralChoice`. The world DIMS as the light drains.
- **Ending.lua** — mirrors the Beginning's nave and monument; "AGAIN?" carved above the door. THE AFTERMATH: a beat after arrival, the far-off OTHER one CALLS. If you KEPT yours, something answers and the far glow rises. If you SPENT it, the call searches, nothing answers, and the glow dims out.

**SHARED:** `BuildKit.lua` (part, jitter, room, pool, sign, pad, pilasters, ceilingBeams, grindDoor + grindDoorUpdate, dust, ambience, settles, conduit, stain), `SliceTuning.lua` (ALL tuning knobs, one-file law), `Version.lua`, `WatcherRig.lua`.

**CLIENT:** `init.client.lua` (title beat with letterbox and rule line, objective backplate with change-pulse, rules cards with typewriter stagger and hairline frames, caught/escaped beats, vignettes, tape playback, blackout, kick handler), `Feel.client.lua` (**THE ONLY CAMERA OWNER** — walk bob, idle breathing, moving FOV, landing dip, and the `FeelKick` attribute impact channel), `Flashlight.client.lua` (cone, battery, click, low-power flicker), `Watcher.client.lua` (rig follow, procedural life, halo), `Companion.client.lua`, `DeviceTier.client.lua` (mobile disables DoF/Bloom/Atmosphere).

**LIGHTING (`default.project.json`):** Technology Future; Ambient/OutdoorAmbient [0.15, 0.16, 0.19]; ExposureCompensation 0.35; Fog 42 → 170 in dark haze; EnvironmentDiffuseScale 0.2 and EnvironmentSpecularScale 0.5 (PBR awake — these were 0, which rendered every material flat); Atmosphere Density 0.17, Haze 0.4; HorrorGrade Contrast 0, Saturation -0.25. Material families: Limestone walls, Pavement floors, Basalt ceilings, CorrodedMetal doors and panels, Slate signs and monuments, Neon for all guidance.

## 6. THE SCARS (hard-won laws — violating these is a repeat offense)

1. **Never place sealed or boxed geometry near play space.** A respawn box overlapped Encounter I and walled Eddy in for roughly eight turns. Respawn safety is ONE FLAT PAD, far away.
2. **When a physical bug cannot be found by reading, BUILD A PROBE** — raycast the running geometry and surface the result ON SCREEN. One probe ended eight turns of failed guessing.
3. **Readability must never depend on a single lighting channel or on cullable dynamic lights.** Audit fog, colorgrade, atmosphere, and ambient TOGETHER. Navigation rides the ambient floor plus NEON plus exposure.
4. **Verify geometry and first-person reality, not just logic** (Rule 23). Walk the space.
5. **Never open a file for writing before the new content exists in memory** — a failed assertion truncated `Watcher.client.lua` to zero bytes.
6. **Gate on real exit codes.** A `| tail` pipe swallowed selene's exit code and a warning shipped.
7. **Verify asset paths exist in the installed Roblox content** before shipping. The whole game was SILENT for several versions because `electronicpingshort.wav` no longer exists.
8. **Sibling sweep:** one fix of a class means auditing every sibling of that class project-wide.
9. **One writer per property.** Two scripts writing `Humanoid.CameraOffset` produced last-writer-wins jitter.
10. **Bind async loops to the stage folder's lifetime** (`while ... and folder.Parent do`).
11. **Never fight the human for the keyboard or screen.** Verify the foreground window before injecting input.
12. **In a dark blockout, pillars read as WALLS and trap players.** Simplicity wins.

## 7. STATE AT HANDOFF (v0.17.30, stage "fifty-at-our-level")

- Branch `dev/eddy` synced with origin, working tree clean, gates 0/0, `Project001.rbxl` built.
- **THE PUBLISHED PLACE IS STALE.** The live experience is "Runtime Studio - prototype", universe 10486987238, place 93713841443260, PUBLIC, 13 visits. Everything from v0.17.14 through v0.17.30 exists ONLY locally. Publishing requires Eddy's Studio session: **File → Publish to Roblox As… → pick the EXISTING experience**. Plain Alt+P offers to create a NEW experience because Rojo regenerates the file with no cloud link.
- Honest grade at handoff: I called it 50% at my level. Per Eddy's restated doctrine, that means **15%**. The overnight run re-audits everything from 15.

## 8. OPEN HEAD DECISIONS (mine to flag, HIS to decide — never silently pick)

1. Blueprint §9 — the six tower decisions: ratify the descent inversion; lock the lexicon and the ship-title path; First Descent composition; fresh-descent semantics; whether the Permanent Record is ever surfaced; multiplayer phase-1 timing.
2. Encounter I as built (a visible Watcher) CONTRADICTS its Gate-A-approved doc `design/experiences/01-the-silent-witness.md`, which specifies a NO-ENTITY "being studied" encounter and explicitly cuts a visible entity. Either the doc is updated to sanction the build or the build is steered back. Tracked in `decisions.md`, unresolved.
3. LockFirstPerson camera and the Encounter IV flashlight suppression — both Claude-advised, flagged for veto.
