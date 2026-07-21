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
	-- THE FIRST FRAME IS A SHOT, NOT A CONTAINER (Eddy, 2026-07-21: front-page games are captivating from the
	-- first second; "basic" is failure). Tall narrow nave proportions, pilaster rhythm down both walls, ceiling
	-- beams for overhead shadow, a MONUMENTAL framed door on a stepped threshold, and a two-tone light story:
	-- cold steel room, warm amber seam pulling the eye to the one warm thing — the way down.
	local H = 15
	BuildKit.room(folder, { minX = 0, maxX = 34, minZ = -9, maxZ = 9 }, { height = H })
	BuildKit.pilasters(folder, 0, 34, -9, 9, H, 5.5)
	BuildKit.ceilingBeams(folder, 0, 34, -9, 9, H, 5.5)

	-- the door monument: two heavy jambs + a deep lintel over the gap, the question carved above; the grind
	-- door itself sits recessed inside this frame so approaching it feels like approaching a gate, not a slab
	for _, jz in { -3.4, 3.4 } do
		BuildKit.part({
			Size = Vector3.new(2.2, 12, 1.6),
			CFrame = CFrame.new(33.6, 6, jz),
			Color = Color3.fromRGB(30, 30, 33),
			Material = Enum.Material.Slate,
			Name = "DoorJamb",
		}, folder)
	end
	BuildKit.part({
		Size = Vector3.new(2.4, 2.6, 8.4),
		CFrame = CFrame.new(33.6, 10.6, 0),
		Color = Color3.fromRGB(26, 26, 29),
		Material = Enum.Material.Slate,
		Name = "DoorLintel",
	}, folder)
	-- two shallow steps up to the threshold (walkable, no jump): the door is ABOVE you; you rise to it
	BuildKit.part({
		Size = Vector3.new(2.6, 0.35, 9),
		CFrame = CFrame.new(31.4, 0.28, 0),
		Color = Color3.fromRGB(52, 53, 56),
		Material = Enum.Material.Slate,
		Name = "Step1",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(1.4, 0.7, 8),
		CFrame = CFrame.new(33, 0.45, 0),
		Color = Color3.fromRGB(46, 47, 50),
		Material = Enum.Material.Slate,
		Name = "Step2",
	}, folder)
	-- the shaft: one cold beam of light falling on the door face from high — the room's single dramatic key
	local shaftSource = BuildKit.part({
		Size = Vector3.new(0.4, 0.4, 0.4),
		CFrame = CFrame.new(29.5, H - 0.6, 0),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		Name = "ShaftSource",
	}, folder)
	local shaft = Instance.new("SpotLight")
	shaft.Face = Enum.NormalId.Bottom
	shaft.Angle = 34
	shaft.Range = 18
	shaft.Brightness = 3.2
	shaft.Color = Color3.fromRGB(168, 186, 214)
	shaft.Shadows = false
	shaft.Parent = shaftSource
	-- a dim cold fill high over the spawn half so the nave reads without stealing the door's drama
	BuildKit.pool(folder, 10, H - 0.5, 0, Color3.fromRGB(120, 132, 156), 0.9, 22)
	-- the guide: a slim inset amber line down the floor from the player's feet (x 4) to the door (x 34). Was a
	-- row of garish glowing runway blocks (verified in-game: they dominated the frame and read game-y); now a
	-- refined recessed light-line — dim amber, low and narrow, dense enough to read as one continuous seam. Neon
	-- (cull-proof) carries it; ONE soft pool at the door end anchors the destination.
	for bx = 4, 29, 2 do
		BuildKit.part({
			Size = Vector3.new(1.5, 0.08, 0.35),
			CFrame = CFrame.new(bx, 0.26, 0),
			Color = Color3.fromRGB(196, 150, 96),
			Material = Enum.Material.Neon,
			Name = "PathStrip",
		}, folder)
	end

	-- dust in the air: the light gets volume, the place reads as long-undisturbed (shared BuildKit.dust)
	BuildKit.dust(folder, 17, 9, 0, 30, 20)
	BuildKit.ambience(folder, ctx.tuning.AMBIENT_SOUND, ctx.tuning.NAVE_BED_SPEED, ctx.tuning.NAVE_BED_VOLUME)
	BuildKit.settles(
		folder,
		ctx.tuning.SETTLE_SOUND,
		ctx.tuning.SETTLE_SPEED,
		ctx.tuning.SETTLE_VOLUME,
		ctx.tuning.SETTLE_GAP_MIN,
		ctx.tuning.SETTLE_GAP_MAX
	)
	-- the name, on the side wall between pilasters — read it or don't; the door is the point
	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(14, 6.5, -8.3), Vector3.new(14, 6.5, 0)),
		"THE THRESHOLD",
		BuildKit.PAPER
	)
	-- the question, carved high above the door monument — you look UP to it
	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(33.5, 13.1, 0), Vector3.new(0, 12.4, 0)),
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
