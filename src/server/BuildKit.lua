-- Shared construction kit: one palette, one part helper, one room builder used by every stage, so the whole
-- experience reads as one place. Blockout on purpose (Bible: prototypes are fast, simple, cheap) but cold,
-- jittered, materialled — never flat default gray.
local BuildKit = {}

BuildKit.WALL = Color3.fromRGB(92, 95, 90)
BuildKit.FLOOR = Color3.fromRGB(70, 72, 71)
BuildKit.CEIL = Color3.fromRGB(46, 48, 50)
BuildKit.TRIM = Color3.fromRGB(56, 48, 40)
BuildKit.PAPER = Color3.fromRGB(214, 208, 194)
BuildKit.INK = Color3.fromRGB(34, 32, 28)
BuildKit.RED = Color3.fromRGB(210, 60, 60)
BuildKit.GREEN = Color3.fromRGB(70, 200, 90)

function BuildKit.jitter(base)
	local function ch(v)
		return math.clamp(v + math.random(-8, 8), 0, 255)
	end
	return Color3.fromRGB(ch(base.R * 255), ch(base.G * 255), ch(base.B * 255))
end

function BuildKit.part(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Locked = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.Concrete
	p.Color = BuildKit.WALL
	for k, v in props do
		p[k] = v
	end
	p.Parent = parent
	return p
end

-- a rectangular room with floor, ceiling, four walls, and an optional door gap on the +X (east) wall.
-- returns the door-gap center so the caller can place a door/exit there.
function BuildKit.room(folder, b, opts)
	opts = opts or {}
	local cx, cz = (b.minX + b.maxX) / 2, (b.minZ + b.maxZ) / 2
	local w, d = b.maxX - b.minX, b.maxZ - b.minZ
	local h = opts.height or 11
	BuildKit.part({
		Size = Vector3.new(w, 0.2, d),
		CFrame = CFrame.new(cx, 0.1, cz),
		Color = BuildKit.jitter(BuildKit.FLOOR),
		Name = "Floor",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(w + 2, 0.5, d + 2),
		CFrame = CFrame.new(cx, h + 0.25, cz),
		Color = BuildKit.jitter(BuildKit.CEIL),
		Name = "Ceiling",
	}, folder)
	-- south + north walls
	BuildKit.part({
		Size = Vector3.new(w, h, 1),
		CFrame = CFrame.new(cx, h / 2, b.minZ),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(w, h, 1),
		CFrame = CFrame.new(cx, h / 2, b.maxZ),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	-- west wall (entrance side; solid)
	BuildKit.part({
		Size = Vector3.new(1, h, d),
		CFrame = CFrame.new(b.minX, h / 2, cz),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	-- east wall with a door gap (z -3..3)
	local gapHalf = opts.doorHalf or 3
	BuildKit.part({
		Size = Vector3.new(1, h, d / 2 - gapHalf),
		CFrame = CFrame.new(b.maxX, h / 2, b.minZ + (d / 2 - gapHalf) / 2),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(1, h, d / 2 - gapHalf),
		CFrame = CFrame.new(b.maxX, h / 2, b.maxZ - (d / 2 - gapHalf) / 2),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Wall",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(1, h - gapHalf * 2 - 2, gapHalf * 2),
		CFrame = CFrame.new(b.maxX, h - (h - gapHalf * 2 - 2) / 2, cz),
		Color = BuildKit.jitter(BuildKit.WALL),
		Name = "Lintel",
	}, folder)
	-- baseboards
	BuildKit.part({
		Size = Vector3.new(w, 0.9, 0.5),
		CFrame = CFrame.new(cx, 0.55, b.minZ + 0.4),
		Color = BuildKit.TRIM,
		Material = Enum.Material.WoodPlanks,
		Name = "Baseboard",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(w, 0.9, 0.5),
		CFrame = CFrame.new(cx, 0.55, b.maxZ - 0.4),
		Color = BuildKit.TRIM,
		Material = Enum.Material.WoodPlanks,
		Name = "Baseboard",
	}, folder)
	return { doorCenter = Vector3.new(b.maxX, 4, cz), center = Vector3.new(cx, 3.5, cz) }
end

-- a ceiling light pool (dark gaps between; horror lights as sparse pools, never uniform fill)
function BuildKit.pool(folder, x, y, z, color, brightness, range)
	local bulb = BuildKit.part({
		Size = Vector3.new(1.6, 0.3, 1.6),
		CFrame = CFrame.new(x, y, z),
		Color = color,
		Material = Enum.Material.Neon,
		Name = "Fixture",
	}, folder)
	local sl = Instance.new("SpotLight")
	sl.Face = Enum.NormalId.Bottom
	sl.Angle = 78
	sl.Range = range or 26
	sl.Brightness = brightness or 1.6
	sl.Color = color
	sl.Shadows = false
	sl.Parent = bulb
	return bulb
end

-- a wall sign (SurfaceGui text) — used for stage titles and stub markers.
-- BUG FIXED 2026-07-09: the board was (0.4,4,9) — thin on X — but the SurfaceGui sits on the Front(-Z) face,
-- which was the 0.4x4 EDGE, so the text rendered on a sliver and the player faced a blank black slab (the
-- game's own name was invisible). The board is now (9,4,0.4): the -Z face is the big 9x4 plane, and CFrame.lookAt
-- aims that plane at the reader.
function BuildKit.sign(folder, cframe, text, color)
	local board = BuildKit.part({
		Size = Vector3.new(9, 4, 0.4),
		CFrame = cframe,
		Color = Color3.fromRGB(18, 17, 16),
		Material = Enum.Material.Slate, -- a stone plaque, not plastic — this place is old and does not care
		Name = "Sign",
	}, folder)
	-- a faint emissive frame so the plaque reads as a made thing, not a floating decal (self-lit, dim)
	local frame = BuildKit.part({
		Size = Vector3.new(9.5, 4.5, 0.3),
		CFrame = cframe,
		Color = Color3.fromRGB(92, 86, 74),
		Material = Enum.Material.Metal,
		Name = "SignFrame",
	}, folder)
	frame.CFrame = cframe * CFrame.new(0, 0, 0.08) -- sit the board just proud of its frame
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(900, 400)
	gui.LightInfluence = 0 -- self-lit: signs must stay READABLE in near-black rooms (verified: scene-lit text vanishes)
	gui.Brightness = 0.75 -- ...but dim, so legibility never becomes glare in a horror scene
	gui.Parent = board
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(0.92, 0.92)
	label.Position = UDim2.fromScale(0.04, 0.04)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.SpecialElite
	label.TextColor3 = color or BuildKit.PAPER
	label.TextScaled = true
	label.Text = text
	label.Parent = gui
	return label
end

-- drifting dust motes over a region — the light gets volume, the place reads as long-undisturbed. One emitter,
-- cheap (rate ~20), texture verified present in the installed Roblox content (2026-07-09).
function BuildKit.dust(folder, cx, cy, cz, w, d)
	local anchor = BuildKit.part({
		Size = Vector3.new(w, 1, d),
		CFrame = CFrame.new(cx, cy, cz),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		Name = "DustField",
	}, folder)
	local dust = Instance.new("ParticleEmitter")
	dust.Texture = "rbxasset://textures/particles/smoke_main.dds"
	dust.Color = ColorSequence.new(Color3.fromRGB(150, 150, 158))
	dust.LightEmission = 0.35
	dust.LightInfluence = 1 -- motes shine only where light falls (volume, not glitter)
	dust.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0.86),
		NumberSequenceKeypoint.new(0.85, 0.9),
		NumberSequenceKeypoint.new(1, 1),
	})
	dust.Size = NumberSequence.new(0.14, 0.28)
	dust.Lifetime = NumberRange.new(9, 16)
	dust.Rate = math.clamp((w * d) / 30, 12, 30) -- density scales with area, capped for mobile
	dust.Speed = NumberRange.new(0.2, 0.7)
	dust.SpreadAngle = Vector2.new(180, 180)
	dust.Acceleration = Vector3.new(0.1, -0.35, 0)
	dust.Rotation = NumberRange.new(0, 360)
	dust.RotSpeed = NumberRange.new(-8, 8)
	dust.Parent = anchor
	return anchor
end

-- ARCHITECTURAL LANGUAGE (the anti-basic kit): pilasters + ceiling beams turn a box into a building. The same
-- rhythm sweeps every room so the whole tower reads as one place. Cheap parts, composed shadows.
-- pilasters along both z-walls of a room span, every `step` studs: vertical ribs proud of the wall
function BuildKit.pilasters(folder, minX, maxX, minZ, maxZ, height, step)
	local dark = Color3.fromRGB(38, 39, 42)
	for px = minX + (step or 6), maxX - 2, (step or 6) do
		for _, pz in { minZ + 0.45, maxZ - 0.45 } do
			BuildKit.part({
				Size = Vector3.new(1.1, height, 1.3),
				CFrame = CFrame.new(px, height / 2, pz),
				Color = dark,
				Material = Enum.Material.Slate,
				Name = "Pilaster",
			}, folder)
		end
	end
end

-- ceiling beams across the room every `step` studs: a shadow rhythm overhead instead of one flat lid
function BuildKit.ceilingBeams(folder, minX, maxX, minZ, maxZ, height, step)
	local dark = Color3.fromRGB(30, 31, 34)
	for bx = minX + (step or 6), maxX - 2, (step or 6) do
		BuildKit.part({
			Size = Vector3.new(0.9, 0.8, maxZ - minZ),
			CFrame = CFrame.new(bx, height - 0.4, (minZ + maxZ) / 2),
			Color = dark,
			Material = Enum.Material.Slate,
			Name = "Beam",
		}, folder)
	end
end

-- an interaction pad the player walks onto to proceed (used for stub-encounter "proceed" and transitions)
function BuildKit.pad(folder, position, color)
	return BuildKit.part({
		Size = Vector3.new(6, 0.3, 6),
		CFrame = CFrame.new(position),
		Color = color or BuildKit.GREEN,
		Material = Enum.Material.Neon,
		Name = "Pad",
	}, folder)
end

-- THE GRIND DOOR — the game's engine made physical: a heavy slab in a room's east door gap that grinds UPWARD
-- on its own as a player nears (the Threshold invites; it does not care), with a dark vestibule beyond and a
-- walk-through zone. Used by the Beginning (enter the descent) and the Ending (descend again).
-- Returns a handle for BuildKit.grindDoorUpdate; hook `handle.goZone.Touched` for the advance.
function BuildKit.grindDoor(folder, doorX, grindSoundId)
	local h = {}
	h.door = BuildKit.part({
		Size = Vector3.new(1.2, 8.6, 6),
		CFrame = CFrame.new(doorX, 4.3, 0),
		Color = Color3.fromRGB(42, 40, 38),
		Material = Enum.Material.DiamondPlate,
		Name = "GrindDoor",
	}, folder)
	h.closed = h.door.CFrame
	h.openT = 0
	h.opening = false

	-- the dark vestibule beyond (you step INTO darkness — the commitment)
	BuildKit.part({
		Size = Vector3.new(10, 0.2, 10),
		CFrame = CFrame.new(doorX + 5, 0.1, 0),
		Color = Color3.fromRGB(24, 24, 26),
		Name = "VestibuleFloor",
	}, folder)
	BuildKit.part({
		Size = Vector3.new(10, 0.5, 12),
		CFrame = CFrame.new(doorX + 5, 11.25, 0),
		Color = Color3.fromRGB(20, 22, 24),
		Name = "VestibuleCeiling",
	}, folder)
	for _, vz in { -5.5, 5.5 } do
		BuildKit.part({
			Size = Vector3.new(10, 11, 1),
			CFrame = CFrame.new(doorX + 5, 5.5, vz),
			Color = Color3.fromRGB(30, 31, 33),
			Name = "VestibuleWall",
		}, folder)
	end
	BuildKit.part({
		Size = Vector3.new(1, 11, 12),
		CFrame = CFrame.new(doorX + 10.5, 5.5, 0),
		Color = Color3.fromRGB(30, 31, 33),
		Name = "VestibuleEnd",
	}, folder)
	h.goZone = BuildKit.part({
		Size = Vector3.new(3, 10, 10),
		CFrame = CFrame.new(doorX + 7, 5, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "ThresholdCrossZone",
	}, folder)
	-- the vestibule is dark, never BLACK: one faint strip keeps the forward direction readable inside it
	BuildKit.part({
		Size = Vector3.new(2.2, 0.14, 0.8),
		CFrame = CFrame.new(doorX + 5, 0.3, 0),
		Color = Color3.fromRGB(148, 122, 100),
		Material = Enum.Material.Neon,
		Name = "PathStrip",
	}, folder)

	h.grind = Instance.new("Sound") -- STUB sample (verified in-install); a long low rumble while it rises
	h.grind.SoundId = grindSoundId
	h.grind.PlaybackSpeed = 0.3
	h.grind.Volume = 0.4
	h.grind.Parent = h.door
	return h
end

-- drive a grind door at the stage's 10Hz tick: starts opening when any player is within openDist, rises over
-- openSeconds, never closes again (the invitation stands).
function BuildKit.grindDoorUpdate(h, step, openDist, openSeconds)
	if h.openT >= 1 then
		return
	end
	if not h.opening then
		local Players = game:GetService("Players")
		for _, p in Players:GetPlayers() do
			local root = p.Character and p.Character.PrimaryPart
			if root and (root.Position - h.closed.Position).Magnitude <= openDist then
				h.opening = true
				h.grind:Play()
				break
			end
		end
		return
	end
	h.openT = math.min(1, h.openT + step / openSeconds)
	h.door.CFrame = h.closed + Vector3.new(0, (h.door.Size.Y - 0.4) * h.openT, 0)
	if h.openT >= 1 then
		h.grind:Stop()
	end
end

return BuildKit
