# Project 001 — Standing Order (Runtime Studio)

You are working in Project 001, the first game of Runtime Studio — five founders (Eddy Etame, Jefferson, Kyle, Carlos, Dylan) sharing one Claude account: never assume who is typing; ask the name if unknown.

If the `runtime-suite/` folder is reachable (sibling directory when this repo lives inside `RuntimeStudio/`, or skills installed globally), boot it fully per its CLAUDE.md — ten skills, canon, ledger, registry. If it is NOT reachable (fresh clone elsewhere), the following is the minimum law and you must say so rather than improvise the rest.

## Minimum law (binding on any session, any model, any human)

1. **Branch protocol (Rule 17):** on first contact with any human, ask their name if unknown, then `git switch -c dev/<name>` (create or reuse). ALL commits/pushes go to their branch — NEVER directly to main. Main moves only via reviewed merge approved by a head (Eddy or Jefferson).
2. **Server-authoritative from day one.** Never trust client input. Every RemoteEvent/Function handler validates sender, types, ranges, state legality, and rate. All gameplay-critical state lives on the server.
3. **Design before code.** Nothing player-facing is built without an approved experience doc in `design/experiences/` (five pillars: Curiosity, Drama, Choice, Trust, Memory; five acts; climax-first; one core question per encounter, no two alike). The Design Constitution is LOCKED — build within it, never around it.
4. **Audio: NO MUSIC in the prototype** (Eddy, 2026-07-06) — sound effects, ambience, and silence only. Sound is information.
5. **Honesty ratchet:** ship thinking it's 100% = it's 20% (with rigor, 15%). Never claim "done" — report an honest % with the exact gaps. A stub is labeled STUB, never demoed as done.
6. **Quality floor:** zero console errors; no magic numbers (constants live in `src/shared/`); `selene src` + `stylua --check src` pass before any push; tested in actual gameplay on desktop AND mobile before claiming a feature works.
7. **The bar is BAFFLED:** self-critique every deliverable before the humans see it, and attach your own defect list. A flaw a head catches that you could have caught is a system failure.
8. **Docs are the single source of truth; chat is temporary.** Decisions made in chat are documented the same day. Design docs in `design/` are repo-master (Eddy, 2026-07-06).
9. When inside RuntimeStudio: any caught mistake gets one line appended to `../runtime-suite/ledger/MISTAKES.md` the same turn.

Claude advises; the heads (Eddy + Jefferson) decide.
