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

function Beginning.build(ctx)
	local folder = ctx.folder
	BuildKit.room(folder, { minX = 0, maxX = 34, minZ = -12, maxZ = 12 })
	-- the door must be VISIBLE FROM SPAWN through the fog (verified in-game: at 1.0 the room read as a black
	-- void and the room's entire point — you SEE a door — didn't happen). A cold pool overhead + a lamp on the
	-- door face itself, so the destination reads at 30 studs.
	BuildKit.pool(folder, 29, 10.5, 0, Color3.fromRGB(150, 168, 196), 2.4, 26)
	local doorLamp = BuildKit.part({
		Size = Vector3.new(0.5, 0.5, 2.4),
		CFrame = CFrame.new(32.9, 9.4, 0),
		Color = Color3.fromRGB(170, 188, 214),
		Material = Enum.Material.Neon,
		Name = "DoorLamp",
	}, folder)
	local dl = Instance.new("PointLight")
	dl.Range = 17
	dl.Brightness = 1.8
	dl.Color = doorLamp.Color
	dl.Shadows = false
	dl.Parent = doorLamp
	-- the guide: a slim inset amber line down the floor from the player's feet (x 4) to the door (x 34). Was a
	-- row of garish glowing runway blocks (verified in-game: they dominated the frame and read game-y); now a
	-- refined recessed light-line — dim amber, low and narrow, dense enough to read as one continuous seam. Neon
	-- (cull-proof) carries it; ONE soft pool at the door end anchors the destination.
	for bx = 4, 33, 2 do
		BuildKit.part({
			Size = Vector3.new(1.5, 0.08, 0.35),
			CFrame = CFrame.new(bx, 0.26, 0),
			Color = Color3.fromRGB(196, 150, 96),
			Material = Enum.Material.Neon,
			Name = "PathStrip",
		}, folder)
	end

	-- DUST in the air (atmosphere: the light gets volume, the place breathes). A slow, sparse fall of motes lit by
	-- the room — cheap, but it turns a flat box into a space that has been sitting here, undisturbed, for a long time.
	local dustAnchor = BuildKit.part({
		Size = Vector3.new(30, 1, 20),
		CFrame = CFrame.new(17, 9, 0),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		Name = "DustField",
	}, folder)
	local dust = Instance.new("ParticleEmitter")
	dust.Texture = "rbxasset://textures/particles/smoke_main.dds" -- built-in, verified present; a soft round mote
	dust.Color = ColorSequence.new(Color3.fromRGB(150, 150, 158))
	dust.LightEmission = 0.35
	dust.LightInfluence = 1 -- catches the room light, so motes only shine where light falls (volume)
	dust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0.86),
		NumberSequenceKeypoint.new(0.85, 0.9),
		NumberSequenceKeypoint.new(1, 1),
	})
	dust.Size = NumberSequence.new(0.14, 0.28)
	dust.Lifetime = NumberRange.new(9, 16)
	dust.Rate = 26
	dust.Speed = NumberRange.new(0.2, 0.7)
	dust.SpreadAngle = Vector2.new(180, 180)
	dust.Acceleration = Vector3.new(0.1, -0.35, 0) -- an almost-still drift + a faint settle
	dust.Rotation = NumberRange.new(0, 360)
	dust.RotSpeed = NumberRange.new(-8, 8)
	dust.Parent = dustAnchor
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

	local h = {
		ctx = ctx,
		spawn = Vector3.new(4, 3.5, 0),
		gate = BuildKit.grindDoor(folder, DOOR_X, ctx.tuning.SURGE_SOUND),
		started = false,
		accum = 0,
	}

	h.gate.goZone.Touched:Connect(function(hit)
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
	BuildKit.grindDoorUpdate(h.gate, step, h.ctx.tuning.DOOR_OPEN_DIST, h.ctx.tuning.DOOR_OPEN_SECONDS)
end

return Beginning
