-- Encounter III — The Hidden Presence. A real presence PACES you down the corridor: it creeps toward you at half
-- your speed, so walking forward holds it back and standing still lets it close. You never see it — you read it
-- by the band of DEAD LAMPS (and the ducking bed) that trails behind you: absence is its position. Close the gap
-- and it warns you (a lamp dies, permanently — the count is in the world); the third close passes through you
-- (blackout, respawn). The tape recorder midway is the reveal: record, play it back, hear the SECOND footsteps.
-- Its position lives ONLY on the server (never replicated) — the client is told the tell (dimmed lamps), not the
-- coordinate. Reach the door to leave; you can finish without ever confirming it (the not-knowing follows you).
local Players = game:GetService("Players")
local Corridor = require(script.Parent.Parent.Corridor)

local Stage = {}
Stage.name = "HiddenPresence"
Stage.title = "ENCOUNTER III — THE HIDDEN PRESENCE"

local RULES = {
	{ t = "THE HIDDEN PRESENCE", y = 0.3, s = 48 },
	{ t = "SOMETHING KEEPS ITS DISTANCE BEHIND YOU.", y = 0.44, s = 28 },
	{ t = "WHERE THE LAMPS DIE, IT STANDS.", y = 0.51, s = 28 },
	{ t = "KEEP MOVING. DON'T LET IT CLOSE.", y = 0.61, s = 32, c = { 200, 60, 60 } },
	{ t = "REACH THE DOOR.", y = 0.71, s = 26 },
	{ t = "THE TAPE HEARS WHAT YOU CANNOT.", y = 0.82, s = 20, c = { 150, 143, 128 } },
}

local function nearestPlayer(corridor)
	local best, bestRoot
	for _, p in Players:GetPlayers() do
		local root = p.Character and p.Character.PrimaryPart
		if root and root.Position.X <= corridor.corridorMaxX then
			if not best or root.Position.X < best then
				best, bestRoot = root.Position.X, root
			end
		end
	end
	return bestRoot
end

function Stage.build(ctx)
	local tuning = ctx.tuning
	local corridor = Corridor.build(tuning, ctx.folder)

	local h = {
		corridor = corridor,
		ctx = ctx,
		spawn = corridor.entranceSpawn,
		accum = 0,
		presenceX = corridor.corridorMinX - tuning.PRESENCE_MAX_GAP, -- starts behind the entry
		warnings = 0,
		closeCd = 0,
		graceUntil = os.clock() + tuning.PRESENCE_START_GRACE, -- safe onboarding: no pacing/closing while the card is up
		blackedOut = false,
		recording = false,
		taught = {},
		escaped = {},
		lastDanger = {},
	}

	corridor.tapePrompt.Triggered:Connect(function(player)
		if h.recording or h.escaped[player.UserId] then
			return
		end
		h.recording = true
		corridor.reel.Color = Color3.fromRGB(90, 230, 120) -- reel spins (recording)
		task.delay(tuning.PRESENCE_RECORD_SECONDS, function()
			corridor.reel.Color = Color3.fromRGB(180, 60, 40)
			h.recording = false
			-- the reveal: your steps + a SECOND set, offset, one beat late
			ctx.send(player, { kind = "tape", steps = 7 })
		end)
	end)

	corridor.doorTouch.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or h.escaped[player.UserId] then
			return
		end
		h.escaped[player.UserId] = true
		ctx.send(player, { kind = "danger", level = 0 })
		ctx.send(player, { kind = "objective", text = "" })
		ctx.send(player, { kind = "banner", text = "YOU LEFT IT BEHIND." })
		task.delay(tuning.ESCAPED_SECONDS, function()
			if player.Parent then
				ctx.clear()
			end
		end)
	end)

	return h
end

function Stage.onPlayerEnter(h, ctx, player)
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.lookAt(h.corridor.entranceSpawn, h.corridor.entranceSpawn + Vector3.new(1, 0, 0)))
	end
	local uid = player.UserId
	h.escaped[uid] = nil -- re-arm the exit for a rejoining player
	if not h.taught[uid] then
		h.taught[uid] = true
		ctx.send(player, { kind = "rules", lines = RULES })
	end
	ctx.send(player, { kind = "objective", text = "REACH THE DOOR — KEEP MOVING SO IT CAN'T CLOSE." })
end

