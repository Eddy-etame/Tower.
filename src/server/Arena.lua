-- Encounter I's space — a piece of The Threshold, not a box. You enter through a tight, low, black throat
-- (the held breath); it OPENS into a tall room. (The concrete-pillar grid was removed for playability — in the
-- dark blockout it read as walls and trapped players; see the note above slab(). It returns with real lighting.)
-- It stays dark until powered, and even powered it is sparse pools with shadow between — the flashlight is your
-- real light. FOUR breakers, you need THREE: the deep one sits in the Watcher's ground, so which three (and in
-- what order) is a judgment call, not a checklist (Choice pillar).
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

-- NOTE (2026-07-09, Eddy playtest): the pillar grid was REMOVED. In the dark blockout — no real lighting, no
-- art — the pillars read as WALLS, and stepping off the center line to reach a breaker put you inside a grid of
-- gray surfaces you could not navigate ("a wall separating two roads... i can't move"). A clean open room is
-- playable NOW; the occlusion/"lost between pillars" layer returns once real lighting + art make a pillar read
-- as a pillar. Simplicity wins (Bible). Reversible — re-add a PILLARS table + the build loop.

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
	slab(folder, -8, 0.1, 0, 20, 0.2, 8, BuildKit.jitter(FLOOR), Enum.Material.Pavement, "HallFloor")
	slab(folder, -8, HALL_H + 0.25, 0, 20, 0.5, 8, BuildKit.jitter(CEIL), Enum.Material.Basalt, "HallCeiling")
	slab(folder, -8, HALL_H / 2, -4, 20, HALL_H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "HallWall")
	slab(folder, -8, HALL_H / 2, 4, 20, HALL_H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "HallWall")
	slab(folder, -18, HALL_H / 2, 0, 1, HALL_H, 8, BuildKit.jitter(WALL), Enum.Material.Limestone, "HallCap")
	-- the throat is NEVER black (verified unplayable): two dim service lights carry you to the room's mouth
	for _, sx in { -13, -4 } do
		BuildKit.pool(folder, sx, HALL_H - 0.4, 0, Color3.fromRGB(150, 118, 96), 1.1, 13)
	end

	-- THE ROOM: tall, opening off the throat.
	slab(folder, 33, 0.1, 0, MAXX - MINX, 0.2, MAXZ - MINZ, BuildKit.jitter(FLOOR), Enum.Material.Pavement, "Floor")
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
	slab(folder, 33, ROOM_H / 2, MINZ, MAXX - MINX, ROOM_H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	slab(folder, 33, ROOM_H / 2, MAXZ, MAXX - MINX, ROOM_H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	-- west wall with the throat gap (z -4..4); segments south and north of the gap, plus a lintel above it
	slab(folder, MINX, ROOM_H / 2, -12, 1, ROOM_H, 16, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	slab(folder, MINX, ROOM_H / 2, 12, 1, ROOM_H, 16, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	slab(
		folder,
		MINX,
		(HALL_H + ROOM_H) / 2,
		0,
		1,
		ROOM_H - HALL_H,
		8,
		BuildKit.jitter(WALL),
		Enum.Material.Limestone,
		"ThroatLintel"
	)
	-- east wall with the door gap (z -3..3)
	slab(folder, MAXX, ROOM_H / 2, -11.5, 1, ROOM_H, 17, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	slab(folder, MAXX, ROOM_H / 2, 11.5, 1, ROOM_H, 17, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	slab(folder, MAXX, ROOM_H - 2, 0, 1, 4, 6, BuildKit.jitter(WALL), Enum.Material.Limestone, "DoorLintel")
	-- baseboards (a cold trim line so walls don't read as one flat plane)
	slab(folder, 33, 0.55, MINZ + 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")
	slab(folder, 33, 0.55, MAXZ - 0.4, MAXX - MINX, 0.9, 0.5, TRIM, Enum.Material.WoodPlanks, "Baseboard")

	-- (the old mid-room pillar GRID stays removed — it trapped players in the dark. The architectural rhythm now
	-- lives at the WALLS: pilasters + ceiling beams, same language as the Beginning, zero footprint in the play
	-- space — the room reads as a building without ever blocking a path.)
	BuildKit.pilasters(folder, MINX, MAXX, MINZ, MAXZ, ROOM_H, 7)
	BuildKit.ceilingBeams(folder, MINX, MAXX, MINZ, MAXZ, ROOM_H, 7)
	-- the exit door monument (matches the Beginning's gate: jambs + lintel framing the way out)
	for _, jz in { -3.4, 3.4 } do
		slab(folder, MAXX - 0.4, 5.5, jz, 2, 11, 1.6, Color3.fromRGB(30, 30, 33), Enum.Material.Slate, "DoorJamb")
	end
	slab(folder, MAXX - 0.4, 10.2, 0, 2.2, 2.4, 8.4, Color3.fromRGB(26, 26, 29), Enum.Material.Slate, "DoorLintel")

	-- THE ROAD: a continuous amber runway from the SPAWN (deep in the throat, x -14) unbroken to the exit door.
	-- It MUST read from the entrance itself (Eddy, v0.17.6: stood at the throat mouth and saw no path — the old
	-- strips began 20 studs in, past the lintel, so from where you enter there was simply no road). Warm amber =
	-- high contrast against the cold room AND distinct from the RED goal beacons; neon so it survives even if
	-- every dynamic light culls; a glow anchor every few markers so it reads as a lit trail at a glance.
	-- refined to the Beginning's language (v0.17.14): a slim recessed amber seam, not glowing runway blocks —
	-- elegant, continuous from the spawn to the exit, still cull-proof neon
	for sx = -14, 61, 2 do
		BuildKit.part({
			Size = Vector3.new(1.5, 0.08, 0.35),
			CFrame = CFrame.new(sx, 0.26, 0),
			Color = Color3.fromRGB(196, 150, 96),
			Material = Enum.Material.Neon,
			Name = "PathStrip",
		}, folder)
	end

	-- dust over the room (shared atmosphere language; the throat stays clear — contrast on arrival)
	BuildKit.dust(folder, 33, 9, 0, 50, 34)
	-- infrastructure + age: conduit runs along both walls feeding the breakers; stains where water found a way
	BuildKit.conduit(folder, MINX + 2, MAXX - 2, ROOM_H - 2.2, MINZ + 0.62, 16)
	BuildKit.conduit(folder, MINX + 2, MAXX - 2, ROOM_H - 2.2, MAXZ - 0.62, 16)
	BuildKit.stain(folder, CFrame.new(20, 3.2, MINZ + 0.58), 7, 5)
	BuildKit.stain(folder, CFrame.new(45, 2.6, MAXZ - 0.58), 9, 4)
	BuildKit.stain(folder, CFrame.new(33, 0.22, -8) * CFrame.Angles(math.rad(90), 0, 0), 8, 6)
	BuildKit.settles(
		folder,
		SliceTuning.SETTLE_SOUND,
		SliceTuning.SETTLE_SPEED,
		SliceTuning.SETTLE_VOLUME,
		SliceTuning.SETTLE_GAP_MIN,
		SliceTuning.SETTLE_GAP_MAX
	)

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
	handles.emergLight = el

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
	-- a low swell (STUB; Audio dept records the real sting). 0.3 not lower: phone speakers cut below ~1kHz,
	-- so a sub-pitched swell would be INAUDIBLE on the ~70% mobile majority (our own research law)
	handles.revealSound.PlaybackSpeed = 0.3
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

		BuildKit.part({
			Size = Vector3.new(2, 2.6, 1.2),
			CFrame = CFrame.new(b.x, 1.5, b.z),
			Color = Color3.fromRGB(64, 62, 60),
			Material = Enum.Material.CorrodedMetal, -- an old panel that has waited a long time
			Name = "Breaker" .. i,
		}, folder)
		-- the LIGHT-POLE: a tall red beacon visible across the whole dark room — THE goal you walk toward, red
		-- until you restore it green (verified: the old 0.7-stud cube was invisible; the goal must be luminous)
		local lamp = BuildKit.part({
			Size = Vector3.new(0.5, 5.6, 0.5),
			CFrame = CFrame.new(b.x, 5.6, b.z),
			Color = RED,
			Material = Enum.Material.Neon,
			Name = "BreakerLamp" .. i,
		}, folder)
		local pl = Instance.new("PointLight")
		pl.Range = 15
		pl.Brightness = 1.6
		pl.Color = RED
		pl.Parent = lamp
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "HOLD - RESTORE POWER"
		prompt.ObjectText = "BREAKER"
		prompt.HoldDuration = tuning.LEVER_HOLD
		prompt.MaxActivationDistance = 9 -- generous in a dark room
		prompt.RequiresLineOfSight = false
		-- anchored to the LAMP (eye height), not the knee-height box: in locked first person a low anchor can sit
		-- below the view when you stand close — the prompt must be where you're already looking
		prompt.Parent = lamp
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
	slab(folder, 78, ROOM_H / 2, -10, 30, ROOM_H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	slab(folder, 78, ROOM_H / 2, 10, 30, ROOM_H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
	slab(folder, 93, ROOM_H / 2, 0, 1, ROOM_H, 22, BuildKit.jitter(WALL), Enum.Material.Limestone, "Wall")
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
		TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
		{ Brightness = 1.2 }
	)
	up.Completed:Connect(function()
		-- HOLD the half-light a beat (long enough to half-see the tall shape far off), then let it sink
		task.delay(0.4, function()
			TweenService
				:Create(light, TweenInfo.new(1.4, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Brightness = 0 })
				:Play()
		end)
	end)
	up:Play()
end

function Arena.restoreBreaker(handles, index)
	local b = handles.breakers[index]
	if not b or b.active then
		return false
	end
	b.active = true
	if handles.breakerSound then
		handles.breakerSound.Parent = b.lamp
		handles.breakerSound:Play()
	end
	-- the lamp SLAMS green with an over-bright pulse that settles (feedback you feel, not a color swap)
	b.lamp.Color = GREEN
	b.lamp.PointLight.Color = GREEN
	b.lamp.PointLight.Brightness = 3.4
	TweenService:Create(b.lamp.PointLight, TweenInfo.new(0.9, Enum.EasingStyle.Quad), { Brightness = 1.6 }):Play()
	-- FLUORESCENT STRIKE: the ceiling fixture stutters to life like a real tube — on, drop, on, hold.
	-- (Restoring power is the room CHANGING, not a switch flipping. Cheap juice, huge feel.)
	task.spawn(function()
		local seq = { 0.06, 0.09, 0.05, 0.12, 0.07 } -- strike pattern: lit/dark alternating, then hold
		for i, dt in seq do
			local lit = (i % 2 == 1)
			b.light.Enabled = lit
			b.bulb.Color = lit and ON_BULB or OFF_BULB
			b.bulb.Material = lit and Enum.Material.Neon or Enum.Material.SmoothPlastic
			task.wait(dt)
		end
		if b.active and not handles.surged then -- the surge may kill the power mid-strike; never re-light a dead room
			b.light.Enabled = true
			b.bulb.Color = ON_BULB
			b.bulb.Material = Enum.Material.Neon
		end
	end)
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
	handles.surged = true
	Arena.openDoor(handles)
	if handles.surgeSound then
		handles.surgeSound:Play()
	end
	-- THE DYING BREATH: every live fixture OVERLOADS (screams bright) for a beat... THEN the cut to black.
	-- Death gets a breath before it — the room's last light is the loudest.
	for _, b in handles.breakers do
		b.prompt.Enabled = false -- no live "Restore" prompt left dangling during the escape
		if b.active then
			b.light.Brightness = b.light.Brightness * SliceTuning.SURGE_FLARE_MULT
		end
	end
	task.delay(SliceTuning.SURGE_FLARE_SECS, function()
		for _, b in handles.breakers do
			b.light.Enabled = false
			b.light.Brightness = 1.5 -- restore the base level for the next attempt
			b.bulb.Color = OFF_BULB
			b.bulb.Material = Enum.Material.SmoothPlastic
		end
	end)
	-- the escape heartbeat: the emergency red + the open-door green BREATHE while the surge state holds
	task.spawn(function()
		local up = true
		while handles.surged do
			local target = up and SliceTuning.SURGE_PULSE_HI or SliceTuning.SURGE_PULSE_LO
			local info =
				TweenInfo.new(SliceTuning.SURGE_PULSE_SECS / 2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			if handles.emergLight then
				TweenService:Create(handles.emergLight, info, { Brightness = target }):Play()
			end
			if handles.doorLamp then
				TweenService:Create(handles.doorLamp.PointLight, info, { Brightness = target + 0.3 }):Play()
			end
			up = not up
			task.wait(SliceTuning.SURGE_PULSE_SECS / 2)
		end
		-- state released (reset): settle both lights back to their resting levels
		if handles.emergLight then
			handles.emergLight.Brightness = 0.55
		end
		if handles.doorLamp then
			handles.doorLamp.PointLight.Brightness = 1.2
		end
	end)
end

function Arena.reset(handles)
	handles.surged = false
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
