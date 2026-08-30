-- Encounter II's space — a long machine gallery, the Threshold's airway. You enter on a SAFE mezzanine and
-- watch it breathe, then cross it: a line of raised, green-lit beat-MARKS are safe islands; the open scorched
-- floor between them is lethal when the gallery surges. Wall lamps down both sides carry the countdown (they
-- cascade toward the surge's origin, then dark-snap as it fires). Blockout, but shaped so the space reads as a
-- thing with a pulse that ran before you and runs after. All lethality is decided server-side against the marks.
local TweenService = game:GetService("TweenService")
local BuildKit = require(script.Parent.BuildKit)

local Gallery = {}

local WALL = BuildKit.WALL
local FLOOR = BuildKit.FLOOR
local CEIL = BuildKit.CEIL
local SCORCH = Color3.fromRGB(28, 24, 24) -- burnt lanes between the marks — the room's history teaches its rule
local LAMP_CALM = Color3.fromRGB(120, 118, 104)
local LAMP_HOT = Color3.fromRGB(255, 150, 44)
local LAMP_DEAD = Color3.fromRGB(26, 24, 24)
local MARK_SAFE = Color3.fromRGB(70, 220, 110)
local SURGE_RED = Color3.fromRGB(205, 44, 32)

local H = 14
local MINX, MAXX, MINZ, MAXZ = 0, 124, -10, 10
local EMINX = -24 -- entry mezzanine (always safe)
-- widened 20 -> 26 studs (Eddy 2026-08-30: the old spacing left a 5.3x time margin — it could not be failed).
-- 26 studs of exposed floor against a 2.2s safe window is a real commitment, not a stroll.
local MARKS_X = { 14, 40, 66, 92, 118 }
local LAMPS_X = { 10, 30, 50, 70, 90, 112 }
local RIBS_X = { 24, 44, 64, 84, 104 }

local function slab(folder, cx, cy, cz, sx, sy, sz, color, mat, name)
	return BuildKit.part({
		Size = Vector3.new(sx, sy, sz),
		CFrame = CFrame.new(cx, cy, cz),
		Color = color or BuildKit.jitter(WALL),
		Material = mat or Enum.Material.Concrete,
		Name = name or "Part",
	}, folder)
end

function Gallery.build(tuning, parentFolder)
	local folder = Instance.new("Folder")
	folder.Name = "Gallery"
	local handles = { folder = folder, marks = {}, lamps = {} }

	-- entry mezzanine (SAFE) — where you witness a full breath before you commit
	slab(
		folder,
		(EMINX + MINX) / 2,
		0.1,
		0,
		MINX - EMINX,
		0.2,
		MAXZ - MINZ,
		BuildKit.jitter(FLOOR),
		Enum.Material.Pavement,
		"MezzFloor"
	)
	slab(
		folder,
		(EMINX + MINX) / 2,
		H + 0.25,
		0,
		MINX - EMINX,
		0.5,
		MAXZ - MINZ + 2,
		BuildKit.jitter(CEIL),
		Enum.Material.Basalt,
		"MezzCeiling"
	)
	slab(folder, EMINX, H / 2, 0, 1, H, MAXZ - MINZ + 2, BuildKit.jitter(WALL), Enum.Material.Limestone, "MezzBack")
	slab(
		folder,
		(EMINX + MINX) / 2,
		H / 2,
		MINZ,
		MINX - EMINX,
		H,
		1,
		BuildKit.jitter(WALL),
		Enum.Material.Limestone,
		"MezzWall"
	)
	slab(
		folder,
		(EMINX + MINX) / 2,
		H / 2,
		MAXZ,
		MINX - EMINX,
		H,
		1,
		BuildKit.jitter(WALL),
		Enum.Material.Limestone,
		"MezzWall"
	)
	BuildKit.pool(folder, EMINX / 2, H - 0.5, 0, Color3.fromRGB(220, 210, 190), 1.4, 26)
	-- the tower's architectural language: pilasters in the safe mezzanine (your last civilized room),
	-- ceiling beams down the whole gallery (the ribs carry the walls; the beams carry the lid)
	BuildKit.pilasters(folder, EMINX, MINX, MINZ, MAXZ, H, 8)
	BuildKit.ceilingBeams(folder, MINX, MAXX, MINZ, MAXZ, H, 10)

	-- the gallery shell
	slab(
		folder,
		(MINX + MAXX) / 2,
		0.1,
		0,
		MAXX - MINX,
		0.2,
		MAXZ - MINZ,
		SCORCH,
		Enum.Material.Pavement,
		"GalleryFloor"
	)
	slab(
		folder,
		(MINX + MAXX) / 2,
		H + 0.25,
		0,
		MAXX - MINX + 2,
		0.5,
		MAXZ - MINZ + 2,
		BuildKit.jitter(CEIL),
		Enum.Material.Basalt,
		"GalleryCeiling"
	)
	slab(
		folder,
		(MINX + MAXX) / 2,
		H / 2,
		MINZ,
		MAXX - MINX,
		H,
		1,
		BuildKit.jitter(WALL),
		Enum.Material.Limestone,
		"GalleryWall"
	)
	slab(
		folder,
		(MINX + MAXX) / 2,
		H / 2,
		MAXZ,
		MAXX - MINX,
		H,
		1,
		BuildKit.jitter(WALL),
		Enum.Material.Limestone,
		"GalleryWall"
	)

	-- structural ribs (depth + the "airway" read; blockout cover pillars)
	for _, rx in RIBS_X do
		for _, rz in { MINZ + 1.6, MAXZ - 1.6 } do
			slab(folder, rx, H / 2, rz, 2.4, H, 3.2, BuildKit.jitter(WALL), Enum.Material.Limestone, "Rib")
		end
	end

	-- the beat-MARKS: raised, green-lit safe islands. A dark base + a neon top plate so they read as lit platforms
	-- you stand ON. Their light survives the surge (the one thing that stays lit points at safety).
	for i, mx in MARKS_X do
		slab(folder, mx, 0.35, 0, 9.2, 0.5, 9.2, Color3.fromRGB(30, 34, 30), Enum.Material.Metal, "MarkBase" .. i)
		local plate = slab(folder, mx, 0.62, 0, 8, 0.15, 8, MARK_SAFE, Enum.Material.Neon, "MarkPlate" .. i)
		local ml = Instance.new("PointLight")
		ml.Range = 13
		ml.Brightness = 1.1
		ml.Color = MARK_SAFE
		ml.Parent = plate
		table.insert(handles.marks, { pos = Vector3.new(mx, 0.62, 0), plate = plate, light = ml })
	end

	-- wall lamps (the countdown tell): a pair per station down both walls, each with its normalized distance from
	-- the entrance so the cascade can sweep from the FAR origin toward the near end
	for _, lx in LAMPS_X do
		local nx = (lx - MINX) / (MAXX - MINX) -- 0 = near entrance, 1 = far origin
		for _, lz in { MINZ + 0.6, MAXZ - 0.6 } do
			BuildKit.part({
				Size = Vector3.new(0.35, 2.0, 2.0),
				CFrame = CFrame.new(lx, H - 3, (lz > 0) and (lz + 0.28) or (lz - 0.28)),
				Color = Color3.fromRGB(46, 44, 42),
				Material = Enum.Material.CorrodedMetal,
				Name = "LampHousing",
			}, folder)
			local bulb = BuildKit.part({
				Size = Vector3.new(0.6, 1.6, 1.6),
				CFrame = CFrame.new(lx, H - 3, lz),
				Color = LAMP_CALM,
				Material = Enum.Material.Neon,
				Name = "Lamp",
			}, folder)
			local pl = Instance.new("PointLight")
			pl.Range = 20
			pl.Brightness = 1.0
			pl.Color = LAMP_CALM
			pl.Parent = bulb
			table.insert(handles.lamps, { bulb = bulb, light = pl, nx = nx })
		end
	end

	-- THE WITNESS BEAT (the price + the sanctuary, DEMONSTRATED — never told): loose debris that the surge
	-- visibly tears down the open lane every cycle, and a crate resting on the first mark that survives
	-- untouched, both cycles. Watched from the safe mezzanine, this teaches everything before it can kill.
	handles.sweptDebris = BuildKit.part({
		Size = Vector3.new(2.2, 2.2, 3),
		CFrame = CFrame.new(MAXX - 2, 1.2, 5.6), -- in the open lane (clears the marks at z<=4.6 and the ribs)
		Color = Color3.fromRGB(38, 36, 34),
		Material = Enum.Material.Metal,
		CanCollide = false, -- a violent prop, never a physics object the player can ride
		CanQuery = false,
		Name = "SweptDebris",
	}, folder)
	handles.debrisStartX = MAXX - 2
	handles.debrisEndX = MINX + 2
	BuildKit.part({
		Size = Vector3.new(2.4, 2.4, 2.4),
		CFrame = CFrame.new(MARKS_X[1] + 2.4, 1.9, -2.2), -- on the first mark's plate, off-center
		Color = Color3.fromRGB(52, 48, 42),
		Material = Enum.Material.WoodPlanks,
		Name = "SurvivorCrate",
	}, folder)

	-- the surge glow: a gallery-filling translucent red volume, off until the surge fires
	handles.surgeGlow = BuildKit.part({
		Size = Vector3.new(MAXX - MINX - 2, H - 1, MAXZ - MINZ - 1),
		CFrame = CFrame.new((MINX + MAXX) / 2, H / 2, 0),
		Color = SURGE_RED,
		Material = Enum.Material.Neon,
		Transparency = 1,
		CanCollide = false,
		CanQuery = false,
		Name = "SurgeGlow",
	}, folder)

	-- exit passage + safe chamber beyond the far end
	slab(folder, MAXX, H / 2, -6.5, 1, H, 7, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitWall")
	slab(folder, MAXX, H / 2, 6.5, 1, H, 7, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitWall")
	slab(folder, MAXX, H - 2, 0, 1, 4, 6, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitLintel")
	slab(folder, MAXX + 15, 0.1, 0, 30, 0.2, 20, BuildKit.jitter(FLOOR), Enum.Material.Pavement, "SafeFloor")
	slab(folder, MAXX + 15, H + 0.25, 0, 32, 0.5, 22, BuildKit.jitter(CEIL), Enum.Material.Basalt, "SafeCeiling")
	slab(folder, MAXX + 15, H / 2, -10, 30, H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "SafeWall")
	slab(folder, MAXX + 15, H / 2, 10, 30, H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "SafeWall")
	slab(folder, MAXX + 30, H / 2, 0, 1, H, 22, BuildKit.jitter(WALL), Enum.Material.Limestone, "SafeWall")
	BuildKit.pool(folder, MAXX + 15, H - 0.5, 0, Color3.fromRGB(220, 210, 190), 1.6, 30)

	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(MAXX + 29.3, 5, 0), Vector3.new(MAXX + 10, 5, 0)),
		"THE RHYTHM DOES NOT MISS YOU.",
		BuildKit.PAPER
	)
	handles.doorTouch = BuildKit.part({
		Size = Vector3.new(3, H, 12),
		CFrame = CFrame.new(MAXX + 3, H / 2, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "GalleryWinZone",
	}, folder)

	-- (the old anonymous ambient bed was REMOVED — it played on top of the named GALLERY bed: two overlapping
	-- wind loops, louder and phasey. One room, one bed.)

	handles.inhale = Instance.new("Sound")
	handles.inhale.SoundId = tuning.RHYTHM_INHALE_SOUND
	handles.inhale.PlaybackSpeed = tuning.RHYTHM_INHALE_SPEED
	handles.inhale.Volume = 0.5
	handles.inhale.Parent = handles.surgeGlow
	handles.roar = Instance.new("Sound")
	handles.roar.SoundId = tuning.RHYTHM_ROAR_SOUND
	handles.roar.PlaybackSpeed = tuning.RHYTHM_ROAR_SPEED
	handles.roar.Volume = 0.85
	handles.roar.Parent = handles.surgeGlow

	handles.entranceSpawn = Vector3.new(EMINX + 6, 3.5, 0)
	handles.galleryMinX = MINX
	handles.galleryMaxX = MAXX

	-- dust over the gallery lane (shared atmosphere language; the surges churn a long-undisturbed air)
	BuildKit.dust(folder, (MINX + MAXX) / 2, H - 3, 0, MAXX - MINX - 10, MAXZ - MINZ - 2)
	BuildKit.ambience(folder, tuning.AMBIENT_SOUND, tuning.GALLERY_BED_SPEED, tuning.GALLERY_BED_VOLUME)
	BuildKit.conduit(folder, MINX + 2, MAXX - 2, H - 1.6, MINZ + 0.6, 20)
	BuildKit.conduit(folder, MINX + 2, MAXX - 2, H - 1.6, MAXZ - 0.6, 20)

	folder.Parent = parentFolder or workspace
	return handles
end

-- drive the lamp visuals for the current phase. phase = "safe" | "warn" | "surge"; p = 0..1 progress within it.
-- warn: a hot front sweeps from the FAR origin toward the entrance (lamps whose distance-from-origin is inside
-- the advancing front go amber). surge: all wall lamps dark-snap (the marks stay lit — safety is the only light).
function Gallery.setLamps(handles, phase, p)
	if phase == "surge" then
		for _, l in handles.lamps do
			l.bulb.Color = LAMP_DEAD
			l.light.Brightness = 0
		end
		return
	end
	if phase == "warn" then
		for _, l in handles.lamps do
			local frontFromOrigin = p -- 0 -> just the origin lamps, 1 -> all the way to the entrance
			local distFromOrigin = 1 - l.nx
			if distFromOrigin <= frontFromOrigin then
				l.bulb.Color = LAMP_HOT
				l.light.Color = LAMP_HOT
				l.light.Brightness = 2.4
			else
				l.bulb.Color = LAMP_CALM
				l.light.Color = LAMP_CALM
				l.light.Brightness = 1.0
			end
		end
		return
	end
	-- safe
	for _, l in handles.lamps do
		l.bulb.Color = LAMP_CALM
		l.light.Color = LAMP_CALM
		l.light.Brightness = 1.0
	end
end

-- toggle the surge: the red volume + the roar, marks flare a touch brighter (the safe islands assert themselves)
function Gallery.setSurge(handles, on)
	handles.surgeGlow.Transparency = on and 0.55 or 1
	for _, m in handles.marks do
		m.light.Brightness = on and 2.2 or 1.1
	end
	if on then
		if handles.roar then
			handles.roar:Play()
		end
	end
end

function Gallery.playInhale(handles)
	if handles.inhale then
		handles.inhale:Play()
	end
end

-- drive the swept-debris demonstration. During the surge it streaks from the far origin toward the entrance
-- (the same direction the lamp cascade taught); on the calm it resets far — the gallery drags loose junk down
-- the lane every breath. Tumbles as it goes so it reads as violence, not a slide.
function Gallery.updateSweep(handles, phase, p)
	local d = handles.sweptDebris
	if not d then
		return
	end
	if phase == "surge" then
		local x = handles.debrisStartX + (handles.debrisEndX - handles.debrisStartX) * p
		d.CFrame = CFrame.new(x, 1.2 + math.sin(p * 21) * 0.5, 5.6) * CFrame.Angles(p * 9, p * 13, 0)
	elseif phase == "safe" then
		d.CFrame = CFrame.new(handles.debrisStartX, 1.2, 5.6)
	end
end

-- the "GO" pulse: every mark breathes bright once as the safe window opens (the timing, made visible)
function Gallery.pulseMarks(handles)
	for _, m in handles.marks do
		m.light.Brightness = 2.2
		TweenService:Create(m.light, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Brightness = 1.1,
		}):Play()
	end
end

return Gallery
