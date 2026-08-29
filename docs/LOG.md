# LOG — running tracker
Terse by design. Update after every major step. Newest entries at the top of each section.
Companions: `BRAIN.md` (what I know) · `CAPABILITIES.md` (what I can do).

---

## STATUS
- **v0.17.30** `dev/eddy` synced · tree clean · gates 0/0 · `Project001.rbxl` built.
- **Honest %: 15** (I called 50; Eddy's ratchet says 50 means 15 — re-auditing from 15).
- Published place is **STALE by 16 versions** (needs Eddy: File → Publish to Roblox As… → existing experience).
- Mode: overnight autonomous. No feedback requests until 100.

## TODO (live)
- [ ] Await Eddy's new ideas → analyse → pick first → blueprint it.
- [ ] Re-audit whole build from 15% (design, feelings, immersion, mechanics, ANIMATIONS).
- [ ] Roblox audio catalog sweep → replace stub `rbxasset://` foley with real curated IDs (browser).
- [ ] Game icon + thumbnail (default green baseplate now — generate + upload; icon/thumbnail may still need Creator Hub UI).
- [ ] Creature concept art → `multi_image_to_3d` → rigged/animated GLB → **convert to FBX** → upload via Open Cloud (test the Model path).
- [ ] UI/UX pass to baffled bar (text, typography, hit areas, states) — `make-interfaces-feel-better`.
- [ ] roblox-watch: study DOORS/Pressure/Rooms first frames + UI via browser; document findings here.
- [ ] Encounter I vs Silent Witness doc contradiction → still a HEAD decision, keep flagged.

## NEW INFO (fact — source)
- 2026-08-29 · **OPEN CLOUD UPLOAD WORKS.** API key stored at `~/.claude/secrets/roblox_api_key` (outside repo). Uploader: `~/.claude/tools/rbx_upload.py` (verify | upload | poll). Test Decal uploaded → assetId 105929786978573, moderation **Approved**. Images/decals are now fully automatable end-to-end.
- 2026-08-29 · Key gotcha: the first paste 401'd — JWT header+payload decoded fine, signature was transcription-corrupted. **Always use "Copy Key To Clipboard", never a visually-read copy.**
- 2026-08-29 · **AUDIO UPLOAD WORKS** (assetId 109173415419557, state Reviewing) after Eddy completed ID + email verification. Both now Verified on the account.
- 2026-08-29 · **THE FOLEY WALL IS BROKEN — ffmpeg is installed.** I can SYNTHESISE original foley (sine/noise sources + lowpass/highpass, aecho reverb, tremolo, pitch sweeps, fades, layering) and upload it. Not AI generation — real procedural sound design, fully iterable by me. Roblox catalog remains a second source.
- 2026-08-29 · Model/FBX upload still untested; Blender installing in background for GLB→FBX.
- 2026-08-29 · Account gaps flagged to Eddy: **no email, no phone** on the Roblox account → no recovery path for the account that owns the game. ID verification entry = Settings → Account info → "Continue with ID".
- 2026-07-21 · `generate_3d` makes GLB meshes, can rig + animate from a **678-clip library** (`animation_actions`) — MCP tool schema.
- 2026-07-21 · `generate_audio` is **speech only**; SFX/music models are restricted to a separate game pipeline and must not be used standalone — MCP tool schema. **Foley wall stands; Roblox catalog is the path.**
- 2026-07-21 · Credits: **857.62, Plus plan** — `balance`.
- 2026-07-21 · Mesh/Image Open Cloud API is **UNCHECKED + needs 13+ ID verification** on Eddy's account — his Creator Hub screenshot. Blocks automated asset upload.
- 2026-07-21 · Live experience: universe 10486987238, place 93713841443260, PUBLIC, 13 visits — games.roblox.com API.
- 2026-07-21 · Blender NOT installed on this PC — checked.
- 2026-07-21 · The 1332-site reference bank is BC-scoped (`Desktop/Boxing Center/05_REFERENCES`), not for this game.
- 2026-07-21 · motion-* skills are React/Next.js — principles transfer, code does not.

## FLAWS (flaw → fix) — open
- Game icon/thumbnail = default green baseplate → generate + Eddy uploads via Creator Hub.
- Watcher body = 7 grey boxes → concept art → 3D pipeline → real mesh.
- All foley = `rbxasset://` stubs → **synthesise originals with ffmpeg + upload** (primary), Roblox catalog (secondary).
- Published build stale → Eddy publishes.

## FLAWS FIXED (kept for the sibling-sweep habit)
- 2026-07-21 · 6 defects from the certification fleet: camera war (2 scripts owning CameraOffset), Gallery double ambient bed, immortal surge loop past teardown, pulse-vs-reset race, lamps embedded in pilasters, flashlight respawn closure pinning the cone to the dead body. + 6 material misses (2 biggest ceilings still flat concrete).
- 2026-07-21 · My patch helper truncated a file to 0 bytes (open-for-write before validating) → content computed FIRST, then written. Ledgered.

## DESIGN / BAFFLED-BAR FINDINGS
- The Runtime Pyramid says Presentation sits under Emotion — our weakest tier is Presentation, and it is the ceiling on everything above it.
- The Ending Effect (Bible Ch.7): endings are remembered most; ours is still the thinnest room. Highest-leverage under-built beat.
- Door-to-door variety is the tower's whole promise — now carried by per-room light moods; needs to extend to materials, sound signature, and motion signature per room.

## DONE (dated, terse)
- 2026-07-21 · Wrote `BRAIN.md`, `CAPABILITIES.md`, `LOG.md` (compression-survival docs).
- 2026-07-21 · v0.17.30 certified: 12 fleet leads hand-verified, 6 real fixed, material families complete in all 6 rooms.
- 2026-07-21 · v0.17.14→29: architecture language (pilasters/beams/monuments), game-feel camera, surge presentation, room moods, ambience layer + settles, impact sounds, Watcher silhouette + halo, realism/PBR pass, tower voice plaques, cinematic title beat.
