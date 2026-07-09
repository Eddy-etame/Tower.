-- Builds the one dark room of the MVP: entrance alcove -> the room -> a lever on the far wall -> the locked
-- exit door. Blockout on purpose (Bible: prototypes are fast, simple, cheap) but lit as pools of dark with a
-- few motivated sources, cold desaturated materials, so it reads as a real place, not a test level.

local Arena = {}

local WALL = Color3.fromRGB(92, 95, 90)
local FLOOR = Color3.fromRGB(68, 70, 69)
local CEIL = Color3.fromRGB(44, 46, 48)
local TRIM = Color3.fromRGB(54, 47, 40)

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

-- room interior: x 2..64, z -20..20, height 11. entrance alcove x -8..2 around the spawn at origin.
local WALL_H = 11
local MINX, MAXX, MINZ, MAXZ = 2, 64, -20, 20

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

	-- floor + ceiling (room + alcove), jittered so no two panels match
	for _, seg in { { -8, 64, -20, 20 } } do
		local x0, x1, z0, z1 = seg[1], seg[2], seg[3], seg[4]
		slab((x0 + x1) / 2, 0.1, (z0 + z1) / 2, x1 - x0, 0.2, z1 - z0, jitter(FLOOR), Enum.Material.Concrete, "Floor")
		slab(
			(x0 + x1) / 2,
			WALL_H + 0.25,
			(z0 + z1) / 2,
			x1 - x0 + 2,
			0.5,
			z1 - z0 + 2,
			jitter(CEIL),
			Enum.Material.Concrete,
			"Ceiling"
		)
	end

	-- room walls (with the exit gap on the east wall, and the alcove mouth on the west)
	slab(MINX - 5, WALL_H / 2, MINZ, 10, WALL_H, 1, jitter(WALL), nil, "Wall") -- alcove south
	slab(MINX - 5, WALL_H / 2, MAXZ, 10, WALL_H, 1, jitter(WALL), nil, "Wall") -- alcove north
	slab(MINX - 8.5, WALL_H / 2, 0, 1, WALL_H, MAXZ - MINZ + 2, jitter(WALL), nil, "Wall") -- alcove west (back)
	slab((MINX + MAXX) / 2, WALL_H / 2, MINZ, MAXX - MINX, WALL_H, 1, jitter(WALL), nil, "Wall") -- room south
	slab((MINX + MAXX) / 2, WALL_H / 2, MAXZ, MAXX - MINX, WALL_H, 1, jitter(WALL), nil, "Wall") -- room north
	-- east wall carries the door gap (z -3..3)
	slab(MAXX, WALL_H / 2, (MINZ - 3) / 2 - 1.5, 1, WALL_H, (MINZ + 3) * -1 + MINZ + 3, jitter(WALL), nil, "Wall")
	slab(MAXX, WALL_H / 2, -11.5, 1, WALL_H, 17, jitter(WALL), nil, "Wall") -- south of door
	slab(MAXX, WALL_H / 2, 11.5, 1, WALL_H, 17, jitter(WALL), nil, "Wall") -- north of door
	slab(MAXX, WALL_H - 1.5, 0, 1, 3, 6, jitter(WALL), nil, "Wall") -- lintel above door
	-- baseboard trim on the two long walls
	slab((MINX + MAXX) / 2, 0.55, MINZ + 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")
	slab((MINX + MAXX) / 2, 0.55, MAXZ - 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")

	-- sparse ceiling light pools: cold, dim, dark gaps between (research: 60-70% of floor left dark)
	local handles = { folder = folder }
	for _, fx in
		{
			{ 14, 0, Color3.fromRGB(210, 222, 240) },
			{ 34, -12, Color3.fromRGB(214, 226, 240) },
			{ 52, 8, Color3.fromRGB(210, 222, 240) },
		}
	do
		local bulb = part({
			Size = Vector3.new(1.6, 0.3, 1.6),
			CFrame = CFrame.new(fx[1], WALL_H - 0.5, fx[2]),
			Color = fx[3],
			Material = Enum.Material.Neon,
			Name = "Fixture",
		}, folder)
		local sl = Instance.new("SpotLight")
		sl.Face = Enum.NormalId.Bottom
		sl.Angle = 70
		sl.Range = 26
		sl.Brightness = 1.4
		sl.Color = fx[3]
		sl.Shadows = false
		sl.Parent = bulb
	end

	-- the LEVER on the far (east) wall's south side: the objective. Throwing it powers the door.
	local lever = part({
		Size = Vector3.new(1.4, 3, 1),
		CFrame = CFrame.new(MAXX - 1, 3, -17),
		Color = Color3.fromRGB(120, 40, 40),
		Material = Enum.Material.Metal,
		Name = "Lever",
	}, folder)
	local leverLamp = part({
		Size = Vector3.new(0.6, 0.6, 0.6),
		CFrame = CFrame.new(MAXX - 1, 5, -17),
		Color = Color3.fromRGB(210, 60, 60),
		Material = Enum.Material.Neon,
		Name = "LeverLamp",
	}, folder)
	local ll = Instance.new("PointLight")
	ll.Range = 12
	ll.Brightness = 1.2
	ll.Color = leverLamp.Color
	ll.Parent = leverLamp
	local leverPrompt = Instance.new("ProximityPrompt")
	leverPrompt.ActionText = "Pull"
	leverPrompt.ObjectText = "Lever"
	leverPrompt.HoldDuration = tuning.LEVER_HOLD
	leverPrompt.MaxActivationDistance = 7
	leverPrompt.RequiresLineOfSight = false
	leverPrompt.Parent = lever
	handles.leverPrompt = leverPrompt
	handles.leverLamp = leverLamp

	-- the EXIT DOOR (east wall gap): the goal. Locked until the lever is thrown.
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
		Color = Color3.fromRGB(210, 60, 60),
		Material = Enum.Material.Neon,
		Name = "DoorLamp",
	}, folder)
	local dl = Instance.new("PointLight")
	dl.Range = 14
	dl.Brightness = 1.4
	dl.Color = doorLamp.Color
	dl.Parent = doorLamp
	handles.doorLamp = doorLamp
	-- exit ledge east of the door: solid ground to escape onto (no void-fall through the open door)
	slab(MAXX + 5, 0.1, 0, 12, 0.2, 12, jitter(FLOOR), Enum.Material.Concrete, "ExitFloor")
	slab(MAXX + 5, WALL_H + 0.25, 0, 12, 0.5, 14, jitter(CEIL), Enum.Material.Concrete, "ExitCeiling")
	slab(MAXX + 5, WALL_H / 2, -6.5, 12, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab(MAXX + 5, WALL_H / 2, 6.5, 12, WALL_H, 1, jitter(WALL), nil, "Wall")
	slab(MAXX + 11, WALL_H / 2, 0, 1, WALL_H, 14, jitter(WALL), nil, "Wall")
	local exitLamp = part({
		Size = Vector3.new(1.4, 0.3, 1.4),
		CFrame = CFrame.new(MAXX + 5, WALL_H - 0.5, 0),
		Color = Color3.fromRGB(214, 226, 240),
		Material = Enum.Material.Neon,
		Name = "ExitFixture",
	}, folder)
	local xl = Instance.new("PointLight")
	xl.Range = 20
	xl.Brightness = 1.2
	xl.Color = exitLamp.Color
	xl.Parent = exitLamp
	handles.doorTouch = part({
		Size = Vector3.new(3, 8, 6),
		CFrame = CFrame.new(MAXX + 4, 4, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "DoorWinZone",
	}, folder)

	-- the entrance pad (respawn point inside the alcove)
	handles.entrance = Vector3.new(-4, 3.5, 0)

	folder.Parent = workspace
	return handles
end

function Arena.throwLever(handles)
	handles.leverLamp.Color = Color3.fromRGB(70, 200, 90)
	handles.leverLamp.PointLight.Color = handles.leverLamp.Color
end

function Arena.openDoor(handles)
	handles.door.CFrame = handles.doorClosed - Vector3.new(0, handles.door.Size.Y - 0.3, 0)
	handles.doorLamp.Color = Color3.fromRGB(70, 200, 90)
	handles.doorLamp.PointLight.Color = handles.doorLamp.Color
end

function Arena.reset(handles)
	handles.door.CFrame = handles.doorClosed
	handles.doorLamp.Color = Color3.fromRGB(210, 60, 60)
	handles.doorLamp.PointLight.Color = handles.doorLamp.Color
	handles.leverLamp.Color = Color3.fromRGB(210, 60, 60)
	handles.leverLamp.PointLight.Color = handles.leverLamp.Color
end

return Arena
