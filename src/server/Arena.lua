-- The room of the MVP: entrance -> a dark room with THREE breakers to restore power -> the door opens ->
-- escape into a safe chamber. Blockout on purpose (Bible: prototypes are fast, simple, cheap) but lit as
-- pools of dark with a few motivated sources, cold desaturated materials, so it reads as a real place.

local Arena = {}

local WALL = Color3.fromRGB(92, 95, 90)
local FLOOR = Color3.fromRGB(68, 70, 69)
local CEIL = Color3.fromRGB(44, 46, 48)
local TRIM = Color3.fromRGB(54, 47, 40)
local RED = Color3.fromRGB(210, 60, 60)
local GREEN = Color3.fromRGB(70, 200, 90)

Arena.ROOM_MAX_X = 64 -- past this (through the door) the player is out of the room and safe

local function jitter(base)
	local function ch(v)
		return math.clamp(v + math.random(-8, 8), 0, 255)
	end
	return Color3.fromRGB(ch(base.R * 255), ch(base.G * 255), ch(base.B * 255))
end

local function part(props, parent)
	local p = Instance.new("Part")
	p.Anchored = true
	p.Locked = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Material = Enum.Material.Concrete
	p.Color = WALL
	for k, v in props do
		p[k] = v
	end
	p.Parent = parent
	return p
end

local WALL_H = 11
local MINX, MAXX, MINZ, MAXZ = 2, 64, -20, 20

-- three breakers scattered so restoring power means crossing the dark room, back turned, again and again
local BREAKERS = {
	{ x = 16, z = -16 },
	{ x = 44, z = 16 },
	{ x = 58, z = -9 },
}

