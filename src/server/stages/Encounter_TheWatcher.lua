-- Encounter I — The Watcher. The being-watched experience, hardened: a dark room, a flashlight, three
-- breakers to restore power, and a figure frozen while in your light that advances the instant it leaves.
-- Escaping the door CLEARS the encounter (the door leads to the next, per the Bible's "what's behind the
-- next door"); being caught retries this encounter. Server-authoritative throughout.
local Players = game:GetService("Players")
local Arena = require(script.Parent.Parent.Arena)
local Threat = require(script.Parent.Parent.Threat)

local function playAt(part, soundId, speed, volume)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	s.PlaybackSpeed = speed
	s.Volume = volume
	s.Parent = part
	s:Play()
	s.Ended:Once(function()
		s:Destroy()
	end)
end

local Stage = {}
Stage.name = "TheWatcher"
Stage.title = "ENCOUNTER I — THE WATCHER"
Stage.mood = { ambient = { 0.13, 0.145, 0.16 }, fog = { 0.06, 0.075, 0.09 }, saturation = -0.32 } -- colder steel; the dark leans blue

local RULES = {
	{ t = "THE WATCHER", y = 0.3, s = 54 },
	{ t = "KEEP IT IN YOUR LIGHT.", y = 0.43, s = 30 },
	{ t = "IT MOVES WHEN YOU LOOK AWAY.", y = 0.5, s = 30 },
	{ t = "YOUR LIGHT DRAINS. LET IT REST.", y = 0.59, s = 26, c = { 206, 190, 150 } },
	{ t = "RESTORE THE POWER.   GET OUT.", y = 0.69, s = 34, c = { 200, 60, 60 } },
	-- m = the mobile variant (the client picks it on touch — "[F]" would lie to the ~70% on phones)
	{
		t = "[F] LIGHT       [E] RESTORE",
		m = "TAP LIGHT       HOLD A BREAKER",
		y = 0.82,
		s = 20,
		c = { 150, 143, 128 },
	},
}

local function objectiveText(h)
	if h.powered then
		return "THE DOOR IS OPEN — RUN."
	end
	return ("RESTORE THE POWER — %d / %d"):format(
		math.min(Arena.activeCount(h.arena), Arena.REQUIRED),
		Arena.REQUIRED
	)
end

function Stage.build(ctx)
	local tuning = ctx.tuning
	local arena = Arena.build(tuning, ctx.folder)
	local watcher = Threat.build(arena.folder)
	Threat.attachSound(watcher, tuning)

	local h = {
		arena = arena,
		watcher = watcher,
		ctx = ctx,
		spawn = arena.entrance,
		powered = false,
		escaped = {},
		caughtCooldown = {},
		holdUntil = os.clock() + tuning.RULES_SECONDS,
		accum = 0,
		revealed = false, -- the entry reveal beat plays once, not on every caught-retry
		taught = {}, -- [userId] onboarded (per-player, like II/III/IV — a co-op joiner still gets the card)
		active = true, -- false after teardown, so a pending caught-retry closure can't fire into the next stage
		lastDanger = {}, -- [userId] = last danger level sent (change-gate the vignette remote)
	}

	for index, breaker in arena.breakers do
		breaker.prompt.Triggered:Connect(function()
			if h.powered or not Arena.restoreBreaker(arena, index) then
				return
			end
			if Arena.activeCount(arena) >= Arena.REQUIRED then
				h.powered = true
				Arena.surge(arena) -- the peak: lights blow out, door opens, sting
				Threat.surge(watcher, tuning) -- the Watcher lunges
				for _, p in ctx.players() do
					ctx.send(p, { kind = "surge" })
				end
			end
			for _, p in ctx.players() do
				ctx.send(p, { kind = "objective", text = objectiveText(h) })
			end
		end)
	end

	arena.doorTouch.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or not h.powered or h.escaped[player.UserId] then
			return
		end
		h.escaped[player.UserId] = true
		arena.escapeSound:Play()
		ctx.send(player, { kind = "escaped" })
		task.delay(tuning.ESCAPED_SECONDS, function()
			if player.Parent then
				ctx.clear() -- the door leads onward: clear this encounter, advance to the next
			end
		end)
	end)

	return h
end

