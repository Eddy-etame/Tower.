-- Encounter III's space — a long, foggy maintenance corridor. It is deliberately plain and repetitive so the
-- EAR (and the dead lamps) become the map, not landmarks. A line of wall lamps down its length is the tell: the
-- ones near the hidden presence lose confidence and dim to almost nothing — a band of dead light that trails
-- behind you IS the thing's position (the muted player's visible twin of the ambient bed ducking). A tape
-- recorder sits midway — the one instrument, incorruptible. Blockout; fog (global Lighting) does the occluding.
local TweenService = game:GetService("TweenService")
local BuildKit = require(script.Parent.BuildKit)

local Corridor = {}

local WALL = BuildKit.WALL
local FLOOR = BuildKit.FLOOR
local CEIL = BuildKit.CEIL
local LAMP_CALM = Color3.fromRGB(158, 154, 138)
local LAMP_DEAD = Color3.fromRGB(30, 30, 34) -- the dead-zone: the light that has lost its nerve

local H = 12
local MINX, MAXX, MINZ, MAXZ = 0, 140, -6, 6
local EMINX = -14 -- entry alcove
local LAMPS_X = { 10, 25, 40, 55, 70, 85, 100, 115, 130 }
local CHAINS_X = { 20, 48, 66, 96, 122 }

local function slab(folder, cx, cy, cz, sx, sy, sz, color, mat, name)
	return BuildKit.part({
		Size = Vector3.new(sx, sy, sz),
		CFrame = CFrame.new(cx, cy, cz),
		Color = color or BuildKit.jitter(WALL),
		Material = mat or Enum.Material.Concrete,
		Name = name or "Part",
	}, folder)
end

