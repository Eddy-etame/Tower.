-- Every balance knob for the Silent Witness slice lives in this one file (one-file tuning law,
-- carried from the archive autopsy: fair deception is reached by fast iteration, never code archaeology).
return {
	-- world sampling
	SAMPLE_INTERVAL = 0.5, -- seconds between route samples (dossier resolution)
	CHECK_INTERVAL = 0.25, -- server tick for room / pause / chair checks
	MAX_SAMPLES = 2400, -- 20 minutes of route history, hard cap

	-- pause detection (feeds the dossier's "STOOD Ns" lines)
	PAUSE_SPEED = 1.5, -- studs/second below which the player counts as standing
	PAUSE_MIN_SECONDS = 3,

	-- chair reorientation (the unobserved-change tell: never seen moving, always seen HAVING moved)
	CHAIR_COOLDOWN = 6,
	CHAIR_MIN_ANGLE = 25, -- degrees; skip rotations too small to read at silhouette scale

	-- the dossier board
	MAX_ROUTE_POINTS = 150,
	MAX_ENTRY_MARKS = 24,
	MAX_PAUSE_LINES = 6,
	READ_DETECT_SECONDS = 2, -- facing the board this long triggers the live line
	READ_RANGE = 18,
	LIVE_LINE = "SUBJECT IS READING THIS PAGE.",
	LIVE_LINE_CHAR_SECONDS = 0.07,

	-- STUB placeholder audio (Rule 2): built-in rbxasset until the studio records real foley
	CLICK_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	CLICK_SPEED = 0.55, -- pitched down so the ping reads as a dry mechanical click
	CLICK_VOLUME = 0.4,
}