local function respawnStart(h)
	h.presenceX = h.corridor.corridorMinX - h.ctx.tuning.PRESENCE_MAX_GAP
	h.warnings = 0 -- warnings re-arm on wake (scars stay)
	for _, p in Players:GetPlayers() do
		local char = p.Character
		if char and char.PrimaryPart and not h.escaped[p.UserId] then -- never drag a player who already left back in
			char:PivotTo(CFrame.lookAt(h.corridor.entranceSpawn, h.corridor.entranceSpawn + Vector3.new(1, 0, 0)))
		end
	end
end

function Stage.update(h, dt)
	local tuning = h.ctx.tuning
	h.accum += dt
	if h.accum < tuning.CHECK_INTERVAL then
		return
	end
	local step = h.accum
	h.accum = 0
	local c = h.corridor

	if h.blackedOut then
		return -- frozen through the blackout; respawnStart is scheduled
	end

	local root = nearestPlayer(c)
	if not root then
		Corridor.setSilence(c, nil, 0)
		return
	end
	local playerX = root.Position.X
	local live = os.clock() >= h.graceUntil -- during onboarding grace it shows the tell but cannot pace/close you

	-- pace: creep toward the player, but never fall further than MAX_GAP behind (it is always WITH you)
	if live then
		h.presenceX += tuning.PRESENCE_SPEED * step
	end
	local gap = playerX - h.presenceX
	if gap > tuning.PRESENCE_MAX_GAP then
		h.presenceX = playerX - tuning.PRESENCE_MAX_GAP
		gap = tuning.PRESENCE_MAX_GAP
	end

	-- close event: it has reached your gap. Warn (scar a lamp + yield) twice; the third passes through you.
	if live and gap < tuning.PRESENCE_CLOSE_DIST and os.clock() >= h.closeCd then
		h.closeCd = os.clock() + tuning.PRESENCE_CLOSE_COOLDOWN
		h.warnings += 1
		if h.warnings > tuning.PRESENCE_WARNINGS then
			-- the third close: blackout, then respawn at the start
			h.blackedOut = true
			for _, p in Players:GetPlayers() do
				if not h.escaped[p.UserId] then
					h.ctx.send(p, { kind = "blackout", seconds = tuning.PRESENCE_BLACKOUT })
				end
			end
			task.delay(tuning.PRESENCE_BLACKOUT, function()
				respawnStart(h)
				h.blackedOut = false
			end)
			return
		else
			Corridor.scar(c, h.presenceX) -- a permanent lamp death: the count is readable in the world
			h.presenceX = playerX - (tuning.PRESENCE_CLOSE_DIST + tuning.PRESENCE_YIELD) -- it yields
			gap = tuning.PRESENCE_CLOSE_DIST + tuning.PRESENCE_YIELD
			for _, p in Players:GetPlayers() do
				if not h.escaped[p.UserId] then
					h.ctx.send(p, { kind = "banner", text = "IT STEPPED ASIDE. MOVE." })
				end
			end
		end
	end

	-- the tell: dim the lamp band on the presence; duck the bed as you enter its silence (both QUANTIZED to coarse
	-- steps so a client can't invert the continuous value back into the presence's exact coordinate)
	Corridor.setSilence(c, h.presenceX, tuning.PRESENCE_SILENCE_RADIUS)
	if c.bed then
		local bedRaw = math.clamp(gap / tuning.PRESENCE_SILENCE_RADIUS, 0.15, 1)
		c.bed.Volume = tuning.AMBIENT_VOLUME
			* (math.floor(bedRaw * tuning.PRESENCE_BED_STEP) / tuning.PRESENCE_BED_STEP)
	end
	-- danger vignette: PER-PLAYER from that player's own gap (not the nearest's), quantized + change-gated
	for _, p in Players:GetPlayers() do
		local uid = p.UserId
		if not h.escaped[uid] then
			local proot = p.Character and p.Character.PrimaryPart
			local pgap = proot and (proot.Position.X - h.presenceX) or tuning.PRESENCE_MAX_GAP
			local raw = math.clamp(1 - pgap / tuning.PRESENCE_MAX_GAP, 0, 0.6)
			local level = math.floor(raw / tuning.PRESENCE_LEVEL_STEP) * tuning.PRESENCE_LEVEL_STEP
			if level ~= h.lastDanger[uid] then
				h.lastDanger[uid] = level
				h.ctx.send(p, { kind = "danger", level = level })
			end
		end
	end
end

return Stage
