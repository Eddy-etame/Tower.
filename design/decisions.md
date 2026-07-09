# Project 001 — Decision Log (append-only, dated; higher canon wins on conflict)

## 2026-07-09 — MVP slice built: all four encounters real + the complete loop
**State (as-built, v0.16.x on `dev/eddy`):** The full loop exists and connects — Beginning → I The Watcher → II The Violent Rhythm → III The Hidden Presence → IV The Moral Collapse → Ending → (loops). Each is a real, server-authoritative encounter on a one-file-per-stage FSM (GameService), NOT the full Stage-2 design — an MVP SLICE of each (one threat + one stated objective + one rule + the signature moment). Blockout geometry, STUB audio (one rbxasset placeholder — Audio dept records real foley), no environment art. Hardened by three adversarial-review passes (fixed the Watcher's detached-body P0, Encounter IV's three sealed-doorway P0s, and ~28 fairness/correctness bugs; ledgered, Rule 23 promoted).
**As-built vs the design docs:** the four experience docs (`design/experiences/01-04`) describe the fuller ~78% design vision; the build is the playable slice. Notable simplifications deferred to a later pass: III's "presence sits between you and the goal" routing (built as a trailing pacer + tape reveal); IV's symmetric cross-path cost "your own light dims for the rest of the run" (built as the crossing's risk only) and the full Act I/II care-bootstrap "save"; DataStore cross-session persistence (out of MVP scope per Bible ch.10). The docs remain the design intent; the code is the MVP truth — reconcile per encounter when each is render-tuned.
**Deferred (needs a render/playtest or a department):** on-device tuning of every encounter's numbers + atmosphere/feel; real audio foley; environment art; companion-orb follow-rate look-tuning.
**Approved:** build executed autonomously under the 2026-07-07 slice-first pivot + Eddy's "full speed / get to the MVP" direction; the specific implementation choices below are Claude-advised, flagged for head confirmation (Claude advises, heads decide).

## 2026-07-09 — Camera: LockFirstPerson (flagged for head confirmation)
**Decision (Claude-advised):** the game runs in `StarterPlayer.CameraMode = LockFirstPerson`.
**Context:** the Watcher's freeze is judged server-side from the character's HEAD facing, but the flashlight cone follows the CAMERA — in default third-person those diverge, so a player could light the Watcher and it would NOT freeze (the core mechanic broke as played). First-person makes head-yaw track the camera (fixing it) and is horror-appropriate.
**Reversibility:** easy to veto — if third-person is wanted, the fix is client-camera reporting to the server instead. Flagged for Eddy/Jefferson.

## 2026-07-09 — Rendering: split-brain (server logic + client-smooth visual)
**Decision (Claude-advised architecture):** the Watcher creature and the Moral Collapse companion orb use a split-brain — the SERVER owns an invisible authoritative logic part (position/hitbox/state) at 10Hz; a CLIENT script renders the visible body/light and interpolates it at frame rate. Freeze/catch/choice stay server-authoritative and unexploitable; the client is read-only.
**Context:** anchored server parts snap on the client (choppy) and 60Hz replication is mobile-costly; this delivers smooth motion without either, and keeps authority on the server.
**Impact:** the reusable pattern for any moving creature/companion (Watcher.client.lua, Companion.client.lua). Also caught+fixed a P0 where the old welded Watcher body sat 47 studs off its hitbox.

## 2026-07-09 — Encounter I direction diverges from the Silent Witness doc (UNDER HEAD RECONCILIATION)
**State:** the shipped Encounter I is a VISIBLE-monster light-chase ("The Watcher"), which contradicts the Gate-A-approved `01-the-silent-witness.md` (a NO-ENTITY "being studied / find your own dossier" encounter — its Cut List explicitly cuts a visible entity). The build diverged because playtests rejected the dossier/notes execution as boring; the visible Watcher has since been iterated many times at Eddy's direction.
**Needs a head decision:** update the doc to sanction the visible-Watcher direction, or steer the build back toward "being studied." Flagged as a tracked task; do NOT silently pick one (above-canon). Docs are the single source of truth — whichever is chosen, update `01` + this log the same day.


## 2026-07-07 — Workflow pivot: slice before documentation
**Decision:** Development is prototype-first from now on. The Silent Witness gets a vertical slice that answers five questions — (1) does the player actually feel watched, (2) does the dossier reveal land, (3) which clues do players naturally notice, (4) what confuses them, (5) can we reliably generate the session dossier in Roblox — and the experience docs EVOLVE from real playtests instead of expanding on assumptions. The four Stage-2 docs stand as approved concepts (no redesign); their further elaboration is frozen until the slice teaches us something real. Build little by little; never the whole system.
**Context:** Eddy, verbatim intent: "Our goal isn't to have the best document. It's to build the best game. The document should evolve from the prototype, not replace it." Consistent with Bible ch. 10 (Prototype: fast, simple, cheap) and ch. 14 (build the smallest proof).
**Impact:** T8 full architecture proposal superseded by slice-scoped architecture; T1's next step is the slice, not more prose.
**Approved:** Eddy (chat, 2026-07-07). Propagated same turn: registry, this log.

## 2026-07-06 — Audio: no music in the prototype
**Decision:** The prototype ships NO music — sound effects, ambience, and silence only.
**Context:** Audit F5 scope residue; Eddy ruled "for now, no music yet."
**Impact:** All four experience docs, the audio system, the template. Diegetic creature vocalizations (e.g. The Moral Collapse's hum) are ruled sound effects, pending Eddy's confirmation at Gate A.
**Reversibility:** Easy — a later milestone may add score.
**Approved:** Eddy (chat, 2026-07-06). Propagated same day: CLAUDE.md, TEMPLATE.md, whiteboards 01-04, research agent briefs.

## 2026-07-06 — Design docs are repo-master
**Decision:** `design/` in this repo is the single authoritative home for Project 001 experience docs and research; Notion mirrors later.
**Context:** Boot question 3; one-source-of-truth law needed one declared home.
**Impact:** T1-T5 deliverables land here; canon docs in runtime-suite/canon remain Notion-mastered (unchanged).
**Approved:** Eddy (chat, 2026-07-06).

## 2026-07-06 — GATE A: all four experience whiteboards approved
**Decision:** The Silent Witness, The Violent Rhythm, The Hidden Presence, and The Moral Collapse whiteboards approved as designed; Stage 2 (climax-first five-act design) authorized for all four. The Moral Collapse companion's hum confirmed as diegetic creature SFX (legal under no-music).
**Approved:** Eddy (chat, 2026-07-06 — "we'll go with your suggestions").

## 2026-07-06 — Project remote: the existing connected repo
**Decision:** Project 001 pushes to the already-connected GitHub remote `Eddy-etame/Tower.` on branch `dev/eddy`. `main` there remains the Horror Castle archive and is never pushed directly (Rule 17); Project 001's main will exist only via reviewed merge.
**Context:** Eddy: the repo where the initial project idea started is the project's connected repo. Claude's standing recommendation, non-blocking: rename the GitHub repo (Tower. → e.g. project-001) for era-clarity — renames keep redirects, zero disruption; and cut a clean default branch at first reviewed merge.
**Approved:** Eddy (chat, 2026-07-06). Pushed same turn: dev/eddy (4 commits at time of push).

## 2026-07-06 — Private exports quarantined; game repo stays clean
**Decision:** Account exports (conversations.json, memories.json, users.json, projects/) moved to `RuntimeStudio/_private/`; the game repo is this dedicated folder so private data can never be pushed.
**Context:** Audit F4 (past transcripts exposed credentials); approved as boot question 2.
**Approved:** Eddy (chat, 2026-07-06). Executed same turn.
