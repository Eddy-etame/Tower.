-- Encounter IV — The Moral Collapse. A small warm light finds you in the dark and lights your way. The exit room
-- needs light: a socket carved to fit it. SPEND it (hold at the socket — it settles, the hum slows and STOPS,
-- the door opens, and the world does not react at all) OR CROSS THE DARK passage beside it (slow + quiet is
-- beneath the shape's notice; RUN and it takes you), keeping the light but paying the crossing's risk. Two real
-- actions, no reward difference, no judgment. Committed server-side the instant it happens. The question is only:
-- what is your way out worth?
local Players = game:GetService("Players")
local Sanctum = require(script.Parent.Parent.Sanctum)

local Stage = {}
Stage.name = "MoralCollapse"
Stage.title = "ENCOUNTER IV — THE MORAL COLLAPSE"
-- the whole dilemma rests on the companion being your light: with a personal flashlight, "spend your light or
-- cross the dark" has no weight. GameService tells the client to suppress the cone for this stage.
Stage.suppressFlashlight = true

local RULES = {
	{ t = "THE MORAL COLLAPSE", y = 0.3, s = 48 },
	{ t = "THE SMALL LIGHT KEPT YOU ALIVE.", y = 0.44, s = 28, c = { 255, 196, 120 } },
	{ t = "THE WAY OUT NEEDS LIGHT.", y = 0.51, s = 28 },
	{ t = "GIVE IT TO THE SOCKET,", y = 0.61, s = 30 },
	{ t = "OR CROSS THE DARK AND KEEP IT.", y = 0.68, s = 30, c = { 200, 60, 60 } },
	{ t = "IN THE DARK: SLOW AND QUIET. DON'T RUN.", y = 0.82, s = 20, c = { 150, 143, 128 } },
}

local function inPassage(p, pos)
	return pos.X >= p.minX and pos.X <= p.maxX and pos.Z >= p.minZ and pos.Z <= p.maxZ
end

function Stage.build(ctx)
	local tuning = ctx.tuning
	local sanctum = Sanctum.build(tuning, ctx.folder)

	local h = {
		sanctum = sanctum,
		ctx = ctx,
		spawn = sanctum.spawn,
		accum = 0,
		committed = nil, -- nil | "spending" | "spent" | "crossed"
		exhaleT = 0, -- the shape's breath clock (only advances while you're in the passage)
		danger = 0,
		taughtExhale = false,
		blackedOut = false,
		taught = {},
		escaped = {},
		lastDanger = nil, -- change-gate the vignette remote
		lastPassagePos = nil, -- server-sampled position for movement detection (client velocity is spoofable)
	}

	-- SPEND: a held place-action at the socket (armed only when the companion is near — proximity never commits)
	sanctum.socketPrompt.Triggered:Connect(function()
		if h.committed then
			return
		end
		h.committed = "spending"
		sanctum.socketPrompt.Enabled = false
		sanctum.orb:SetAttribute("OrbState", "drain") -- the client fades the visual light over the drain
		task.spawn(function()
			local orb, hum = sanctum.orb, sanctum.hum
			local start = orb.Position
			local t = 0
			while t < tuning.MORAL_DRAIN_SECONDS do
				t += task.wait()
				local a = math.clamp(t / tuning.MORAL_DRAIN_SECONDS, 0, 1)
				orb.Position = start:Lerp(sanctum.socketPos, math.min(a * 2, 1)) -- settles first, then drains
				hum.Volume = tuning.MORAL_HUM_VOLUME * (1 - a)
				hum.PlaybackSpeed = tuning.MORAL_HUM_SPEED * (1 - a * 0.75) -- the hum SLOWS (never pitch-tricks) as it fades
			end
			hum:Stop() -- ...stops.
			orb:SetAttribute("OrbState", "spent")
			ctx.session.moralChoice = "spent" -- the aftermath (the Ending) will know what you did
			sanctum.socketGlow.Brightness = 0.35 -- the warmth is gone
			-- THE WORLD DOES NOT REACT. one beat of authored nothing, then the door simply opens.
			task.wait(1.4)
			Sanctum.openDoor(sanctum)
			h.committed = "spent"
			for _, p in ctx.players() do
				ctx.send(p, { kind = "objective", text = "THE DOOR IS OPEN." })
			end
		end)
	end)

	-- SPEND exit (path A): no fanfare — the indifference is the point
	sanctum.doorTouchA.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or player ~= Players:GetPlayers()[1] or h.committed ~= "spent" or h.escaped[player.UserId] then
			return
		end
		h.escaped[player.UserId] = true
		task.delay(tuning.ESCAPED_SECONDS, function()
			if player.Parent then
				ctx.clear()
			end
		end)
	end)

	-- CROSS exit (path B): you kept it, and you carry the crossing's cost out
	sanctum.doorTouchB.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if
			not player
			or player ~= Players:GetPlayers()[1]
			or h.escaped[player.UserId]
			or h.committed == "spent"
			or h.committed == "spending"
			or h.blackedOut -- can't drift into the exit mid-blackout
		then
			return
		end
		h.committed = "crossed"
		ctx.session.moralChoice = "crossed" -- the aftermath (the Ending) will know what you did
		h.escaped[player.UserId] = true
		ctx.send(player, { kind = "banner", text = "YOU KEPT IT. IT STILL HUMS BEHIND YOU." })
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
		char:PivotTo(CFrame.lookAt(h.sanctum.spawn, h.sanctum.spawn + Vector3.new(1, 0, 0)))
	end
	local uid = player.UserId
	h.escaped[uid] = nil -- re-arm the exits for a rejoining player
	if not h.taught[uid] then
		h.taught[uid] = true
		ctx.send(player, { kind = "rules", lines = RULES })
	end
	ctx.send(player, { kind = "objective", text = "FIND THE WAY OUT. IT NEEDS LIGHT." })
