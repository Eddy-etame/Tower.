# CAPABILITIES — what I can now do that I could not before

**Mapped 2026-07-21. Read with `BRAIN.md`.**
This file exists because I spent weeks telling Eddy "art, meshes and foley are department work". Some of that is now FALSE. This is the honest audit of what changed, what it unlocks for Project 001, and what is still genuinely blocked.

---

## A. GENERATION TOOLS (MCP) — the big change

Account: **Plus plan, 857 credits** at time of writing. Every generation costs credits. **Always preflight with `get_cost: true` before spending.** Never pass `use_unlim: true` unless Eddy explicitly asks.

### A1. `generate_3d` — THE MESH WALL IS BROKEN ⭐ highest-value unlock
Produces **GLB meshes**. Modes: `image_to_3d` (general, with texturing / PBR / rigging), `multi_image_to_3d` (2–4 views of the same subject → better geometry), `sam_3_3d` (single-object reconstruction), `3d_rigging` (rig an existing model).
**It can also ANIMATE:** `animation_actions` is a read-only catalog of **678 rig animations** (locomotion, gestures, daily actions, combat) with preview GIFs; pass `animation_action_id` plus `enable_animation: true`.
- **Why this matters:** Eddy said ANIMATIONS ARE VERY IMPORTANT and insisted on them at the 70% gate. The Watcher is currently seven grey boxes moved by procedural CFrame math. This is the path to a real creature.
- **Pipeline:** `generate_image` (concept art of the creature, multiple angles) → `multi_image_to_3d` → optional `3d_rigging` → optional animation clip → GLB.
- **THE CATCH — getting it into Roblox:** a MeshPart needs a Roblox asset ID. Two routes: (1) Eddy imports the GLB by hand via Studio's 3D Importer; (2) the Open Cloud Assets API uploads it — but the Creator Hub screenshot showed **"Enable Mesh / Image APIs" UNCHECKED with "You must be 13+ ID verified to access this API."** So automated upload is BLOCKED until Eddy ID-verifies. **I can still do 100% of the preparation**: generate, inspect, name, organise the GLBs in an import folder with a manifest, and write the Lua that consumes them the moment IDs exist.

### A2. `generate_image` / `generate_image_batch` — textures, icons, concept art
Models include `nano_banana_pro` (4K, good text/diagrams), `soul_2` (portraits/character), `marketing_studio_image` (commercial/product). Uses: the **game icon and thumbnails** (currently the default green Roblox baseplate — an immediate, visible quality failure on the experience page), concept art that feeds the 3D pipeline, and surface textures. Same upload caveat as meshes for in-game textures; icons/thumbnails upload through the Creator Hub UI, which Eddy can do in a minute.

### A3. `generate_video` / `generate_video_batch` — the experience-page trailer
For the store page and for sharing. Not in-game.

### A4. `generate_audio` — ⚠️ SPEECH ONLY. **THE FOLEY WALL STANDS.**
The tool states plainly: it generates speech (TTS) only; it "cannot generate music or sound effects for general use", and the music/SFX models (`sonilo_music`, `mirelo_text_to_audio`) exist ONLY for a separate game-generation pipeline and **must not be used for standalone audio**. I will not misuse them.
**Therefore the real foley paths are:**
1. **Roblox's own audio catalog** — thousands of free, licensed sounds usable by asset ID with no upload needed. **This is the strongest available path and I have a browser to search it.** It replaces the current `rbxasset://` placeholder stubs with real, curated horror foley.
2. Eddy records or sources audio and uploads it (his account, his call).
3. Speech TTS is available if the tower ever needs a voice — but the Bible forbids music and the design is voiceless, so this is likely unused.

## B. BROWSER — research and verification without Eddy

`mcp__Claude_Browser__*` (in-app browser: navigate, read_page, get_page_text, find, computer, screenshot, console, network). Uses for this project:
- **Roblox audio/asset catalog search** for real foley IDs (see A4).
- **roblox-watch research**: study DOORS, Pressure, Rooms, The Mimic and current front-page horror — what their first frame does, their UI, their pacing.
- **Roblox Creator Docs**: verify APIs before using them instead of trusting memory.
- **Verify the published experience page** looks right to a stranger.

## C. WORKFLOWS / SUBAGENTS (ultracode is ON)

`Workflow` runs deterministic multi-agent scripts; `Agent` spawns single subagents. Proven pattern from this project: **hunt → adversarially verify** (finders propose, independent skeptics try to refute; only survivors are accepted). This caught 6 real defects in the last sprint.
**Hard lesson from that run: agents can die on quota mid-workflow, and an empty `confirmed` list from dead verifiers is NOT a clean bill of health.** Always check the failures block; verify by hand what the fleet could not.

