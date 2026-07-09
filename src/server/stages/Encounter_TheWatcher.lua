-- Encounter I — The Watcher. The being-watched experience, hardened: a dark room, a flashlight, three
-- breakers to restore power, and a figure frozen while in your light that advances the instant it leaves.
-- Escaping the door CLEARS the encounter (the door leads to the next, per the Bible's "what's behind the
-- next door"); being caught retries this encounter. Server-authoritative throughout.
local Players = game:GetService("Players")
local Arena = require(script.Parent.Parent.Arena)
local Threat = require(script.Parent.Parent.Threat)

local Stage = {}
Stage.name = "TheWatcher"
Stage.title = "ENCOUNTER I — THE WATCHER"

local function objectiveText(h)
	if h.powered then
		return "THE DOOR IS OPEN. GET OUT."
	end
	return ("RESTORE THE POWER — %d / 3"):format(Arena.activeCount(h.arena))
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
	}

	for index, breaker in arena.breakers do
		breaker.prompt.Triggered:Connect(function()
			if h.powered or not Arena.restoreBreaker(arena, index) then
				return
			end
			if Arena.activeCount(arena) >= #arena.breakers then
				h.powered = true
				Arena.openDoor(arena)
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
		char:PivotTo(CFrame.new(h.arena.entrance))
	end
	h.holdUntil = os.clock() + ctx.tuning.RULES_SECONDS -- Watcher frozen while the rules are on screen
	ctx.send(player, { kind = "rules" })
	ctx.send(player, { kind = "objective", text = objectiveText(h) })
end

function Stage.update(h, dt)
	local tuning = h.ctx.tuning
	h.accum += dt
	if h.accum < tuning.CHECK_INTERVAL then
		return
	end
	local step = h.accum
	h.accum = 0
	if os.clock() < h.holdUntil then
		return
	end

	local caught = Threat.step(h.watcher, step, Players:GetPlayers(), tuning, Arena.activeCount(h.arena))
	if caught and not h.caughtCooldown[caught.UserId] and not h.escaped[caught.UserId] then
		h.caughtCooldown[caught.UserId] = true
		h.holdUntil = os.clock() + tuning.RULES_SECONDS + tuning.CAUGHT_SECONDS
		h.ctx.send(caught, { kind = "caught" })
		task.delay(tuning.CAUGHT_SECONDS, function()
			if not caught.Parent then
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

	-- danger vignette (feel, don't read) — only while still in the room
	local wpos = h.watcher.root.Position
	for _, p in Players:GetPlayers() do
		local root = p.Character and p.Character.PrimaryPart
		if root then
			local level = 0
			if root.Position.X <= Arena.ROOM_MAX_X and not h.escaped[p.UserId] then
				local d = (root.Position - wpos).Magnitude
				level = math.clamp(1 - (d - tuning.CATCH_DISTANCE) / 26, 0, 1)
			end
			h.ctx.send(p, { kind = "danger", level = level })
		end
	end
end

return Stage
