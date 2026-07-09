# Project 001 — Runtime Studio

Psychological horror / encounter-based survival. Single-player-first prototype set in **The Threshold** — an impossible, indifferent place. Working title pending.

The prototype exists to prove one thing: *can we create encounters so memorable that players naturally want to open the next door, even when they're terrified of what's behind it?*

**Prototype scope (Project Bible v1.0):** core player controller, basic interaction system, four complete encounters, one beginning, one ending, atmospheric audio (**no music** — SFX/ambience/silence only, per Eddy 2026-07-06), basic UI, one complete playable experience, mobile sanity checks. NOT in scope: multiplayer, cosmetics, story campaign, large progression systems, extensive customization, live-service features.

---

> **Working with an AI on this repo?** Read **[AGENTS.md](AGENTS.md)** (and `CLAUDE.md`) first — they
> are the operating manual for any LLM: the non-negotiables, who's who, and how to launch. An AI should
> run the bootstrap for you; you shouldn't install anything by hand.

## Get running — ONE command (zero-touch)

The only prerequisite is **Git** ([git-scm.com](https://git-scm.com/downloads)). Everything else — the
toolchain **and Roblox Studio itself** — is installed for you, the place is built, and Studio opens
ready to test:

```powershell
git clone <repo-url> project-001
cd project-001
powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1     # Windows
# macOS:  bash scripts/bootstrap.sh
```

Then press **Play (F5)** in Studio. (The one thing no script can skip: Roblox Studio asks you to sign
in to a Roblox account the first time it opens.) Flags: `-Serve` for a live-sync dev loop,
`-NoLaunch` to build only.

<details>
<summary>Manual steps (if you'd rather not run the script)</summary>

Install **Rokit** ([releases](https://github.com/rojo-rbx/rokit/releases)) and **Roblox Studio**
([create.roblox.com](https://create.roblox.com/)), then:

```powershell
rokit install          # installs the pinned rojo / wally / selene / stylua
rojo plugin install    # installs the Rojo plugin into Roblox Studio (once per machine)
rojo build -o Project001.rbxl   # produces the place file (a build ARTIFACT — never commit it)
```
Open `Project001.rbxl` in Studio and press Play.
</details>

On Play you should see in Output:

```
[Project001][Server] booted — vX.Y.Z (<stage>)
[Project001][Client] booted — vX.Y.Z (<stage>)
```

(the exact version/stage comes from `src/shared/Version.lua`). Zero red errors in Output is the standard — a single console error means the build is broken.

To develop with live sync instead of rebuilding: run `rojo serve`, then in Studio open the Rojo plugin panel and press **Connect**. Edits to `src/` sync into Studio live.

### Troubleshooting: "The version of Roblox Studio is out of date"

The updater cannot replace Studio's files while ANY Roblox process is alive — a stuck instance makes every reinstall attempt "block" even after the download worked. Fix, in order:

1. Close every Roblox process: Task Manager → end `RobloxStudioBeta` and `RobloxCrashHandler` (or in PowerShell: `Stop-Process -Name RobloxStudioBeta,RobloxCrashHandler -Force`).
2. Check whether the files already updated — they often did: compare the folder name in `%LOCALAPPDATA%\Roblox\Versions\` against the official current version (`https://clientsettings.roblox.com/v2/client-version/WindowsStudio64` → `clientVersionUpload`). If they match, just relaunch — no reinstall needed.
3. Only if they differ: run `RobloxStudioInstaller.exe` from that Versions folder (with everything closed), then relaunch.

## Repo layout

```
src/
  client/    # rendering, input, UI controllers — the client renders and requests
  server/    # services, gameplay state, validation — the server decides
  shared/    # constants and modules used by both (no magic numbers anywhere else)
design/
  experiences/  # the four experience docs (T1-T4) — the ONLY source of buildable design
  research/     # teardowns and craft studies (T5) with application plans
default.project.json  # Rojo mapping: src/ -> Roblox tree (src is the source of truth)
```

## The laws of this repo

1. **Branch protocol** — every human works on their own branch: `git switch -c dev/<yourname>` (create once, reuse forever). ALL commits and pushes go there. **Nobody commits to `main`** — main moves only through a reviewed merge approved by a head (Eddy or Jefferson). This applies to every person, every tool, every AI, every time.
2. **Server-authoritative from day one** — never trust client input; every remote validates sender, type, range, state, and rate.
3. **Design before code** — nothing player-facing gets built without an approved experience doc in `design/experiences/`.
4. **A stub is labeled STUB** — in-file and in the status report. Never demoed as done.
5. **Before pushing:** `selene src` and `stylua --check src` both pass, and the game runs with zero console errors.

## Toolchain

Pinned in `rokit.toml` (proven versions carried from the studio's previous project): rojo 7.6.1, wally 0.3.2, selene 0.31.0, stylua 2.5.2. `selene` uses the committed `roblox.yml` standard-library definition; regenerate with `selene generate-roblox-std` after engine API updates.

Wally has no dependencies yet by design — packages land when a system needs them, never before.
