-- Every balance knob for the MVP experience "The Watcher" in one file (one-file tuning law: fair fear is
-- reached by fast iteration, never code archaeology). The rule of this room: it is frozen while in your
-- light, it advances the instant your light leaves it.
return {
	-- server tick
	CHECK_INTERVAL = 0.1,

	-- observation (server-authoritative: is the player facing the Watcher, in line of sight, close enough
	-- that their light would reach it). VIEW_DOT ~ cos(50deg): a generous cone so it reads as "in my light".
	VIEW_DOT = 0.64,
	OBSERVE_RANGE = 60, -- studs; matches the flashlight's reach

	-- the Watcher's advance (no reflexes: observation + light-rationing decide survival, never twitch speed).
	-- Tension CURVE, not constant highs (2026 watch): each breaker restored makes it bolder — reward offset
	-- by rising threat, so the finale carries real dread.
	ADVANCE_SPEED = 9, -- base studs/sec while unobserved
	ADVANCE_SPEED_PER_BREAKER = 2.4, -- +per restored breaker (9 -> 11.4 -> 13.8 -> 16.2)
	CATCH_DISTANCE = 4,
	RESET_PAUSE = 1.2,
	GRACE_SECONDS = 0.35, -- telegraph window: sound starts, but it does not gain ground yet (mobile-fair)

	-- THE SURGE — the signature moment: the instant you restore the last breaker, the lights you fought for BLOW
	-- OUT, a sting hits, and the Watcher lunges faster for a few seconds while the door opens. Restoring power is
	-- the peak, not a quiet win (Bible: Pressure -> Decision -> Consequence). Brief + freeze-still-works = fair.
	SURGE_SECONDS = 2.5, -- how long the Watcher's lunge lasts after power is restored
	SURGE_MULT = 1.3, -- speed multiplier during the surge (kept modest so it reads as drama, not a cheat)

	-- LIGHT-RATIONING (2026 watch: kill the safe-corner — standing bathing it in light forever must not be a
	-- stable win. The flashlight both lights your path AND freezes the Watcher, and it runs out.)
	BATTERY_DRAIN = 0.04, -- per second while ON (~25s of continuous light per full charge)
	BATTERY_RECHARGE = 0.06, -- per second while OFF (a burst economy: light, then let it breathe)
	BATTERY_MIN = 0.08, -- below this the light cannot freeze the Watcher and dims to a floor
	BATTERY_LOW = 0.25, -- below this the light flickers (a scare beat + a warning)

	-- AUDIO-AS-INFORMATION (2026 watch: the #1 lever for a NO-MUSIC horror MVP — the constraint is our weapon).
	-- The Watcher's move sound plays ONLY while it advances and cuts to silence the instant your light freezes
	-- it, so the audio itself teaches the rule and every death is one the player can narrate (a fair tell).
	-- STUB rbxasset sounds — the Audio dept records/uploads real foley (that is the real fix; system is ready).
	AMBIENT_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	AMBIENT_SPEED = 0.12,
	AMBIENT_VOLUME = 0.1,
	WATCHER_MOVE_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	WATCHER_MOVE_SPEED = 0.26,
	WATCHER_MOVE_VOLUME = 0.6,
	BREAKER_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	BREAKER_SPEED = 0.4,
	ESCAPE_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	ESCAPE_SPEED = 0.85,
	SURGE_SOUND = "rbxasset://sounds/electronicpingshort.wav", -- STUB: the power-death sting (Audio dept records real)
	SURGE_SOUND_SPEED = 0.55,

	-- THE LIVING WATCHER (split-brain: the SERVER owns one invisible LogicRoot — freeze/catch/locomotion all
	-- measure it, unchanged and unexploitable; the visible body is a CLIENT-LOCAL rig that smoothly follows the
	-- replicated LogicRoot and layers procedural life on top). The alive-layer TEACHES the locked rule: it
	-- breathes/sways/gazes while advancing and snaps taut-dead-still the instant it is lit (weeping-angel), so
	-- the motion is the visual twin of the move-sound for the muted-mobile majority. No new assets — pure CFrame.
	WATCHER_FOLLOW_K = 12, -- render-base catch-up rate (1-exp(-k*dt), ~90ms) — hides the 10Hz server steps at 60fps
	-- studs: hard-snap the visual to the true hitbox beyond this. MUST exceed the max per-tick server step
	-- (~2.1st during the surge = 16.2*1.3*0.1) or the clamp fires every tick and STROBES the surge; 2.8 lets the
	-- lerp survive while still bounding the visual trail well under CATCH_DISTANCE (4) for catch fairness.
	WATCHER_SNAP_CLAMP = 2.8,
	WATCHER_TURN_RATE = math.rad(300), -- max body re-face rate (~0.6s for 180deg) so a large reorient never whip-spins
	WATCHER_CULL_DIST = 80, -- studs: skip the whole articulation block when far/off-screen (mobile frame budget)
	WATCHER_YAW = math.rad(70), -- head-track yaw clamp; at the limit the head HOLDS (wants to keep looking, cannot)
	WATCHER_PITCH_UP = math.rad(30),
	WATCHER_PITCH_DN = math.rad(-25),
	WATCHER_HEAD_K = 170, -- idle head spring stiffness — a living lock with micro-overshoot, not a servo
	WATCHER_HEAD_RATIO = 0.7, -- damping ratio (<1 = slight organic overshoot)
	WATCHER_HEAD_K_SNAP = 380, -- notice-beat stiffness spike (frozen->waking): a fast, SILENT head snap
	WATCHER_NOTICE_RATIO = 0.8, -- near-critical so the snap LOCKS without rebounding past the yaw clamp (weeping-angel)
	WATCHER_NOTICE_SECS = 0.4,
	WATCHER_NOTICE_ARM_SECS = 0.7, -- must be HELD frozen this long before a look-away re-arms the notice snap/flare
	WATCHER_NOTICE_COOLDOWN = 2, -- and this long between flares — so flicking your light can never strobe the eyes
	WATCHER_BREATH_HZ = 0.2, -- ~12 breaths/min — predatory-slow patience; proves it is not a statue
	WATCHER_BREATH_RISE = 0.06, -- studs the chest heaves (kept sub-perceptual — restraint)
	WATCHER_BREATH_PITCH = math.rad(2),
	WATCHER_SWAY_A = 0.37, -- incommensurate weight-shift freqs (Hz) => quasi-non-repeating (anti-metronome)
	WATCHER_SWAY_B = 0.5,
	WATCHER_SWAY_PITCH = math.rad(1.5),
	WATCHER_SWAY_ROLL = math.rad(3),
	WATCHER_FREEZE_DAMP = 0.15, -- s to damp all life to 0 when lit (taut stillness that teaches the rule)
	WATCHER_ALIVE_RAMP = 0.2, -- s to bring life back when it advances
	WATCHER_LEAN_K = 90, -- lean spring stiffness (grace forward-lean / surge coil-release)
	WATCHER_GRACE_LEAN = math.rad(8), -- forward lean on the grace window — the muted-mobile twin of the move-sound
	WATCHER_SURGE_LEAN = math.rad(12), -- the released lunge lean (kept modest so the chest doesn't fold over the hips)
	WATCHER_COIL = math.rad(-12), -- the pre-lunge coil (leans BACK first — the fair telegraph)
	WATCHER_COIL_SECS = 0.22, -- how long it coils (holding ground) before releasing into the lunge
	WATCHER_EYE_LO = 0.22, -- resting eye glow (dim points you can just find in the dark)
	WATCHER_EYE_HI = 0.95, -- eye glow on the notice pulse
	WATCHER_EYE_DECAY = 0.45, -- s for the notice eye-flare to fall back to the rest glow
	WATCHER_BOLD_SCALE = 0.12, -- extra breath/sway amplitude per restored breaker (it grows bolder as power returns)

	-- ENCOUNTER II — THE VIOLENT RHYTHM. The gallery "breathes" on a FIXED period (determinism is forgiven,
	-- randomness resented). Each cycle: a SAFE window to move, a WARNING (lamps cascade toward the origin + an
	-- inhale rises = the countdown), then the SURGE — the open floor is lethal, the raised beat-MARKS are safe
	-- islands. Rule: be on a mark when it surges; cross mark-to-mark to the door. Speed never saves you — position
	-- + timing do (the slowest player has the same odds as the fastest). Server-authoritative schedule (the surge
	-- "entity" does not exist between events). Miss a window = wait one cycle, never a life (bus-timetable law).
	RHYTHM_PERIOD = 6, -- seconds per full breath
	RHYTHM_SAFE = 3.6, -- the move window (lamps calm)
	RHYTHM_WARN = 1.7, -- the cascade + inhale countdown
	RHYTHM_SURGE = 0.7, -- open floor lethal; marks safe. (SAFE + WARN + SURGE MUST equal PERIOD.)
	RHYTHM_MARK_RADIUS = 4.6, -- studs: how close to a mark's centre counts as "on the mark" (generous — no pixel-perfect)
	RHYTHM_START_GRACE = 6.3, -- covers the first FULL breath (SAFE+WARN+SURGE): the first surge is witnessed, never lethal
	-- STUB audio (Audio dept records real foley): the breath — inhale rises, surge roars
	RHYTHM_INHALE_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	RHYTHM_INHALE_SPEED = 0.5,
	RHYTHM_ROAR_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	RHYTHM_ROAR_SPEED = 0.28,

	-- ENCOUNTER III — THE HIDDEN PRESENCE. A real server-side presence PACES you down the corridor, keeping its
	-- distance; you never see it. It is betrayed by a SILENCE RADIUS — the ambient bed ducks and the lamps dim
	-- where it stands, so absence is a positional signal (visible as a band of dead lamps trailing behind you =
	-- the muted-player's twin). Walk forward and it stays back; stand still (to use the tape) and it CREEPS in.
	-- Close the gap twice and you're warned (a lamp dies); a third time it passes through you (blackout, respawn).
	-- The tape recorder is the reveal: record yourself, play it back, and hear the SECOND set of footsteps.
	PRESENCE_SPEED = 8, -- studs/s it creeps toward you (half walkspeed — walking forward outpaces it, stillness lets it close)
	PRESENCE_MAX_GAP = 28, -- it never trails further than this (snaps to keep pace — it is always with you)
	PRESENCE_CLOSE_DIST = 10, -- gap below this = a close event (a warning, then it yields)
	PRESENCE_YIELD = 15, -- how far it backs off on a warning
	PRESENCE_WARNINGS = 2, -- warnings before the third close blacks you out
	PRESENCE_BLACKOUT = 1.5, -- seconds of sensory blackout on the third close, then respawn at the start
	PRESENCE_SILENCE_RADIUS = 18, -- studs: lamps within this of the presence dim to the dead-zone low
	PRESENCE_RECORD_SECONDS = 3, -- stand still this long at the recorder to capture the tape

	-- ENCOUNTER IV — THE MORAL COLLAPSE. A small warm light finds you in the dark and lights your way — the only
	-- thing in the Threshold that ever responded to you. The way out needs light: a socket carved to fit it. SPEND
	-- it (hold at the socket; it settles, the hum slows and stops, the door opens — and the world does not react
	-- at all), OR CROSS THE DARK passage beside it (slow + quiet is beneath the shape's notice; RUN and it takes
	-- you) keeping the light but dimming yourself. Two real actions, symmetric permanence, zero reward difference,
	-- no judgment. The question is only: what is your way out worth? Committed server-side the instant it happens.
	MORAL_ORB_OFFSET_UP = 4.5, -- how high the companion hovers
	MORAL_ORB_OFFSET_FWD = 3, -- ...and how far ahead (it leads you), along +X
	MORAL_ORB_OFFSET_SIDE = 2.5,
	MORAL_ORB_FOLLOW = 6, -- follow catch-up rate (1-exp(-k*dt)) — an unhurried drift, not a leash
	MORAL_DRAIN_SECONDS = 4.5, -- the spend: hum + glow slow and fade to nothing over this long (the climax's length)
	MORAL_SOCKET_HOLD = 1.8, -- held place-action at the socket to commit (proximity alone NEVER commits)
	MORAL_EXHALE_PERIOD = 4, -- the shape's breath: a safe window to move, then an EXHALE when any movement draws it
	MORAL_EXHALE_SAFE = 2.8, -- the move window; the rest of the period is the exhale (the companion at the mouth flares)
	MORAL_MOVE_THRESH = 2, -- studs/s above which you count as MOVING; still is beneath its notice
	MORAL_PASSAGE_DANGER = 0.6, -- seconds of moving-during-an-exhale it tolerates before it takes you (grace to stop)
	MORAL_BLACKOUT = 1.5, -- pass-through blackout on a dark-crossing death (the choice stays open)

	-- the objective
	ROOM_MAX_X = 64, -- x of the door line; past it the player is safe. ONE source (Threat.step + Arena + vignette)
	LEVER_HOLD = 0.6, -- ProximityPrompt hold to throw the lever
	DOOR_TOUCH_WIN = true,
	FLASH_MIN_INTERVAL = 0.1, -- s: coalesce redundant same-value flashlight remote spam (min-law rate validation)

	-- UI timings
	CAUGHT_SECONDS = 2.4,
	ESCAPED_SECONDS = 5,
	RULES_SECONDS = 3.6, -- the 3-second-understanding onboarding: threat + rule + objective, shown then faded
	RETRY_HOLD = 1.2, -- shorter frozen window on a caught-RETRY (rules already taught — don't re-onboard every death)

	-- STUB placeholder audio (Rule 2): built-in rbxasset until the studio records real foley
	HEARTBEAT_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	CATCH_SOUND = "rbxasset://sounds/electronicpingshort.wav",
}
