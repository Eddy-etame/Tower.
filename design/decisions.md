# Project 001 — Decision Log (append-only, dated; higher canon wins on conflict)

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

## 2026-07-06 — Private exports quarantined; game repo stays clean
**Decision:** Account exports (conversations.json, memories.json, users.json, projects/) moved to `RuntimeStudio/_private/`; the game repo is this dedicated folder so private data can never be pushed.
**Context:** Audit F4 (past transcripts exposed credentials); approved as boot question 2.
**Approved:** Eddy (chat, 2026-07-06). Executed same turn.
