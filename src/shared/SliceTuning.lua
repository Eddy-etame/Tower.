-- Every balance knob for the Silent Witness encounter lives in this one file (one-file tuning law,
-- carried from the archive autopsy: fair deception is reached by fast iteration, never code archaeology).
return {
	-- world sampling
	SAMPLE_INTERVAL = 0.5, -- seconds between behaviour samples
	CHECK_INTERVAL = 0.2, -- server tick for room / observation / scratch checks
	MAX_SAMPLES = 2400,

	-- pace / pause detection
	PAUSE_SPEED = 2, -- studs/second below which the subject counts as still

	-- the observer: chairs/paintings turn to face you the instant you stop looking at them
	VIEW_CONE_DOT = 0.4, -- >0.4 dot with look direction = "the subject is looking at it" (~66deg half-cone)
	CHAIR_COOLDOWN = 4, -- min seconds between a given watchable's turns
	CHAIR_MIN_ANGLE = 22, -- degrees; skip turns too small to read
	PAINTING_TILT_DEG = 10,
	PAINTING_SLIDE = 0.8,

	-- the entry click event (audio + light-dip twin)
	CLICK_DIP = 0.3,
	CLICK_DIP_SECONDS = 0.12,

	-- Act III: writing behind the quiet room's wall, only while the subject moves nearby
	SCRATCH_RANGE = 26,
	SCRATCH_SPEED = 0.3,
	SCRATCH_VOLUME = 0.4,

	-- Act I: the entrance light dies once the subject is this far past the first doorway
	COMMIT_X = 24,

	-- the climax reveal (staged in the annex)
	PANEL_REVEAL_SECONDS = 1.1, -- gap between each file sheet filling in
	LIVE_LINE_DELAY_SECONDS = 1.6, -- pause before the live line begins typing
	LIVE_LINE_CHAR_SECONDS = 0.06,
	POST_REVEAL_SECONDS = 2.5, -- beat after the live line before the door opens

	-- loop UI
	NOTE_POPUP_SECONDS = 5,
	ENDCARD_SECONDS = 5,

	-- STUB placeholder audio (Rule 2): built-in rbxasset until the studio records real foley
	CLICK_SOUND = "rbxasset://sounds/electronicpingshort.wav",
	CLICK_SPEED = 0.5,
	CLICK_VOLUME = 0.75,
}
