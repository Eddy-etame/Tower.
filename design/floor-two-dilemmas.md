# FLOOR 2+ — THE DILEMMA ROOMS (Eddy's ideas, 2026-08-30)

**Source: Eddy, verbatim brief.** Four dilemma concepts for the next room-sets and floors.
Read with `blueprint-the-first-descent.md` (the tower structure) and `BRAIN.md` (doctrine).

---

## THE PATTERN (extracted — this is the real invention)

Every one of the four is the same machine, and the machine is what matters more than any single theme:

```
A 5-MINUTE ROOM
      ↓
A DILEMMA with a hard clock (10s freeze / 30s to detonation / one railgun shot / the vault door)
      ↓
TWO PATHS, both costly, neither correct
      ↓
THE NEXT ROOM IS DIFFERENT DEPENDING ON WHICH YOU TOOK
```

That last line is the leap. Floor 1's Moral Collapse changes a *memory* (the Ending's aftermath). These change **the next room itself**. That is the Project Bible line — *"Every completed encounter changes how the player approaches the next"* — taken to its maximum.

**Structural requirements this creates (engineering, not design):**
1. The stage FSM must support a **branching graph**, not an ordered list. (Floor 1 is `stages[current + 1]`.)
2. A **choice ledger** in the session, keyed per dilemma, that the router reads.
3. Each dilemma costs **3 rooms** (the dilemma + 2 continuations). Four dilemmas = **12 rooms**.

---

## THE FOUR (as given)

### 1. THE TIME-FREEZE EXECUTION — *inspired by JoJo: Stone Ocean*
Partner trapped in an execution field of delayed kinetic blades. The boss freezes reality for 10 seconds; your artifact grants **3 seconds of immune movement** inside it.
- **A — The Objective:** rush the boss, break concentration, kill them permanently. The blades drop. **Your partner dies.**
- **B — The Rescue:** tackle your partner clear. The execution fails, but the boss escapes into the temporal rift at full health.
- **→ A leads to THE VOID COLLAPSE:** the boss is dead but the temporal engine collapses into a black hole. Speedrun escape while carrying your partner's *ghost-memory artifact* — it grants their passive combat skills and **talks to you the whole way**.
- **→ B leads to THE BLEEDING TIMELINE:** locked in the rift with your saved partner. The boss summons hyper-accelerated future enemies. **Defend your injured partner** while they hack the rift door.

### 2. THE PLANET-CORE SACRIFICE — *inspired by Transformers: Prime*
Alien forge planet, core control panel, **30 seconds** to detonation. Above you: the evacuation fleet. Inside the forge: the bio-data to resurrect your dying species.
- **A — Save the Fleet:** invert the polarity. The fleet lives; **the species' resurrection becomes impossible.**
- **B — Save the Legacy:** secure the bio-data. **80% of the civilian population dies** in an orbital strike; the blueprint of your civilisation survives.
- **→ A leads to THE HANGAR BREACH:** survivors alive, morale zero, resources gone. Scavenger boarding pods attach. Clear the breach bay on the ship's **last energy units**.
- **→ B leads to THE COLD LABORATORY:** you escape with the data, and the surviving soldiers **mutiny** — they brand you a monster for letting their families die. You fight your own allies, who are trying to destroy the data out of grief.

### 3. THE UNLIKELY TRUCE — *inspired by Transformers: The Last Knight*
Your mind-controlled mentor is smashing the planetary shield generator while the superweapon closes in orbit. Your **sworn rival** arrives with a railgun and **one shot**.
- **A — Kill the Mentor:** shield holds, superweapon blocked. **You lose your mentor forever.**
- **B — Save the Mentor:** shoot the superweapon instead. Your mentor breaks free — **the planet's atmosphere shatters.**
- **→ A leads to INSIDE THE ENGINE ROOM:** you and your rival board the warship and fight side by side — and **the rival actively steals your kills and drops.**
- **→ B leads to ZERO-G SURVIVAL:** atmosphere bleeding into space, thruster movement, a draining **oxygen/fuel meter**, and your freed but heavily damaged mentor beside you.