function Stage.onPlayerEnter(h, ctx, player)
	local char = player.Character
	if char and char.PrimaryPart then
		-- face the player DOWN THE THROAT into the room (+X), not at a side wall, so they meet the space head-on
		char:PivotTo(CFrame.lookAt(h.arena.entrance, h.arena.entrance + Vector3.new(1, 0, 0)))
	end
	local uid = player.UserId
	h.escaped[uid] = nil -- re-arm the exit for a rejoining player
	-- SHIP B: the light state is the DESCENT's now — this room must NOT reset it (that was the whole bug we
	-- are fixing: every room used to hand the player a full battery back).
	-- holdUntil only ever EXTENDS (math.max): a co-op entrant's shorter hold must never cut a peer's in-flight
	-- rules read short — that would wake the Watcher while someone is still reading the card (unfair catch)
	if not h.taught[uid] then
		-- first entry for THIS player: teach the rules and hold the Watcher for the full read
		h.taught[uid] = true
		h.holdUntil = math.max(h.holdUntil, os.clock() + ctx.tuning.RULES_SECONDS)
		ctx.send(player, { kind = "rules", lines = RULES })
	else
		-- a caught-retry: the player already knows the rules — a brief regroup, then straight back in. This MUST
		-- dismiss the caught card (only the rules beat used to; skipping rules here would leave it stuck on screen).
		h.holdUntil = math.max(h.holdUntil, os.clock() + ctx.tuning.RETRY_HOLD)
		ctx.send(player, { kind = "retry" })
	end
	ctx.send(player, { kind = "objective", text = objectiveText(h) })
end

function Stage.teardown(h)
	h.active = false -- pending caught-retry closures bail instead of touching destroyed instances
end

function Stage.update(h, dt)
	local tuning = h.ctx.tuning
	h.accum += dt
	if h.accum < tuning.CHECK_INTERVAL then
		return
	end
	local step = h.accum
	h.accum = 0

	-- SHIP B: the battery now belongs to the DESCENT (GameService drives drain/recharge in every room).
	-- This room only declares the frozen window (rules card / caught screen), during which the drain pauses —
	-- the player cannot act and the Watcher is not stepping, so charging them would be unfair (fair-learning).
	local frozenWindow = os.clock() < h.holdUntil
	h.ctx.pauseDrain(frozenWindow)
	local lighting = h.ctx.lighting()

	-- THE MOMENT: fire the reveal the instant a player first clears the throat into the room (x > 6), where they
	-- can actually see the space open and catch the shape — not while they are still in the corridor facing a gap.
	-- It fires once (h.revealed sticks), well inside the frozen RULES window, so the Watcher is still safe.
	if not h.revealed then
		for _, p in Players:GetPlayers() do
			local root = p.Character and p.Character.PrimaryPart
			if root and root.Position.X > 6 then
				h.revealed = true
				Arena.playReveal(h.arena)
				h.ctx.broadcast({ kind = "kick", n = 0.3 }) -- the room opening is felt, not just seen
				break
			end
		end
	end

	if os.clock() < h.holdUntil then
		return
	end

	local caught = Threat.step(h.watcher, step, Players:GetPlayers(), tuning, Arena.activeCount(h.arena), lighting)
	if caught and not h.caughtCooldown[caught.UserId] and not h.escaped[caught.UserId] then
		h.caughtCooldown[caught.UserId] = true
		-- freeze the Watcher for the caught screen; onPlayerEnter then sets the (shorter) post-retry hold
		h.holdUntil = os.clock() + tuning.CAUGHT_SECONDS
		local croot = caught.Character and caught.Character.PrimaryPart
		if croot then
			playAt(croot, tuning.CATCH_SOUND, tuning.CATCH_SOUND_SPEED, tuning.CATCH_SOUND_VOLUME)
		end
		h.ctx.send(caught, { kind = "caught" })
		task.delay(tuning.CAUGHT_SECONDS, function()
			-- fire-time re-checks: the stage may have been torn down (h.active), the player may have left, or
			-- they may have slipped out the open door DURING the caught card (escaped) — never yank them back
			if not h.active or not caught.Parent or h.escaped[caught.UserId] then
				return
			end
			h.powered = false
			Arena.reset(h.arena)
			Threat.reset(h.watcher)
			Stage.onPlayerEnter(h, h.ctx, caught) -- retry the encounter
		end)
		task.delay(tuning.CAUGHT_SECONDS + 0.5, function()
			h.caughtCooldown[caught.UserId] = nil
		end)
	end

	-- danger vignette (feel, don't read) — only while still in the room, and only while it is actually a THREAT.
	-- When it is frozen/held in your light you are safe, so drop the alarm right down: red must mean "it's closing",
	-- never "it's near but I've got it" — or the signal lies and stops meaning anything.
	local wpos = h.watcher.root.Position
	local threatening = h.watcher.root:GetAttribute("WatcherState") ~= "frozen"
	for _, p in Players:GetPlayers() do
		local root = p.Character and p.Character.PrimaryPart
		if root then
			local level = 0
			if root.Position.X <= Arena.ROOM_MAX_X and not h.escaped[p.UserId] then
				local d = (root.Position - wpos).Magnitude
				level = math.clamp(1 - (d - tuning.CATCH_DISTANCE) / 26, 0, 1)
				if not threatening then
					level = level * 0.2
				end
			end
			-- change-gate (epsilon band — this level is continuous): no 10Hz same-value remote spam
			if math.abs(level - (h.lastDanger[p.UserId] or -1)) > 0.02 then
				h.lastDanger[p.UserId] = level
				h.ctx.send(p, { kind = "danger", level = level })
			end
		end
	end
end

return Stage
