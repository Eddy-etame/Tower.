-- The Beginning: a cold antechamber and ONE heavy door — the game's whole engine ("what's behind the next
-- door?") made physical in the first thirty seconds. No pad, no cutscene: you walk toward the door, it grinds
-- upward on its own as you near (the Threshold invites; it does not care), and you step through into the dark.
-- Zero text beyond the name and the question (2026 watch: sub-30s time-to-fun; understand in seconds).
local Players = game:GetService("Players")
local BuildKit = require(script.Parent.Parent.BuildKit)

local Beginning = {}
Beginning.name = "Beginning"
Beginning.title = "THE THRESHOLD"

local DOOR_X = 34 -- the room's east wall (BuildKit.room leaves the z[-3,3] gap + lintel there)
local OPEN_DIST = 11 -- studs: the door starts grinding open when a player is this near
local OPEN_SECONDS = 1.8 -- slow enough to feel heavy, fast enough to never gate the player

function Beginning.build(ctx)
	local folder = ctx.folder
	local tuning = ctx.tuning
	BuildKit.room(folder, { minX = 0, maxX = 34, minZ = -12, maxZ = 12 })
	-- one cold light, ON THE DOOR (the focal point; the rest of the room holds the dark)
	BuildKit.pool(folder, 29, 10.5, 0, Color3.fromRGB(150, 168, 196), 1.0, 22)
	-- the name, off to the side — read it or don't; the door is the point
	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(17, 5.5, -11.4), Vector3.new(17, 5.5, 0)),
		"THE THRESHOLD",
		BuildKit.PAPER
	)
	-- the question, over the door
	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(33.5, 8.6, 0), Vector3.new(0, 8.6, 0)),
		"WHAT'S BEHIND\nTHE NEXT DOOR?",
		BuildKit.PAPER
	)

	-- THE DOOR: heavy, filling the gap, closed until approached
	local door = BuildKit.part({
		Size = Vector3.new(1.2, 8.6, 6),
		CFrame = CFrame.new(DOOR_X, 4.3, 0),
		Color = Color3.fromRGB(42, 40, 38),
		Material = Enum.Material.DiamondPlate,
		Name = "FirstDoor",
	}, folder)

	-- a short dark vestibule beyond it (you step INTO darkness — the commitment), with the advance zone
	BuildKit.part({
		Size = Vector3.new(10, 0.2, 10),
		CFrame = CFrame.new(39, 0.1, 0),
		Color = Color3.fromRGB(24, 24, 26),
		Material = Enum.Material.Concrete,
		Name = "VestibuleFloor",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(10, 0.5, 12),
		CFrame = CFrame.new(39, 11.25, 0),
		Color = Color3.fromRGB(20, 22, 24),
		Material = Enum.Material.Concrete,
		Name = "VestibuleCeiling",
	}, folder)
	for _, vz in { -5.5, 5.5 } do
		BuildKit.part({
			Size = Vector3.new(10, 11, 1),
			CFrame = CFrame.new(39, 5.5, vz),
			Color = Color3.fromRGB(30, 31, 33),
			Material = Enum.Material.Concrete,
			Name = "VestibuleWall",
		}, folder)
	end
	BuildKit.part({
		Size = Vector3.new(1, 11, 12),
		CFrame = CFrame.new(44.5, 5.5, 0),
		Color = Color3.fromRGB(30, 31, 33),
		Material = Enum.Material.Concrete,
		Name = "VestibuleEnd",
	}, folder)
	local goZone = BuildKit.part({
		Size = Vector3.new(3, 10, 10),
		CFrame = CFrame.new(41, 5, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "ThresholdCrossZone",
	}, folder)

	-- the grind (STUB sample, verified in-install): a long low rumble while it rises
	local grind = Instance.new("Sound")
	grind.SoundId = tuning.SURGE_SOUND
	grind.PlaybackSpeed = 0.3
	grind.Volume = 0.4
	grind.Parent = door

	local h = {
		ctx = ctx,
		spawn = Vector3.new(4, 3.5, 0),
		door = door,
		doorClosed = door.CFrame,
		grind = grind,
		openT = 0, -- 0 closed .. 1 open
		opening = false,
		started = false,
		accum = 0,
	}

	goZone.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not h.started then
			h.started = true
			ctx.clear() -- through the first door: the descent begins
		end
	end)

	return h
end

function Beginning.onPlayerEnter(h, ctx, player)
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.lookAt(h.spawn, h.spawn + Vector3.new(1, 0, 0))) -- facing the door, 30 studs ahead
	end
	ctx.send(player, { kind = "objective", text = "THE DOOR IS AHEAD." })
end

function Beginning.update(h, dt)
	h.accum += dt
	if h.accum < h.ctx.tuning.CHECK_INTERVAL then
		return
	end
	local step = h.accum
	h.accum = 0
	if h.openT >= 1 then
		return
	end

	-- start the grind when any player comes near; the door never closes again (the invitation stands)
	if not h.opening then
		for _, p in Players:GetPlayers() do
			local root = p.Character and p.Character.PrimaryPart
			if root and (root.Position - Vector3.new(DOOR_X, 4.3, 0)).Magnitude <= OPEN_DIST then
				h.opening = true
				if h.grind then
					h.grind:Play()
				end
				break
			end
		end
		return
	end

	-- rising into the lintel, heavy and slow
	h.openT = math.min(1, h.openT + step / OPEN_SECONDS)
	h.door.CFrame = h.doorClosed + Vector3.new(0, (h.door.Size.Y - 0.4) * h.openT, 0)
	if h.openT >= 1 and h.grind then
		h.grind:Stop()
	end
end

return Beginning