function Arena.build(tuning)
	local folder = Instance.new("Folder")
	folder.Name = "Arena"

	local function slab(cx, cy, cz, sx, sy, sz, color, mat, name)
		part({
			Size = Vector3.new(sx, sy, sz),
			CFrame = CFrame.new(cx, cy, cz),
			Color = color,
			Material = mat or Enum.Material.Concrete,
			Name = name or "Part",
		}, folder)
	end

	-- floor + ceiling (alcove + room)
	slab(28, 0.1, 0, 72, 0.2, 40, jitter(FLOOR), Enum.Material.Concrete, "Floor")
	slab(28, WALL_H + 0.25, 0, 74, 0.5, 42, jitter(CEIL), Enum.Material.Concrete, "Ceiling")

	-- room shell
	slab(MINX - 5, WALL_H / 2, MINZ, 10, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab(MINX - 5, WALL_H / 2, MAXZ, 10, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab(MINX - 8.5, WALL_H / 2, 0, 1, WALL_H, MAXZ - MINZ + 2, jitter(WALL), nil, "Wall")
	slab((MINX + MAXX) / 2, WALL_H / 2, MINZ, MAXX - MINX, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab((MINX + MAXX) / 2, WALL_H / 2, MAXZ, MAXX - MINX, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab(MAXX, WALL_H / 2, -11.5, 1, WALL_H, 17, jitter(WALL), nil, "Wall")
	slab(MAXX, WALL_H / 2, 11.5, 1, WALL_H, 17, jitter(WALL), nil, "Wall")
	slab(MAXX, WALL_H - 1.5, 0, 1, 3, 6, jitter(WALL), nil, "Wall")
	slab((MINX + MAXX) / 2, 0.55, MINZ + 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")
	slab((MINX + MAXX) / 2, 0.55, MAXZ - 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")

	-- sparse cold ceiling pools, dark gaps between
	for _, fx in { { 14, 0 }, { 34, -12 }, { 52, 8 } } do
		local bulb = part({
			Size = Vector3.new(1.6, 0.3, 1.6),
			CFrame = CFrame.new(fx[1], WALL_H - 0.5, fx[2]),
			Color = Color3.fromRGB(212, 224, 240),
			Material = Enum.Material.Neon,
			Name = "Fixture",
		}, folder)
		local sl = Instance.new("SpotLight")
		sl.Face = Enum.NormalId.Bottom
		sl.Angle = 70
		sl.Range = 26
		sl.Brightness = 1.3
		sl.Color = bulb.Color
		sl.Shadows = false
		sl.Parent = bulb
	end

	local handles = { folder = folder, breakers = {} }

	-- the three breakers: wall-mounted boxes with a red indicator + hold-to-throw prompt
	for i, b in BREAKERS do
		local box = part({
			Size = Vector3.new(2, 2.6, 1.2),
			CFrame = CFrame.new(b.x, 3, b.z),
			Color = Color3.fromRGB(70, 72, 76),
			Material = Enum.Material.Metal,
			Name = "Breaker" .. i,
		}, folder)
		local lamp = part({
			Size = Vector3.new(0.7, 0.7, 0.7),
			CFrame = CFrame.new(b.x, 4.8, b.z),
			Color = RED,
			Material = Enum.Material.Neon,
			Name = "BreakerLamp" .. i,
		}, folder)
		local pl = Instance.new("PointLight")
		pl.Range = 10
		pl.Brightness = 1
		pl.Color = RED
		pl.Parent = lamp
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Restore"
		prompt.ObjectText = "Breaker " .. i
		prompt.HoldDuration = tuning.LEVER_HOLD
		prompt.MaxActivationDistance = 7
		prompt.RequiresLineOfSight = false
		prompt.Parent = box
		table.insert(handles.breakers, { prompt = prompt, lamp = lamp, active = false })
	end

	-- the exit door (locked until all breakers are restored)
	local door = part({
		Size = Vector3.new(1.3, 8, 6),
		CFrame = CFrame.new(MAXX, 4, 0),
		Color = Color3.fromRGB(44, 42, 40),
		Material = Enum.Material.DiamondPlate,
		Name = "ExitDoor",
	}, folder)
	handles.door = door
	handles.doorClosed = door.CFrame
	local doorLamp = part({
		Size = Vector3.new(0.6, 0.6, 2),
		CFrame = CFrame.new(MAXX - 0.9, 8.4, 0),
		Color = RED,
		Material = Enum.Material.Neon,
		Name = "DoorLamp",
	}, folder)
	local dl = Instance.new("PointLight")
	dl.Range = 14
	dl.Brightness = 1.4
	dl.Color = RED
	dl.Parent = doorLamp
	handles.doorLamp = doorLamp

	-- the SAFE CHAMBER beyond the door: warm, lit, out of the Watcher's reach. You escape into here.
	slab(78, 0.1, 0, 30, 0.2, 20, jitter(FLOOR), Enum.Material.Concrete, "SafeFloor")
	slab(78, WALL_H + 0.25, 0, 32, 0.5, 22, jitter(CEIL), Enum.Material.Concrete, "SafeCeiling")
	slab(78, WALL_H / 2, -10, 30, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab(78, WALL_H / 2, 10, 30, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab(93, WALL_H / 2, 0, 1, WALL_H, 22, jitter(WALL), nil, "Wall")
	local safeBulb = part({
		Size = Vector3.new(2, 0.3, 2),
		CFrame = CFrame.new(78, WALL_H - 0.5, 0),
		Color = Color3.fromRGB(255, 236, 205),
		Material = Enum.Material.Neon,
		Name = "SafeFixture",
	}, folder)
	local sbl = Instance.new("SpotLight")
	sbl.Face = Enum.NormalId.Bottom
	sbl.Angle = 90
	sbl.Range = 34
	sbl.Brightness = 2.6
	sbl.Color = safeBulb.Color
	sbl.Shadows = false
	sbl.Parent = safeBulb

	handles.doorTouch = part({
		Size = Vector3.new(3, 8, 6),
		CFrame = CFrame.new(MAXX + 4, 4, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "DoorWinZone",
	}, folder)

	-- the REPLAY pad in the safe chamber: step on it to go again (never auto-thrown back into the room)
	handles.replayPad = part({
		Size = Vector3.new(5, 0.3, 5),
		CFrame = CFrame.new(88, 0.35, 0),
		Color = Color3.fromRGB(70, 200, 90),
		Material = Enum.Material.Neon,
		Name = "ReplayPad",
	}, folder)
	local replaySign = part({
		Size = Vector3.new(0.4, 2.4, 6),
		CFrame = CFrame.new(92, 3.5, 0),
		Color = Color3.fromRGB(30, 30, 32),
		Material = Enum.Material.SmoothPlastic,
		Name = "ReplaySign",
	}, folder)
	local rg = Instance.new("SurfaceGui")
	rg.Face = Enum.NormalId.Left
	rg.CanvasSize = Vector2.new(600, 240)
	rg.Parent = replaySign
	local rl = Instance.new("TextLabel")
	rl.Size = UDim2.fromScale(1, 1)
	rl.BackgroundTransparency = 1
	rl.Font = Enum.Font.SpecialElite
	rl.TextColor3 = Color3.fromRGB(214, 226, 240)
	rl.TextScaled = true
	rl.Text = "STEP HERE\nTO GO AGAIN"
	rl.Parent = rg

	handles.entrance = Vector3.new(-4, 3.5, 0)
	handles.safeSpot = Vector3.new(70, 3.5, 0)

	folder.Parent = workspace
	return handles
end

function Arena.restoreBreaker(handles, index)
	local b = handles.breakers[index]
	if not b or b.active then
		return false
	end
	b.active = true
	b.lamp.Color = GREEN
	b.lamp.PointLight.Color = GREEN
	return true
end

function Arena.activeCount(handles)
	local n = 0
	for _, b in handles.breakers do
		if b.active then
			n += 1
		end
	end
	return n
end

function Arena.openDoor(handles)
	handles.door.CFrame = handles.doorClosed - Vector3.new(0, handles.door.Size.Y - 0.3, 0)
	handles.doorLamp.Color = GREEN
	handles.doorLamp.PointLight.Color = GREEN
end

function Arena.reset(handles)
	handles.door.CFrame = handles.doorClosed
	handles.doorLamp.Color = RED
	handles.doorLamp.PointLight.Color = RED
	for _, b in handles.breakers do
		b.active = false
		b.lamp.Color = RED
		b.lamp.PointLight.Color = RED
	end
end

return Arena
