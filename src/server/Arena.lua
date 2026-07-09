-- Encounter I's space — a piece of The Threshold, not a box. You enter through a tight, low, black throat
-- (the held breath); it OPENS into a tall room broken by concrete pillars, so you never see all of it at once
-- and the Watcher can be lost between them. It stays dark until powered, and even powered it is sparse pools
-- with shadow between — the flashlight is your real light. FOUR breakers, you need THREE: the deep one sits in
-- the Watcher's ground, so which three (and in what order) is a judgment call, not a checklist (Choice pillar).
-- Blockout on purpose (Bible: prototypes are fast/cheap) but shaped so the ARCHITECTURE itself feels wrong.
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BuildKit = require(script.Parent.BuildKit)
local SliceTuning = require(ReplicatedStorage.Shared.SliceTuning)

local Arena = {}

local WALL = BuildKit.WALL
local FLOOR = BuildKit.FLOOR
local CEIL = BuildKit.CEIL
local TRIM = BuildKit.TRIM
local RED = BuildKit.RED
local GREEN = BuildKit.GREEN
local OFF_BULB = Color3.fromRGB(26, 28, 32) -- a dead fixture: near-black until its breaker gives it power
local ON_BULB = Color3.fromRGB(255, 236, 205)

-- past this (through the door) the player is out of the room and safe — ONE source, shared with Threat.step and
-- the danger vignette (SliceTuning.ROOM_MAX_X), and it IS the east-wall/door x below, so geometry can't drift
-- from gameplay
Arena.ROOM_MAX_X = SliceTuning.ROOM_MAX_X
Arena.REQUIRED = 3 -- breakers needed to open the door (of the FOUR present — the fourth is the choice)

local ROOM_H = 12 -- the room is TALL...
local HALL_H = 7 -- ...and the throat you enter through is LOW: the contrast IS the reveal of scale
local MINX, MAXX, MINZ, MAXZ = 2, SliceTuning.ROOM_MAX_X, -20, 20

-- FOUR breakers; you need three. Three sit on safer ground; the fourth (B4) is deep in the Watcher's corner,
-- a tempting shortcut when another is contested. Each powers a nearby ceiling pool when restored.
local BREAKERS = {
	{ x = 14, z = -15, fx = 16, fz = -12 }, -- near the entrance, safe
	{ x = 34, z = 15, fx = 34, fz = 12 }, -- mid, exposed crossing
	{ x = 57, z = -15, fx = 55, fz = -12 }, -- far, near the door
	{ x = 52, z = 13, fx = 50, fz = 12 }, -- DEEP — beside where the Watcher wakes
}

-- pillars break the long sightline so the room reveals in pieces and the Watcher can be occluded (its freeze
-- needs CLEAR line of sight, enforced in Threat.observedBy — a pillar between you and it means you cannot hold it)
local PILLARS = {
	{ 20, -8 },
	{ 20, 8 },
	{ 34, -8 },
	{ 34, 8 },
	{ 48, -8 },
	{ 48, 8 },
}

local function slab(folder, cx, cy, cz, sx, sy, sz, color, mat, name)
	return BuildKit.part({
		Size = Vector3.new(sx, sy, sz),
		CFrame = CFrame.new(cx, cy, cz),
		Color = color or BuildKit.jitter(WALL),
		Material = mat or Enum.Material.Concrete,
		Name = name or "Part",
	}, folder)
end

