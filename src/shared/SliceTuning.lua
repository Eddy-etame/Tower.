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

	-- the objective
	LEVER_HOLD = 0.6, -- ProximityPrompt hold to throw the lever
	DOOR_TOUCH_WIN = true,

	-- UI timings
	CAUGHT_SECONDS = 2.4,
	ESCAPED_SECONDS = 5,
	RULES_SECONDS = 3.6, -- the 3-second-understanding onboarding: threat + rule + objective, shown then faded

	-- STUB placeholder audio (Rule 2): built-in rbxasset until the studio records real foley
	HEARTBEAT_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	CATCH_SOUND = "rbxasset://sounds/electronicpingshort.wav",
}
