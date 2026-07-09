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

	-- the Watcher's advance (no reflexes: observation + light-rationing decide survival, never twitch speed)
	ADVANCE_SPEED = 11, -- studs/sec while unobserved (a walk faster than the player's backpedal, slower than sprint)
	CATCH_DISTANCE = 4,
	RESET_PAUSE = 1.2, -- seconds the Watcher holds still at the start of a run / after a catch, to be fair

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
