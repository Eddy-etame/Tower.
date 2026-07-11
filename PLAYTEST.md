# Project 001 — Playtest & Tuning Checklist

The game logic + geometry are built and hardened (three adversarial reviews). What it hasn't had is a
human in Studio: every timing/distance/atmosphere number is a first-pass value that needs *seeing*. Run
`scripts/bootstrap.ps1` (or `.sh`), press **Play**, and walk each encounter with this list. Every knob
below lives in **`src/shared/SliceTuning.lua`** (one-file tuning law) — change a number, re-Play, no rebuild
needed if you use `rojo serve`.

Report per encounter: does the LOOP work (start → objective → win) · is every death **fair** (self-attributable,
avoidable, telegraphed) · does the signature **moment** land · what feels off, and the honest %.

---

## Global (check first)
- Boot Output shows `[Project001][Server] booted` + `[Project001][Client] booted`, **zero red errors**.
- First-person camera (LockFirstPerson) feels right; the flashlight cone (`[F]`, or the mobile button) points where you look.
- The whole loop advances: Beginning → I → II → III → IV → Ending → loops back. No stage silently skips.

## Beginning / Ending
- Do they read as a cold dread threshold (Beginning) and a dim relief-with-weight (Ending), not bright rooms? Tune the `BuildKit.pool` brightness/colour in `Beginning.lua` / `Ending.lua` if still too lit.
- You spawn facing the pad (+X), not a wall.

## Encounter I — The Watcher (the living creature)
**Loop:** dark room → restore 3 of 4 breakers (light-managed) → the surge (lights blow, it lunges) → run out the open door.
- **The creature:** does it BREATHE, does its head/eyes track YOU, does it snap taut-still the instant you light it? (This is the hero read.) Tune `WATCHER_*` — `WATCHER_FOLLOW_K` (smoothing), `WATCHER_BREATH_*`, `WATCHER_SWAY_*`, the gaze pivots are in `WatcherRig.lua`.
- **Freeze fairness:** point your light at it → it freezes; look away → it comes. If it fails to freeze when clearly lit, tune `VIEW_DOT` (cone width). Battery: `BATTERY_DRAIN`/`RECHARGE`/`MIN`/`LOW`.
- **Speeds:** `ADVANCE_SPEED` (+`_PER_BREAKER`), `CATCH_DISTANCE`, `GRACE_SECONDS`, `SURGE_MULT`/`_SECONDS`.
- **Moment:** the reveal swell + the surge blackout-lunge — do they land? `WATCHER_NOTICE_*`, `WATCHER_COIL`.

## Encounter II — The Violent Rhythm (be on a mark when it surges)
**Loop:** witness one full breath from the mezzanine → cross the gallery mark-to-mark → reach the door.
- **The tell:** do the wall lamps clearly cascade the countdown, then dark-snap, then surge? Is standing on a green mark obviously safe and the open floor obviously lethal?
- **Fairness:** you should NEVER be swept while on a green plate; a sweep should always be "I mistimed." Tune the cycle: `RHYTHM_PERIOD` / `RHYTHM_SAFE` / `RHYTHM_WARN` / `RHYTHM_SURGE` (must sum to PERIOD), `RHYTHM_MARK_RADIUS`, `RHYTHM_START_GRACE`.
- Is the mark spacing (in `Gallery.lua`, `MARKS_X`) a fair 1-mark-per-cycle cross, tense at 2?

## Encounter III — The Hidden Presence (read the dark, don't let it close)
**Loop:** walk the corridor forward (it paces behind) → optionally record the tape (the reveal) → reach the door.
- **The tell:** is the band of DEAD LAMPS behind you readable as "it's there"? Does the ambient bed duck as it nears?
- **Pace fairness:** walking forward should hold it back; standing still lets it close → warns (a lamp dies) twice → 3rd = blackout. Tune `PRESENCE_SPEED` (⚠ vs WalkSpeed 16 — note #22: partial-stick mobile may need ~6), `PRESENCE_MAX_GAP`, `PRESENCE_CLOSE_DIST`, `PRESENCE_YIELD`, `PRESENCE_START_GRACE`.
- **Moment:** the tape playback — do the two rows of footsteps read as "there's a second set"?

## Encounter IV — The Moral Collapse (what is your way out worth)
**Loop:** the companion light leads you → **spend it** at the socket (it drains, the hum stops, the door opens, the world doesn't react) OR **cross the dark** passage (keep it) → out.
- **The companion:** does it follow SMOOTHLY (client-rendered) and read as alive/warm? Tune `MORAL_ORB_FOLLOW` + the offsets.
- **The spend climax:** does the drain (glow + hum fading to silence over `MORAL_DRAIN_SECONDS`) land as the gut-punch? Is the aftermath truly silent (no reaction)?
- **The dark crossing fairness:** move in the safe window, be STILL on the exhale (the vignette ramps + the hum swells as a facing-independent countdown; the mouth-orb flares). Moving on an exhale → blackout, choice stays open. Tune `MORAL_EXHALE_PERIOD`/`_SAFE`/`_WARN`, `MORAL_PASSAGE_DANGER`, `MORAL_MOVE_THRESH`.
- **Both exits work** (this was a P0 softlock — verify both the door AND the far passage exit are reachable).

---

## Publishing (make it public so friends can play)

Publish from the OPEN Studio session (publishing captures the current data model — make sure it's the
latest build: stop Play first).

1. **File → Publish to Roblox As...** → Create new experience. Name: **The Threshold** (working title,
   per the Bible). Short description: *"Four rooms. Four rules. One question — what's behind the next door?"*
2. **Game Settings → Basic Info:** Genre **Horror**; devices: **Computer, Phone, Tablet** (the game is
   built mobile-first; leave Console off — untested).
3. **Game Settings → Places → (your place) → Edit:** set **Maximum Players = 1**. This is important:
   every visitor gets their OWN private descent (single-player-first per the Bible), and no shared-server
   weirdness in the public build.
4. Complete the **Age Guidelines questionnaire** honestly (fear themes, no gore/violence depictions —
   expect a 9+ rating; that matches the design's no-gore laws).
5. **Game Settings → Permissions:** set to **Public**.
6. Share the experience page link. Updates later: **File → Publish to Roblox** (same place) — players
   get the new build on their next join.

## Known gaps to close (not bugs — scoped work)
- Real audio foley everywhere (currently one stub `.wav` — Audio dept).
- Environment art + real creature/companion meshes (blockout — Building/Animation dept).
- Encounter IV: the full Act I/II "save" bootstrap + path-B's "your own light dims for the run" symmetric cost.
- Encounter III: the "presence sits between you and the goal" routing (built as a trailing pacer).
- Encounter I: reconcile the visible-Watcher build with the Silent Witness design doc (a head decision — see `design/decisions.md` 2026-07-09).
