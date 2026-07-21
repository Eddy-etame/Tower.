-- Encounter IV's space — the dark arrival where a small warm light finds you, and the one warm-lit exit room
-- where the horror is the architecture: a socket carved to the exact curl of a resting light (this room was
-- BUILT to spend them; it is routine), a great door that only that light can open, and a dark passage yawning
-- beside it. A husk by the socket and a dead lantern by the passage state both prices without a word. The
-- companion orb is the only real light in the dark; everything else is indifferent. Blockout.
local CollectionService = game:GetService("CollectionService")
local BuildKit = require(script.Parent.BuildKit)

local Sanctum = {}

local WALL = BuildKit.WALL
local FLOOR = BuildKit.FLOOR
local CEIL = BuildKit.CEIL
local WARM = Color3.fromRGB(255, 196, 120) -- the companion / the socket: the only warmth in the place
local HUSK = Color3.fromRGB(70, 66, 60)

local H = 12

local function slab(folder, cx, cy, cz, sx, sy, sz, color, mat, name)
	return BuildKit.part({
		Size = Vector3.new(sx, sy, sz),
		CFrame = CFrame.new(cx, cy, cz),
		Color = color or BuildKit.jitter(WALL),
		Material = mat or Enum.Material.Concrete,
		Name = name or "Part",
	}, folder)
end