function Arena.build(tuning, parentFolder)
	local folder = Instance.new("Folder")
	folder.Name = "Arena"
	local handles = { folder = folder, breakers = {} }

	-- THE THROAT: a tight, low corridor you walk in through (x -18..2, z -4..4). Spawn is inside it, facing in.
	slab(folder, -8, 0.1, 0, 20, 0.2, 8, BuildKit.jitter(FLOOR), Enum.Material.Concrete, "HallFloor")
	slab(folder, -8, HALL_H + 0.25, 0, 20, 0.5, 8, BuildKit.jitter(CEIL), Enum.Material.Concrete, "HallCeiling")
	slab(folder, -8, HALL_H / 2, -4, 20, HALL_H, 1, BuildKit.jitter(WALL), nil, "HallWall")
	slab(folder, -8, HALL_H / 2, 4, 20, HALL_H, 1, BuildKit.jitter(WALL), nil, "HallWall")
	slab(folder, -18, HALL_H / 2, 0, 1, HALL_H, 8, BuildKit.jitter(WALL), nil, "HallCap")

	-- THE ROOM: tall, opening off the throat.
	slab(folder, 33, 0.1, 0, MAXX - MINX, 0.2, MAXZ - MINZ, BuildKit.jitter(FLOOR), Enum.Material.Concrete, "Floor")
	slab(
		folder,
		33,
		ROOM_H + 0.25,
		0,
		MAXX - MINX + 2,
		0.5,
		MAXZ - MINZ + 2,
		BuildKit.jitter(CEIL),
		Enum.Material.Concrete,
		"Ceiling"
	)
	slab(folder, 33, ROOM_H / 2, MINZ, MAXX - MINX, ROOM_H, 1, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, 33, ROOM_H / 2, MAXZ, MAXX - MINX, ROOM_H, 1, BuildKit.jitter(WALL), nil, "Wall")
	-- west wall with the throat gap (z -4..4); segments south and north of the gap, plus a lintel above it
	slab(folder, MINX, ROOM_H / 2, -12, 1, ROOM_H, 16, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, MINX, ROOM_H / 2, 12, 1, ROOM_H, 16, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, MINX, (HALL_H + ROOM_H) / 2, 0, 1, ROOM_H - HALL_H, 8, BuildKit.jitter(WALL), nil, "ThroatLintel")
	-- east wall with the door gap (z -3..3)
	slab(folder, MAXX, ROOM_H / 2, -11.5, 1, ROOM_H, 17, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, MAXX, ROOM_H / 2, 11.5, 1, ROOM_H, 17, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, MAXX, ROOM_H - 2, 0, 1, 4, 6, BuildKit.jitter(WALL), nil, "DoorLintel")
	-- baseboards (a cold trim line so walls don't read as one flat plane)
	slab(folder, 33, 0.55, MINZ + 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")
	slab(folder, 33, 0.55, MAXZ - 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")

	-- pillars (structure that breaks the room into readable fragments)
	for _, p in PILLARS do
		slab(folder, p[1], ROOM_H / 2, p[2], 2.6, ROOM_H, 2.6, BuildKit.jitter(WALL), Enum.Material.Concrete, "Pillar")
	end

	-- environmental story (this place broke; it does not care that you are here): a toppled barricade at the
	-- mouth, two fallen ceiling chunks, a dead hung fixture. Cheap parts, but the room stops being a box.
	local barricade = slab(folder, 6, 1.1, -6, 4, 2.2, 0.4, BuildKit.jitter(TRIM), Enum.Material.WoodPlanks, "Debris")
	barricade.CFrame = CFrame.new(6, 1.1, -6) * CFrame.Angles(0, math.rad(24), math.rad(64))
	local rubble1 = slab(folder, 27, 0.5, -6, 2.4, 1, 2.2, BuildKit.jitter(CEIL), Enum.Material.Concrete, "Debris")
	rubble1.CFrame = CFrame.new(27, 0.5, -6) * CFrame.Angles(math.rad(9), math.rad(30), 0)
	local rubble2 = slab(folder, 41, 0.45, 6, 2, 0.9, 1.8, BuildKit.jitter(CEIL), Enum.Material.Concrete, "Debris")
	rubble2.CFrame = CFrame.new(41, 0.45, 6) * CFrame.Angles(0, math.rad(-18), math.rad(6))
	slab(folder, 33, ROOM_H - 3.4, -3, 0.18, 6.8, 0.18, Color3.fromRGB(20, 20, 22), Enum.Material.Metal, "Cable")
	slab(folder, 33, ROOM_H - 6.9, -3, 1.4, 0.5, 1.4, OFF_BULB, Enum.Material.SmoothPlastic, "DeadFixture")

	-- faint red emergency floor at the throat: never pure black (mobile crushes it), but only the entrance —
	-- the room past it is yours to light. This same light carries the reveal beat.
	local emerg = BuildKit.part({
		Size = Vector3.new(1.2, 0.3, 1.2),
		CFrame = CFrame.new(-2, HALL_H - 0.4, 0),
		Color = Color3.fromRGB(120, 50, 50),
		Material = Enum.Material.Neon,
		Name = "EmergencyLight",
	}, folder)
	local el = Instance.new("PointLight")
	el.Range = 20
	el.Brightness = 0.55
	el.Color = Color3.fromRGB(150, 84, 76)
	el.Parent = emerg

	-- THE REVEAL: a dim, sick swell of light high over the room that lifts it out of black for ~1.4s on entry,
	-- long enough to half-see the tall shape far off, then sinks back to nothing. Uncertainty, not a jump scare
	-- (Bible: "Fear comes from uncertainty. Not jump scares. Not loud noises."). Off until Arena.playReveal.
	local revealBulb = BuildKit.part({
		Size = Vector3.new(0.5, 0.5, 0.5),
		CFrame = CFrame.new(40, ROOM_H - 1, 0),
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		Name = "RevealSource",
	}, folder)
	local rv = Instance.new("PointLight")
	rv.Range = 46
	rv.Brightness = 0
	rv.Color = Color3.fromRGB(150, 158, 170)
	rv.Parent = revealBulb
	handles.revealLight = rv
	handles.revealSound = Instance.new("Sound")
	handles.revealSound.SoundId = tuning.AMBIENT_SOUND
	handles.revealSound.PlaybackSpeed = 0.1 -- a low sub swell (STUB rbxasset; Audio dept records the real sting)
	handles.revealSound.Volume = 0.5
	handles.revealSound.Parent = revealBulb

	-- THE ROOM STARTS DARK. Each breaker powers a nearby ceiling pool — restoring power is lights coming on
	-- section by section, but sparse (Range/Brightness kept low so shadow always survives between pools).
	for i, b in BREAKERS do
		local bulb = BuildKit.part({
			Size = Vector3.new(1.8, 0.3, 1.8),
			CFrame = CFrame.new(b.fx, ROOM_H - 0.5, b.fz),
			Color = OFF_BULB,
			Material = Enum.Material.SmoothPlastic,
			Name = "Fixture" .. i,
		}, folder)
		local sl = Instance.new("SpotLight")
		sl.Face = Enum.NormalId.Bottom
		sl.Angle = 80
		sl.Range = 20
		sl.Brightness = 1.5
		sl.Color = ON_BULB
		sl.Shadows = false
		sl.Enabled = false
		sl.Parent = bulb

		local box = BuildKit.part({
			Size = Vector3.new(2, 2.6, 1.2),
			CFrame = CFrame.new(b.x, 1.5, b.z),
			Color = Color3.fromRGB(70, 72, 76),
			Material = Enum.Material.Metal,
			Name = "Breaker" .. i,
		}, folder)
		local lamp = BuildKit.part({
			Size = Vector3.new(0.7, 0.7, 0.7),
			CFrame = CFrame.new(b.x, 3.1, b.z),
			Color = RED,
			Material = Enum.Material.Neon,
			Name = "BreakerLamp" .. i,
		}, folder)
		local pl = Instance.new("PointLight")
		pl.Range = 9
		pl.Brightness = 0.9
		pl.Color = RED
		pl.Parent = lamp
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Restore"
		prompt.ObjectText = "Breaker " .. i
		prompt.HoldDuration = tuning.LEVER_HOLD
		prompt.MaxActivationDistance = 7
		prompt.RequiresLineOfSight = false
		prompt.Parent = box
		table.insert(handles.breakers, { prompt = prompt, lamp = lamp, active = false, bulb = bulb, light = sl })
	end

	-- the exit door (locked until REQUIRED breakers are restored)
	local door = BuildKit.part({
		Size = Vector3.new(1.3, 8, 6),
		CFrame = CFrame.new(MAXX, 4, 0),
		Color = Color3.fromRGB(44, 42, 40),
		Material = Enum.Material.DiamondPlate,
		Name = "ExitDoor",
	}, folder)
	handles.door = door
	handles.doorClosed = door.CFrame
	local doorLamp = BuildKit.part({
		Size = Vector3.new(0.6, 0.6, 2),
		CFrame = CFrame.new(MAXX - 0.9, 8.4, 0),
		Color = RED,
		Material = Enum.Material.Neon,
		Name = "DoorLamp",
	}, folder)
	local dl = Instance.new("PointLight")
	dl.Range = 12
	dl.Brightness = 1.2
	dl.Color = RED
	dl.Parent = doorLamp
	handles.doorLamp = doorLamp

	-- the SAFE CHAMBER beyond the door: warm, lit, out of the Watcher's reach. Escaping delivers you here.
	slab(folder, 78, 0.1, 0, 30, 0.2, 20, BuildKit.jitter(FLOOR), Enum.Material.Concrete, "SafeFloor")
	slab(folder, 78, ROOM_H + 0.25, 0, 32, 0.5, 22, BuildKit.jitter(CEIL), Enum.Material.Concrete, "SafeCeiling")
	slab(folder, 78, ROOM_H / 2, -10, 30, ROOM_H, 1, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, 78, ROOM_H / 2, 10, 30, ROOM_H, 1, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, 93, ROOM_H / 2, 0, 1, ROOM_H, 22, BuildKit.jitter(WALL), nil, "Wall")
	local safeBulb = BuildKit.part({
		Size = Vector3.new(2, 0.3, 2),
		CFrame = CFrame.new(78, ROOM_H - 0.5, 0),
		Color = ON_BULB,
		Material = Enum.Material.Neon,
		Name = "SafeFixture",
	}, folder)
	local sbl = Instance.new("SpotLight")
	sbl.Face = Enum.NormalId.Bottom
	sbl.Angle = 90
	sbl.Range = 32
	sbl.Brightness = 2.2
	sbl.Color = safeBulb.Color
	sbl.Shadows = false
	sbl.Parent = safeBulb

	handles.doorTouch = BuildKit.part({
		Size = Vector3.new(3, 8, 6),
		CFrame = CFrame.new(MAXX + 4, 4, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "DoorWinZone",
	}, folder)

	-- ambient bed (STUB rbxasset, low + looped): makes SILENCE meaningful, so the Watcher's move sound spikes
	local ambient = Instance.new("Sound")
	ambient.SoundId = tuning.AMBIENT_SOUND
	ambient.PlaybackSpeed = tuning.AMBIENT_SPEED
	ambient.Volume = tuning.AMBIENT_VOLUME
	ambient.Looped = true
	ambient.Parent = folder
	ambient:Play()

	handles.breakerSound = Instance.new("Sound")
	handles.breakerSound.SoundId = tuning.BREAKER_SOUND
	handles.breakerSound.PlaybackSpeed = tuning.BREAKER_SPEED
	handles.breakerSound.Volume = 0.7
	handles.breakerSound.Parent = folder

	handles.escapeSound = Instance.new("Sound")
	handles.escapeSound.SoundId = tuning.ESCAPE_SOUND
	handles.escapeSound.PlaybackSpeed = tuning.ESCAPE_SPEED
	handles.escapeSound.Volume = 0.6
	handles.escapeSound.Parent = safeBulb

	-- the surge sting (STUB): a non-positional room-wide hit when the power dies (parented to the folder = 2D)
	handles.surgeSound = Instance.new("Sound")
	handles.surgeSound.SoundId = tuning.SURGE_SOUND
	handles.surgeSound.PlaybackSpeed = tuning.SURGE_SOUND_SPEED
	handles.surgeSound.Volume = 0.85
	handles.surgeSound.Parent = folder

	handles.entrance = Vector3.new(-14, 3.5, 0) -- inside the throat, facing the room
	handles.safeSpot = Vector3.new(70, 3.5, 0)

	folder.Parent = parentFolder or workspace
	return handles
end

-- the entry reveal beat: swell the room dimly out of black, then let it sink. Called once, on first entry.
function Arena.playReveal(handles)
	local light = handles.revealLight
	if not light then
		return
	end
	if handles.revealSound then
		handles.revealSound:Play()
	end
	local up = TweenService:Create(
		light,
		TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Brightness = 0.85 }
	)
	up.Completed:Connect(function()
		TweenService:Create(light, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Brightness = 0 })
			:Play()
	end)
	up:Play()
end

function Arena.restoreBreaker(handles, index)
	local b = handles.breakers[index]
	if not b or b.active then
		return false
	end
	b.active = true
	b.lamp.Color = GREEN
	b.lamp.PointLight.Color = GREEN
	b.light.Enabled = true
	b.bulb.Color = ON_BULB
	b.bulb.Material = Enum.Material.Neon
	if handles.breakerSound then
		handles.breakerSound.Parent = b.lamp
		handles.breakerSound:Play()
	end
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

-- THE SURGE: restoring the last breaker opens the door — but the lights you fought for BLOW OUT and a sting
-- hits. The room drops to just the dim emergency red + your flashlight, and now it is a sprint (Threat.surge
-- gives the Watcher its lunge). The peak of the encounter, not a quiet win.
function Arena.surge(handles)
	Arena.openDoor(handles)
	for _, b in handles.breakers do
		b.light.Enabled = false
		b.bulb.Color = OFF_BULB
		b.bulb.Material = Enum.Material.SmoothPlastic
		b.prompt.Enabled = false -- power is done; no live "Restore" prompt left dangling during the escape
	end
	if handles.surgeSound then
		handles.surgeSound:Play()
	end
end

function Arena.reset(handles)
	handles.door.CFrame = handles.doorClosed
	handles.doorLamp.Color = RED
	handles.doorLamp.PointLight.Color = RED
	for _, b in handles.breakers do
		b.active = false
		b.lamp.Color = RED
		b.lamp.PointLight.Color = RED
		b.light.Enabled = false
		b.bulb.Color = OFF_BULB
		b.bulb.Material = Enum.Material.SmoothPlastic
		b.prompt.Enabled = true -- a fresh attempt: the breakers are live again
	end
end

return Arena