end

function Stage.update(h, dt)
	local tuning = h.ctx.tuning
	h.accum += dt
	if h.accum < tuning.CHECK_INTERVAL then
		return
	end
	local step = h.accum
	h.accum = 0
	local s = h.sanctum

	if h.committed or h.blackedOut then
		-- ANY committed outcome (spending/spent/crossed) makes the room inert: the drain task owns the orb on a
		-- spend, and after a cross no new blackout may be scheduled (a pending one could fire past teardown and
		-- teleport the player into the NEXT stage — the exact cross-stage leak class)
		return
	end

	local player = Players:GetPlayers()[1]
	local root = player and player.Character and player.Character.PrimaryPart
	if not root then
		return
	end
	local pos = root.Position

	if inPassage(s.passage, pos) then
		s.socketPrompt.Enabled = false
		-- the companion cannot follow into the dark; it waits at the mouth. The shape BREATHES: a safe window to
		-- move, then an EXHALE when any movement draws it. A facing-independent COUNTDOWN warns first — the dread
		-- ramps and the hum swells BEFORE the exhale (the mouth flare is behind a +Z-facing crosser, so it cannot
		-- be the only tell). Move on the exhale and it takes you; be still and it passes.
		s.orb.Position = s.passageMouth -- set the logic target; the client smooths the visible orb to it
		h.exhaleT += step
		if h.exhaleT >= tuning.MORAL_EXHALE_PERIOD then
			h.exhaleT -= tuning.MORAL_EXHALE_PERIOD
		end
		local exhaling = h.exhaleT >= tuning.MORAL_EXHALE_SAFE
		local warnStart = tuning.MORAL_EXHALE_SAFE - tuning.MORAL_EXHALE_WARN
		local warn = math.clamp((h.exhaleT - warnStart) / tuning.MORAL_EXHALE_WARN, 0, 1)
		local intensity = exhaling and 1 or warn
		s.orb:SetAttribute("OrbState", exhaling and "flare" or "gutter") -- the client renders the flare/gutter
		if s.hum then
			s.hum.Volume = tuning.MORAL_HUM_VOLUME + 0.4 * intensity -- the hum swells as the countdown (omnidirectional)
			s.hum.PlaybackSpeed = tuning.MORAL_HUM_SPEED + 0.25 * intensity
		end
		-- movement from a SERVER-sampled position delta (client-owned AssemblyLinearVelocity is spoofable)
		local moving = h.lastPassagePos ~= nil
			and Vector3.new(pos.X - h.lastPassagePos.X, 0, pos.Z - h.lastPassagePos.Z).Magnitude / step
				> tuning.MORAL_MOVE_THRESH
		h.lastPassagePos = pos
		if exhaling and moving then
			h.danger += step
			if not h.taughtExhale then
				h.taughtExhale = true
				h.ctx.send(player, { kind = "banner", text = "IT EXHALES. BE STILL." })
			end
			if h.danger > tuning.MORAL_PASSAGE_DANGER then
				-- it takes you: FREEZE the player for the blackout, then return them to the room, choice still open
				h.blackedOut = true
				h.danger = 0
				local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.WalkSpeed = 0
				end
				root.Anchored = true
				h.ctx.send(player, { kind = "blackout", seconds = tuning.MORAL_BLACKOUT })
				-- clear the red vignette UNDER the black overlay, so it doesn't flash stale as the black lifts
				h.lastDanger = 0
				h.ctx.send(player, { kind = "danger", level = 0 })
				task.delay(tuning.MORAL_BLACKOUT, function()
					if root.Parent then
						root.Anchored = false
						root.AssemblyLinearVelocity = Vector3.zero
						root.CFrame = CFrame.new(12, 3.5, 10) -- back inside the exit room, at the mouth
					end
					if humanoid and humanoid.Parent then
						humanoid.WalkSpeed = 16
					end
					h.exhaleT = 0 -- retry begins in a safe window, not mid-exhale
					h.blackedOut = false
				end)
				return -- don't fall through to the danger send below (it would re-send 0.75 this same tick)
			end
		else
			h.danger = math.max(0, h.danger - step * 2)
		end
		local level = exhaling and 0.75 or (0.1 + 0.4 * warn)
		if level ~= h.lastDanger then
			h.lastDanger = level
			h.ctx.send(player, { kind = "danger", level = level })
		end
		return
	end

	-- in the light: the companion follows (ahead + up, where you look), and drifts to the socket when you bring
	-- it close — a last-chance hover, reversible, never a commit (the socket prompt is the only commit)
	h.lastPassagePos = nil -- left the passage; the movement sampler resets so re-entry starts fresh
	if s.hum then
		s.hum.Volume = tuning.MORAL_HUM_VOLUME
		s.hum.PlaybackSpeed = tuning.MORAL_HUM_SPEED
	end
	if h.lastDanger ~= 0 then
		h.lastDanger = 0
		h.ctx.send(player, { kind = "danger", level = 0 })
	end
	s.orb:SetAttribute("OrbState", "follow")
	local nearSocket = (pos - s.socketPos).Magnitude < 11
	s.socketPrompt.Enabled = nearSocket
	local target
	if nearSocket then
		target = s.socketPos + Vector3.new(0, 1.2, 0) -- hovers at the rim, straining toward it
	else
		local cf = root.CFrame
		target = root.Position
			+ cf.LookVector * tuning.MORAL_ORB_OFFSET_FWD
			+ Vector3.new(0, tuning.MORAL_ORB_OFFSET_UP, 0)
			+ cf.RightVector * tuning.MORAL_ORB_OFFSET_SIDE
	end
	s.orb.Position = target -- set the logic target; the client smooths the visible orb toward it at frame rate
end

return Stage