function Corridor.build(tuning, parentFolder)
	local folder = Instance.new("Folder")
	folder.Name = "Corridor"
	local handles = { folder = folder, lamps = {} }

	-- entry alcove + the corridor shell (one long tube; fog hides the far end)
	slab(folder, (EMINX + MAXX) / 2, 0.1, 0, MAXX - EMINX, 0.2, MAXZ - MINZ, BuildKit.jitter(FLOOR), nil, "Floor")
	slab(
		folder,
		(EMINX + MAXX) / 2,
		H + 0.25,
		0,
		MAXX - EMINX,
		0.5,
		MAXZ - MINZ + 2,
		BuildKit.jitter(CEIL),
		nil,
		"Ceiling"
	)
	slab(folder, (EMINX + MAXX) / 2, H / 2, MINZ, MAXX - EMINX, H, 1, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, (EMINX + MAXX) / 2, H / 2, MAXZ, MAXX - EMINX, H, 1, BuildKit.jitter(WALL), nil, "Wall")
	slab(folder, EMINX, H / 2, 0, 1, H, MAXZ - MINZ + 2, BuildKit.jitter(WALL), nil, "BackWall")

	-- the tower's architectural language: pilaster ribs + beams turn the tube into a passage that was BUILT
	BuildKit.pilasters(folder, EMINX, MAXX, MINZ, MAXZ, H, 9)
	BuildKit.ceilingBeams(folder, EMINX, MAXX, MINZ, MAXZ, H, 9)

	-- hanging chains — atmosphere (the industrial airway); static blockout
	for _, cx in CHAINS_X do
		slab(folder, cx, H - 3, MAXZ - 1.5, 0.14, 5.6, 0.14, Color3.fromRGB(24, 24, 26), Enum.Material.Metal, "Chain")
	end

	-- the conduit lines the lamps LIVE on (both walls, lamp height): the corridor was WIRED, by someone, once
	BuildKit.conduit(folder, MINX + 2, MAXX - 2, H - 3.5, MINZ + 0.55, 18)
	BuildKit.conduit(folder, MINX + 2, MAXX - 2, H - 3.5, MAXZ - 0.55, 18)
	-- the wall lamps (the tell): one per station, alternating walls, each remembers its calm brightness
	for i, lx in LAMPS_X do
		local lz = (i % 2 == 0) and (MAXZ - 0.6) or (MINZ + 0.6)
		BuildKit.part({
			Size = Vector3.new(1.8, 1.8, 0.35),
			CFrame = CFrame.new(lx, H - 3.5, (lz > 0) and (lz + 0.22) or (lz - 0.22)),
			Color = Color3.fromRGB(46, 44, 42),
			Material = Enum.Material.CorrodedMetal, -- the housing plate behind each lamp
			Name = "LampHousing",
		}, folder)
		local bulb = BuildKit.part({
			Size = Vector3.new(1.4, 1.4, 0.5),
			CFrame = CFrame.new(lx, H - 3.5, lz),
			Color = LAMP_CALM,
			Material = Enum.Material.Neon,
			Name = "Lamp",
		}, folder)
		local pl = Instance.new("PointLight")
		pl.Range = 22
		pl.Brightness = 1.3
		pl.Color = LAMP_CALM
		pl.Shadows = false
		pl.Parent = bulb
		table.insert(handles.lamps, { bulb = bulb, light = pl, x = lx })
	end

	-- the tape recorder station, midway — a table + a prompt. The one instrument.
	slab(folder, 70, 1.5, MAXZ - 1.4, 3, 3, 1.6, Color3.fromRGB(60, 58, 54), Enum.Material.Metal, "TapeTable")
	local recorder = BuildKit.part({
		Size = Vector3.new(1.6, 0.7, 1.1),
		CFrame = CFrame.new(70, 3.2, MAXZ - 1.4),
		Color = Color3.fromRGB(40, 40, 44),
		Material = Enum.Material.SmoothPlastic,
		Name = "Recorder",
	}, folder)
	local reel = BuildKit.part({
		Size = Vector3.new(0.5, 0.5, 0.3),
		CFrame = CFrame.new(70, 3.5, MAXZ - 1.9),
		Color = Color3.fromRGB(180, 60, 40),
		Material = Enum.Material.Neon,
		Name = "Reel",
	}, folder)
	handles.reel = reel
	handles.tapePrompt = Instance.new("ProximityPrompt")
	handles.tapePrompt.ActionText = "HOLD - RECORD"
	handles.tapePrompt.ObjectText = "THE TAPE"
	handles.tapePrompt.HoldDuration = 0.4
	handles.tapePrompt.MaxActivationDistance = 8
	handles.tapePrompt.RequiresLineOfSight = false
	handles.tapePrompt.Parent = recorder

	-- exit + safe chamber
	slab(folder, MAXX, H / 2, -6.5, 1, H, 7, BuildKit.jitter(WALL), nil, "ExitWall")
	slab(folder, MAXX, H / 2, 6.5, 1, H, 7, BuildKit.jitter(WALL), nil, "ExitWall")
	slab(folder, MAXX, H - 2, 0, 1, 4, 6, BuildKit.jitter(WALL), nil, "ExitLintel")
	slab(folder, MAXX + 15, 0.1, 0, 30, 0.2, 20, BuildKit.jitter(FLOOR), nil, "SafeFloor")
	slab(folder, MAXX + 15, H + 0.25, 0, 32, 0.5, 22, BuildKit.jitter(CEIL), nil, "SafeCeiling")
	slab(folder, MAXX + 15, H / 2, -10, 30, H, 1, BuildKit.jitter(WALL), nil, "SafeWall")
	slab(folder, MAXX + 15, H / 2, 10, 30, H, 1, BuildKit.jitter(WALL), nil, "SafeWall")
	slab(folder, MAXX + 30, H / 2, 0, 1, H, 22, BuildKit.jitter(WALL), nil, "SafeWall")
	BuildKit.pool(folder, MAXX + 15, H - 0.5, 0, Color3.fromRGB(220, 210, 190), 1.5, 28)

	handles.doorTouch = BuildKit.part({
		Size = Vector3.new(3, H, 12),
		CFrame = CFrame.new(MAXX + 3, H / 2, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "CorridorWinZone",
	}, folder)

	-- the bed (STUB rbxasset ambient) — the constant the presence SUBTRACTS from (its ducking is the threat channel)
	handles.bed = Instance.new("Sound")
	handles.bed.SoundId = tuning.AMBIENT_SOUND
	handles.bed.PlaybackSpeed = tuning.AMBIENT_SPEED
	handles.bed.Volume = tuning.AMBIENT_VOLUME
	handles.bed.Looped = true
	handles.bed.Parent = folder
	handles.bed:Play()

	handles.entranceSpawn = Vector3.new(EMINX + 6, 3.5, 0)
	handles.corridorMinX = MINX
	handles.corridorMaxX = MAXX
	handles.recordX = 70

	-- dust down the corridor: motes catch each lamp pool, so the dead-lamp band (the presence's tell) reads as
	-- a hole in the drifting light too — the atmosphere itself carries the positional signal
	BuildKit.dust(folder, (MINX + MAXX) / 2, H - 3, 0, MAXX - MINX - 10, MAXZ - MINZ - 1)
	BuildKit.stain(folder, CFrame.new(34, 2.8, MINZ + 0.53), 6, 4.5)
	BuildKit.stain(folder, CFrame.new(88, 3.4, MAXZ - 0.53), 8, 5)
	BuildKit.stain(folder, CFrame.new(60, 0.22, 2) * CFrame.Angles(math.rad(90), 0, 0), 7, 5)

	folder.Parent = parentFolder or workspace
	return handles
end

-- dim the lamps within the silence radius of the presence (the dead-zone band); restore the rest to calm.
-- presenceX = nil clears the effect (all calm).
function Corridor.setSilence(handles, presenceX, radius)
	for _, l in handles.lamps do
		-- a scarred lamp is dead forever (a spent-warning history); never re-light it
		if not l.scarred then
			local dead = presenceX ~= nil and math.abs(l.x - presenceX) <= radius
			if dead ~= l.deadState then -- EDGE-ONLY: the band's movement is a wave of lamps CHANGING, not a repaint
				l.deadState = dead
				if dead then
					-- the lamp GUTTERS OUT as the presence arrives: two failing blinks, then it loses its nerve
					task.spawn(function()
						l.light.Brightness = 0.55
						task.wait(0.07)
						if l.deadState and not l.scarred then
							l.light.Brightness = 1.1
							task.wait(0.05)
						end
						if l.deadState and not l.scarred then
							l.bulb.Color = LAMP_DEAD
							TweenService:Create(l.light, TweenInfo.new(0.3), { Brightness = 0.12 }):Play()
						end
					end)
				else
					-- the presence has passed: the lamp regains its nerve SLOWLY (relief is never instant here)
					l.bulb.Color = LAMP_CALM
					TweenService:Create(l.light, TweenInfo.new(0.9, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Brightness = 1.3,
					}):Play()
				end
			end
		end
	end
end

-- permanently kill one lamp at x (a spent-warning SCAR — the count is readable in the world, never a hidden meter)
function Corridor.scar(handles, nearX)
	local live, best, bestD = 0, nil, nil
	for _, l in handles.lamps do
		if not l.scarred then
			live += 1
			local d = math.abs(l.x - nearX)
			if not bestD or d < bestD then
				bestD, best = d, l
			end
		end
	end
	-- keep at least ~3 lamps live so a retry-heavy run can never scar away the dead-zone band (the core tell)
	if best and live > 3 then
		best.scarred = true
		best.bulb.Color = LAMP_DEAD
		best.bulb.Material = Enum.Material.SmoothPlastic
		best.light.Enabled = false
	end
end

return Corridor