### 4. THE BOSS'S BLOODLINE DILEMMA — *inspired by JoJo: Golden Wind*
You are a syndicate enforcer delivering a young target to an extraction vault. At the door you learn the boss intends to **harvest their life force** for godhood.
- **A — Complete the Mission:** lock them in. You gain **absolute authority and dark upgrades.** The target is consumed.
- **B — Break the Syndicate:** smash the locks, betray the boss, run with the target into the inner sanctum.
- **→ A leads to THE TRAITOR'S GAUNTLET:** empowered, you are sent to purge your former squadmates. You play an **overpowered juggernaut slaughtering your old friends** before they expose the boss.
- **→ B leads to THE ELEVATOR SHAFT:** ascending industrial lift, endless assassins from above, cables being cut. **Protect the target, keep the lift alive.**

---

## MY ANALYSIS (second brain — the part he didn't ask for)

### What is genuinely great here
The **branch-the-next-room** structure is the strongest idea in this project so far, including mine. It converts choice from *flavour* into *architecture* and it is exactly the tower's promise: the player cannot see what the next door holds, because **their own choice built it.** Two players compare runs and describe different rooms. That is the Bible's "invites conversation" pillar at full strength.

The dilemmas also obey the hardest rule correctly: **neither path is the good one.** Every A and every B costs something irreplaceable. That is Meaningful Choice per the Project Bible ("there is rarely one correct answer").

### The risks I must name (and design around)
1. **These are combat rooms, and Project 001 has no combat system.** Waves, railguns, juggernaut arenas, boarding pods. Floor 1 is a no-combat psychological horror. Building a mediocre combat system would cap every one of these rooms at 3/10 forever — and the Bible is explicit that *mechanics sit at the BOTTOM of the pyramid*, serving emotion. **The dilemma is the memory; the combat is only the delivery.**
   **Therefore:** where a room's fiction says "fight waves", I express it with mechanics we can take to 10/10 — pressure, protection, positioning, resource collapse, escort under threat — rather than a shallow shooter. The named example: *The Elevator Shaft* is a protection/attrition room, and protection under a rising clock is something this codebase can already almost do (Encounter II's rhythm + III's pacer).
2. **12 rooms is a very large scope.** Bible: *"Finish before expanding"* and *"simplicity wins."* Building all four dilemmas half-way is the failure mode. **Therefore: ONE dilemma, all three of its rooms, at 10/10 — then the next.**
3. **A partner/companion NPC is required by three of the four** (partner, mentor, rival, target). We have exactly one precedent: the Moral Collapse companion orb. A *character* who follows, speaks, and can die is a whole new system — and the rival who "steals your kills" is a genuine design gem worth building properly.
4. **The 5-minute clock is a new pillar.** Floor 1 has no timers (the Rhythm's period is a cycle, not a countdown). A visible, honest clock changes the entire feel — and per the Bible it must never lie.

### Which one goes first — my recommendation, with the reasoning
**#4, THE BOSS'S BLOODLINE DILEMMA.** Reasons, ranked:
- Its dilemma is the **cleanest and most human** — no sci-fi apparatus needed to understand it in three seconds. A child understands "they will kill this kid if you obey."
- Its two branches are **maximally different in feel**: A is power and shame (you are the monster, and you are strong); B is fear and duty (you are weak and carrying someone). That contrast is what sells the branch mechanic to a player.
- It needs **no orbital fleet, no zero-G, no time-freeze VFX** — the scope is a vault, a corridor, and an elevator. Achievable at 10/10.
- The Elevator Shaft is a **single-room ascent under attrition**, which is the most buildable "action" room in the set.

Runner-up: **#1 (Time-Freeze)**, because a 3-seconds-of-movement-inside-a-frozen-world mechanic is genuinely baffling to look at — but the VFX bill is the highest of the four.

### The engineering that unlocks ALL of them (doing this first)
A **branching stage router**: stages declare `next` as either a plain index (linear, Floor 1 unchanged) or a function of the session ledger. Cheap, backward-compatible, and it is the prerequisite for every idea above.