function Sanctum.build(tuning, parentFolder)
	local folder = Instance.new("Folder")
	folder.Name = "Sanctum"
	local handles = { folder = folder }

	-- ARRIVAL (dark): the companion is the only light here
	slab(folder, -20, 0.1, 0, 40, 0.2, 24, BuildKit.jitter(FLOOR), Enum.Material.Pavement, "ArrivalFloor")
	slab(folder, -20, H + 0.25, 0, 40, 0.5, 26, BuildKit.jitter(CEIL), Enum.Material.Basalt, "ArrivalCeiling")
	slab(folder, -20, H / 2, -12, 40, H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "ArrivalWall")
	slab(folder, -20, H / 2, 12, 40, H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "ArrivalWall")
	slab(folder, -40, H / 2, 0, 1, H, 26, BuildKit.jitter(WALL), Enum.Material.Limestone, "ArrivalBack")
	-- the throat between arrival and the exit room (z -4..4 gap in the x=0 wall) — sz 10 leaves the gap open
	slab(folder, 0, H / 2, -9, 1, H, 10, BuildKit.jitter(WALL), Enum.Material.Limestone, "MidWall")
	slab(folder, 0, H / 2, 9, 1, H, 10, BuildKit.jitter(WALL), Enum.Material.Limestone, "MidWall")

	-- EXIT ROOM (the one warm-lit room; the warmth is the horror)
	slab(folder, 25, 0.1, 0, 50, 0.2, 28, BuildKit.jitter(FLOOR), Enum.Material.Pavement, "ExitFloor")
	slab(folder, 25, H + 0.25, 0, 52, 0.5, 30, BuildKit.jitter(CEIL), Enum.Material.Basalt, "ExitCeiling")
	slab(folder, 25, H / 2, -14, 50, H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitWall")
	-- north wall with the PASSAGE mouth (x 8..16)
	slab(folder, 4, H / 2, 14, 8, H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitWall")
	slab(folder, 33, H / 2, 14, 34, H, 1, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitWall")
	-- east wall with the DOOR gap (z -4..4) — sz 10 leaves the gap the door fills
	slab(folder, 50, H / 2, -9, 1, H, 10, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitWall")
	slab(folder, 50, H / 2, 9, 1, H, 10, BuildKit.jitter(WALL), Enum.Material.Limestone, "ExitWall")

	-- the SOCKET — carved to fit, polished by use — and its husk (taking's full price, foreknown)
	slab(folder, 42, 2, -12.5, 4, 4, 1.6, Color3.fromRGB(60, 54, 48), Enum.Material.Slate, "SocketBlock")
	local socket = BuildKit.part({
		Size = Vector3.new(1.9, 1.9, 1),
		CFrame = CFrame.new(42, 3.1, -11.9),
		Color = WARM,
		Material = Enum.Material.Neon,
		Transparency = 0.35,
		Name = "Socket",
	}, folder)
	local sglow = Instance.new("PointLight")
	sglow.Range = 16
	sglow.Brightness = 1.4
	sglow.Color = WARM
	sglow.Parent = socket
	handles.socket = socket
	handles.socketGlow = sglow
	handles.socketPos = Vector3.new(42, 3.6, -11)
	handles.socketPrompt = Instance.new("ProximityPrompt")
	handles.socketPrompt.ActionText = "HOLD - GIVE THE LIGHT"
	handles.socketPrompt.ObjectText = "THE SOCKET"
	handles.socketPrompt.HoldDuration = tuning.MORAL_SOCKET_HOLD
	handles.socketPrompt.MaxActivationDistance = 8
	handles.socketPrompt.RequiresLineOfSight = false
	handles.socketPrompt.Enabled = false -- armed only once the companion is near (so proximity alone never commits)
	handles.socketPrompt.Parent = socket
	slab(folder, 45.5, 2.3, -12, 1.1, 1.1, 1.1, HUSK, Enum.Material.SmoothPlastic, "Husk") -- the one who came before

	-- the DOOR (path A) — only the light opens it
	local door = BuildKit.part({
		Size = Vector3.new(1.3, 8, 8),
		CFrame = CFrame.new(50, 4, 0),
		Color = Color3.fromRGB(40, 38, 36),
		Material = Enum.Material.CorrodedMetal,
		Name = "ExitDoor",
	}, folder)
	handles.door = door
	handles.doorClosed = door.CFrame
	-- landing beyond the door (path A exit)
	slab(folder, 62, 0.1, 0, 24, 0.2, 18, BuildKit.jitter(FLOOR), nil, "LandingA")
	slab(folder, 62, H + 0.25, 0, 24, 0.5, 20, BuildKit.jitter(CEIL), nil, "LandingACeil")
	slab(folder, 62, H / 2, -9, 24, H, 1, BuildKit.jitter(WALL), nil, "LandingAWall")
	slab(folder, 62, H / 2, 9, 24, H, 1, BuildKit.jitter(WALL), nil, "LandingAWall")
	slab(folder, 74, H / 2, 0, 1, H, 18, BuildKit.jitter(WALL), nil, "LandingAWall")
	handles.doorTouchA = BuildKit.part({
		Size = Vector3.new(3, H, 8),
		CFrame = CFrame.new(54, H / 2, 0),
		Transparency = 1,
		CanCollide = false,
		Name = "SpendExit",
	}, folder)

	-- the dark PASSAGE (path B) — a narrow tunnel north; the shape lives in here, heard never seen
	slab(folder, 12, 0.1, 41, 8, 0.2, 56, Color3.fromRGB(22, 20, 20), Enum.Material.Pavement, "PassageFloor")
	slab(folder, 12, H + 0.25, 41, 10, 0.5, 58, BuildKit.jitter(CEIL), nil, "PassageCeil")
	slab(folder, 7.5, H / 2, 41, 1, H, 56, BuildKit.jitter(WALL), nil, "PassageWall")
	slab(folder, 16.5, H / 2, 41, 1, H, 56, BuildKit.jitter(WALL), nil, "PassageWall")
	slab(folder, 12, H / 2, 80, 16, H, 1, BuildKit.jitter(WALL), nil, "PassageBackstop") -- past the landing, not capping the passage
	-- the dead lantern at the mouth — the dark's full price, foreknown
	slab(folder, 15, 2, 16.5, 1, 2.4, 1, Color3.fromRGB(40, 38, 40), Enum.Material.Metal, "DeadLantern")
	-- far exit (path B) — a sliver of light at the end
	slab(folder, 12, 0.1, 74, 16, 0.2, 12, BuildKit.jitter(FLOOR), nil, "LandingB")
	BuildKit.pool(folder, 12, H - 0.5, 76, Color3.fromRGB(220, 210, 190), 1.4, 22)
	handles.doorTouchB = BuildKit.part({
		Size = Vector3.new(12, H, 3),
		CFrame = CFrame.new(12, H / 2, 71),
		Transparency = 1,
		CanCollide = false,
		Name = "CrossExit",
	}, folder)
	handles.passage = { minX = 7.5, maxX = 16.5, minZ = 14, maxZ = 70 } -- the shape's domain
	handles.passageMouth = Vector3.new(12, 4, 15)

	-- the COMPANION ORB — the only thing that ever responded to you. SPLIT-BRAIN like the Watcher: the SERVER owns
	-- an INVISIBLE logic orb (this — its authoritative position at 10Hz + the diegetic hum); the CLIENT
	-- (Companion.client.lua) renders the visible warm light and follows it at frame rate, so the emotional core
	-- never reads choppy off the server tick. OrbState tells the client how to render it.
	local orb = BuildKit.part({
		Size = Vector3.new(1.3, 1.3, 1.3),
		CFrame = CFrame.new(-30, 4.5, 0),
		Transparency = 1,
		Material = Enum.Material.SmoothPlastic,
		CanCollide = false,
		CanQuery = false,
		Name = "CompanionLogic",
	}, folder)
	orb:SetAttribute("OrbState", "follow") -- follow | gutter | flare | drain | spent
	CollectionService:AddTag(orb, "CompanionOrb")
	handles.orb = orb
	handles.hum = Instance.new("Sound")
	handles.hum.SoundId = tuning.MORAL_HUM_SOUND -- STUB: the diegetic hum (Audio dept records the real creature voice)
	handles.hum.PlaybackSpeed = tuning.MORAL_HUM_SPEED
	handles.hum.Volume = tuning.MORAL_HUM_VOLUME
	handles.hum.Looped = true
	handles.hum.Parent = orb
	handles.hum:Play()

	-- a very dim warm pool over the socket so the exit room reads as "the one warm room" (the rest stays dark)
	BuildKit.pool(folder, 42, H - 0.5, -6, Color3.fromRGB(120, 96, 64), 0.7, 20)

	-- dust in both halves — LightInfluence=1 means the motes are INVISIBLE in the dark arrival and only appear
	-- inside the companion's warm glow: the little light literally reveals the air around you as it walks with you
	BuildKit.ambience(folder, tuning.AMBIENT_SOUND, tuning.SANCTUM_BED_SPEED, tuning.SANCTUM_BED_VOLUME)
	BuildKit.dust(folder, -20, H - 3, 0, 34, 20)
	BuildKit.dust(folder, 25, H - 3, 0, 44, 24)

	handles.spawn = Vector3.new(-34, 3.5, 0)
	folder.Parent = parentFolder or workspace
	return handles
end

function Sanctum.openDoor(handles)
	handles.door.CFrame = handles.doorClosed - Vector3.new(0, handles.door.Size.Y - 0.3, 0)
end

return Sanctum
