# AGENTS.md — read this first if you are an AI working on Project 001

You are an LLM (Claude, or another model) about to work on **Project 001**, Runtime Studio's first
game — a single-player-first psychological-horror prototype set in **The Threshold**. This file is
the operating manual for any AI. Read it, then `CLAUDE.md`, then get the project running (below).

If you are Claude Code, `CLAUDE.md` is loaded for you automatically — it is the binding contract and
it wins over this file on any conflict. This file exists so that **any** model or tool can onboard.

---

## 0. Who is talking to you

Five founders share one Claude subscription: **Eddy Etame** (Studio Lead / head), **Jefferson**
(head), **Kyle, Carlos, Dylan**. **Never assume who is typing — ask their name if you don't know it.**
Then put them on their own branch (below). Claude advises; the **heads** (Eddy + Jefferson) decide.

## 1. Get it running — ONE command, zero manual setup

You install everything and launch it yourself. The human does nothing but press Play.

- **Windows:** `powershell -ExecutionPolicy Bypass -File scripts\bootstrap.ps1`
- **macOS:** `bash scripts/bootstrap.sh`

The script installs the toolchain (Rokit → rojo / stylua / selene / wally), installs **Roblox Studio
if it is missing**, installs the Rojo plugin, builds `Project001.rbxl`, and opens it in Studio ready
to test. Flags: `-Serve` / `--serve` (live-sync dev loop), `-NoLaunch` / `--no-launch` (build only).

The one thing a script cannot do: Roblox Studio requires a **one-time Roblox account sign-in** the
first time it opens. Everything else is automatic. To iterate with live sync, run with `-Serve`, then
in Studio open the Rojo panel → **Connect**; edits to `src/` sync live.

**Do not ask the user to install anything or run manual steps — run the bootstrap script for them.**

### Launch-and-confirm protocol (do this every fresh handoff)

After you run the bootstrap and Roblox Studio opens, you MUST **pause and confirm the human is signed
in before you continue** — use the **AskUserQuestion** tool (a yes/no question), do not just assume.
Say what you did and what they need to do, e.g.:

> "I've installed the toolchain, built the place, and opened it in Roblox Studio. If this is the first
> time, **add an account / sign in** in the Studio window, then press **Play** to test. Have you
> signed in and got it running?"  → options: **Yes, I'm in** / **No / it's not working**

If **Yes** → continue the project work (pick up `git log` on the current `dev/<name>` branch). If
**No** → help them past the sign-in / install snag (see the README troubleshooting), then ask again.
Never proceed to build/test claims until they've confirmed Studio is actually up.

## 2. The non-negotiables (full text in `CLAUDE.md`)

1. **Branch protocol.** On first contact, ask the human's name, then `git switch -c dev/<name>`
   (create or reuse). **ALL commits/pushes go to that branch — NEVER to `main`.** Main moves only via
   a reviewed merge approved by a head. This makes merge/push conflicts impossible; it binds every
   tool, model, and person, every time.
2. **Server-authoritative from day one.** Never trust the client. Every RemoteEvent/Function handler
   validates sender, type, range, state legality, and rate. Gameplay-critical state lives on the server.
3. **Design before code.** Nothing player-facing without an approved experience doc in
   `design/experiences/`. The Design Constitution is LOCKED — build within it.
4. **No music** in the prototype (Eddy, 2026-07-06) — SFX, ambience, and silence only. Sound is information.
5. **Honesty ratchet.** Shipping something you think is 100% means it's ~20% (with rigor, 15%). Never
   claim "done" — report an honest % and the exact gaps. A **stub is labeled STUB**, never demoed as done.
6. **Quality floor before any push:** `selene src` and `stylua --check src` both pass, zero console
   errors, no magic numbers (constants live in `src/shared/`), tested in actual gameplay on desktop
   **and** mobile. Build with `rojo build -o Project001.rbxl`.
7. **The bar is BAFFLED, not impressed.** Self-critique every deliverable before a human sees it and
   attach your own defect list — a flaw a head has to catch that you could have caught is a failure.
8. **Warden ledger.** If `../runtime-suite/ledger/` is reachable, append one line to `MISTAKES.md` the
   same turn any mistake is caught, and diff your work against `RULES.md` before any "done".

## 3. Boot the full system if it is here

If a sibling `runtime-suite/` folder is reachable (this repo living inside `RuntimeStudio/`, or the
skills installed globally), **boot it fully** per its `CLAUDE.md`: ten skills (runtime-studio-core →
encounter-design, baffled-bar, luau-architect, horror-craft, roblox-watch, ship-real, studio-os,
runtime-docs, the-warden), the canon (`runtime-suite/canon/` — Design Constitution → Handbook →
Project Bible → decision log; higher wins on conflict), the ledger, and the registry. If it is **not**
reachable (a fresh clone elsewhere), the "minimum law" in `CLAUDE.md` is binding and you say so rather
than improvise the rest.

## 4. Where things live

```
src/client|server|shared/   the game (client renders/requests, server decides, shared = constants)
design/experiences/         the four experience docs — the ONLY source of buildable design
design/research/            roblox-watch teardowns + craft studies (amplify the Bible, never redirect)
scripts/bootstrap.*         the zero-touch install + build + launch
default.project.json        Rojo mapping: src/ -> Roblox tree (src is the source of truth)
CLAUDE.md                   the binding contract (minimum law even without runtime-suite)
```

## 5. Handing off / continuing

It is the **same Claude subscription** across the team — a fresh session (any founder, any model) picks
up by reading this file + `CLAUDE.md`, running the bootstrap, and checking `git log` on the current
`dev/<name>` branch. Docs are the single source of truth; chat is temporary — write decisions down the
same day. Never make a teammate feel the model changed under them.