## D. SKILLS NEWLY AVAILABLE — mapped by usefulness to Project 001

### Tier 1 — load these during the overnight run
| Skill | Use |
|---|---|
| **baffled-bar** | The standard + persona rotation. Load before ANY deliverable. Already core. |
| **passe-hater** (FR) | The ritual before handing back: destroy my own work, open it for real, then announce a LOW defensible percentage. Directly encodes Eddy's ratchet. |
| **the-warden** | Ledger loop: mistakes → MISTAKES.md, repeats → RULES.md. |
| **horror-craft** / **encounter-design** / **luau-architect** / **roblox-watch** | The four project-specific craft skills. Already core. |
| **respect-de-l-existant** (FR) | Never remove, replace, or invent. Removing a feature to dodge a bug and inventing a missing value are among his most-punished faults. Critical during a big autonomous refactor night. |
| **make-interfaces-feel-better** | Concrete polish details: spacing, typography, borders, hit areas, states. Maps onto the UI/UX pass he demanded. |
| **windows-desktop-e2e** | Driving Studio myself for verification (already used; the driver script lives in the session scratchpad). |
| **verification-loop** / **click-path-audit** | Systematic verification of every interactive path. |

### Tier 2 — high value, situational
**deep-research** (multi-source cited research), **council** (four-voice structured disagreement for ambiguous calls — good for choosing WHICH idea to build first), **product-lens** (validate the why before building), **blueprint** (multi-session construction plans with self-contained context briefs — ideal for the tower), **second-brain** (the posture: associate who signs the work, never an order-taker), **reve** (retrospective pass over past sessions to catch repeating faults), **agent-design-patterns**, **claude-routines** (scheduled/proactive agents), **team-agent-orchestration**, **parallel-execution-optimizer**.

### Tier 3 — principles transfer, code does NOT
**motion-foundations / motion-patterns / motion-advanced / motion-ui** are React/Next.js with `motion/react`. **They are NOT drop-in for Roblox/Luau.** What transfers is the *thinking*: motion tokens, spring presets over linear tweens, stagger, exit animations, performance and accessibility rules, device adaptation. I will mine them for principles and implement in TweenService — and I will not pretend the code applies.
**blender-motion-state-inspection** — relevant IF I inspect generated rigs, but **Blender is NOT installed on this machine** (checked). Would need installing before use.
**veille-references-web** — points at a local bank of 1332 sites, but it lives in `Desktop/Boxing Center/05_REFERENCES` and is web-design scoped for that project. For Project 001 my research surface is the browser plus roblox-watch, not this bank.

### Tier 4 — other projects, do not load here
All **bc-\*** skills (Boxing Center: ads, design, photos, video, master), **prompts-et-evals** and **depot-partage** (BC/web repos), plus the large library of framework-specific skills (django, laravel, springboot, cloudflare, kotlin, swift, etc.). Noted so I never waste context loading them for a Roblox game.

## E. WHAT IS STILL GENUINELY BLOCKED (after trying every way)

1. **Uploading any asset to Roblox from here** — meshes, textures, audio all need either Eddy's Studio session or the Open Cloud Assets API, and the Mesh/Image API is gated behind **13+ ID verification** on his account. *I can prepare everything up to the upload boundary.*
2. **Publishing the place** — requires Eddy's Studio (File → Publish to Roblox As… → existing experience). The live build is stale by 16 versions.
3. **Real human playtest feedback** — his eyes, his verdict. Mine is a substitute, not a replacement.
4. **Original recorded foley** — see A4; the catalog path is the workaround and I will exhaust it first.

## F. THE OVERNIGHT OPERATING RULES (self-imposed, from his brief)

1. No feedback requests until 100%. Decide and proceed.
2. Run my own workflows and prompts.
3. Update `docs/LOG.md` after every major step — terse: todo, new info + source, new flaw + fix, new design, baffled-bar findings.
4. Percentage discipline: at 50 look again (it is 15). 70 is 50. Stricter as it climbs. Heaviest scrutiny on **design, feelings, immersion, mechanics, and ANIMATIONS**.
5. Gates before every commit: `stylua --check src` and `selene src` at 0/0, `rojo build` clean, real exit codes.
6. Every caught mistake → MISTAKES.md the same turn.
7. Never touch main. Never invent a value. Never remove a feature to dodge a bug.
8. Preflight every credit spend with `get_cost`.
