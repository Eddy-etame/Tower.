-- Builds the slice world from MapLayout at server start. Blockout quality on purpose (Bible: prototypes are
-- fast, simple, cheap) — but ceilings and per-room lights exist so third-person cameras can't peek over walls
-- and spoil the annex.

local Blockout = {}

local WALL_COLOR = Color3.fromRGB(72, 72, 78)
local FLOOR_COLOR = Color3.fromRGB(96, 94, 100)
local CEILING_COLOR = Color3.fromRGB(58, 58, 62)
local PAPER = Color3.fromRGB(216, 210, 196)
local INK = Color3.fromRGB(40, 38, 34)

local function makePart(props, parent)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Locked = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.Slate
	part.Color = WALL_COLOR
	for key, value in props do
		part[key] = value
	end
	part.Parent = parent
	return part
end

local function buildWallSegment(folder, layout, wall)
	local height = layout.WALL_HEIGHT
	local function box(from, to, y, boxHeight)
		local length = to - from
		if length <= 0 then
			return
		end
		local size, cframe
		if wall.axis == "x" then
			size = Vector3.new(1, boxHeight, length)
			cframe = CFrame.new(wall.fixed, y, (from + to) / 2)
		else
			size = Vector3.new(length, boxHeight, 1)
			cframe = CFrame.new((from + to) / 2, y, wall.fixed)
		end
		makePart({ Size = size, CFrame = cframe, Name = "Wall" }, folder)
	end
	if wall.gap then
		box(wall.from, wall.gap.from, height / 2, height)
		box(wall.gap.to, wall.to, height / 2, height)
		local lintelHeight = height - layout.DOOR_HEIGHT
		box(wall.gap.from, wall.gap.to, layout.DOOR_HEIGHT + lintelHeight / 2, lintelHeight)
	else
		box(wall.from, wall.to, height / 2, height)
	end
end

local function buildChair(folder, def)
	local model = Instance.new("Model")
	model.Name = "Chair_" .. def.room
	local seat = makePart({
		Size = Vector3.new(2, 1, 2),
		CFrame = CFrame.new(def.x, 0.5, def.z),
		Color = Color3.fromRGB(120, 104, 86),
		Material = Enum.Material.WoodPlanks,
		Name = "Seat",
	}, model)
	makePart({
		Size = Vector3.new(2, 2.4, 0.4),
		CFrame = CFrame.new(def.x, 2.2, def.z - 0.8),
		Color = Color3.fromRGB(120, 104, 86),
		Material = Enum.Material.WoodPlanks,
		Name = "Back",
	}, model)
	model.PrimaryPart = seat
	model.Parent = folder
	model:PivotTo(CFrame.lookAt(Vector3.new(def.x, 1.2, def.z), Vector3.new(def.faceX, 1.2, def.faceZ)))
	return model
end

local function surfaceLabel(part, canvasSize)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = canvasSize
	gui.ClipsDescendants = true
	gui.Parent = part
	return gui
end

function Blockout.build(layout, tuning)
	local folder = Instance.new("Folder")
	folder.Name = "SliceBlockout"

	for _, wall in layout.walls do
		buildWallSegment(folder, layout, wall)
	end

	local handles = { folder = folder, rooms = {}, chairs = {} }

	for _, room in layout.rooms do
		local centerX = (room.minX + room.maxX) / 2
		local centerZ = (room.minZ + room.maxZ) / 2
		local width = room.maxX - room.minX
		local depth = room.maxZ - room.minZ

		makePart({
			Size = Vector3.new(width, 0.2, depth),
			CFrame = CFrame.new(centerX, 0.1, centerZ),
			Color = FLOOR_COLOR,
			Material = Enum.Material.Concrete,
			Name = room.id .. "_Floor",
		}, folder)
		makePart({
			Size = Vector3.new(width + 2, 0.5, depth + 2),
			CFrame = CFrame.new(centerX, layout.WALL_HEIGHT + 0.25, centerZ),
			Color = CEILING_COLOR,
			Name = room.id .. "_Ceiling",
		}, folder)

		local relay = makePart({
			Size = Vector3.new(0.6, 0.6, 0.6),
			CFrame = CFrame.new(centerX, layout.WALL_HEIGHT - 0.6, centerZ),
			Color = CEILING_COLOR,
			Transparency = 0.4,
			Name = room.id .. "_Relay",
		}, folder)
		local light = Instance.new("PointLight")
		light.Range = 34
		light.Brightness = 1.1
		light.Parent = relay

		local roomHandle = { def = room, relay = relay }

		if room.relay then
			local sound = Instance.new("Sound")
			sound.SoundId = tuning.CLICK_SOUND
			sound.PlaybackSpeed = tuning.CLICK_SPEED
			sound.Volume = tuning.CLICK_VOLUME
			sound.RollOffMaxDistance = 60
			sound.Parent = relay
			roomHandle.clickSound = sound

			local plate = makePart({
				Size = Vector3.new(4, 2.5, 0.3),
				CFrame = CFrame.lookAt(Vector3.new(centerX, 5, room.maxZ - 0.35), Vector3.new(centerX, 5, centerZ)),
				Color = PAPER,
				Material = Enum.Material.SmoothPlastic,
				Name = room.id .. "_TickPlate",
			}, folder)
			local gui = surfaceLabel(plate, Vector2.new(400, 250))
			local label = Instance.new("TextLabel")
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Font = Enum.Font.SpecialElite
			label.TextColor3 = INK
			label.TextScaled = true
			label.Text = ""
			label.Parent = gui
			roomHandle.tickLabel = label
		end

		handles.rooms[room.id] = roomHandle
	end

	for _, chairDef in layout.chairs do
		handles.chairs[chairDef.room] = { def = chairDef, model = buildChair(folder, chairDef), smudges = 0 }
	end

	local boardDef = layout.board
	local board = makePart({
		Size = Vector3.new(boardDef.width, boardDef.height, 0.4),
		CFrame = CFrame.lookAt(
			Vector3.new(boardDef.x, boardDef.y, boardDef.z),
			Vector3.new(boardDef.x, boardDef.y, boardDef.z + 1)
		),
		Color = PAPER,
		Material = Enum.Material.SmoothPlastic,
		Name = "DossierBoard",
	}, folder)
	handles.board = board

	makePart({
		Size = Vector3.new(10, 3, 2.5),
		CFrame = CFrame.new(layout.desk.x, 1.5, layout.desk.z),
		Color = Color3.fromRGB(88, 74, 60),
		Material = Enum.Material.WoodPlanks,
		Name = "Desk",
	}, folder)

	local pad = makePart({
		Size = Vector3.new(3, 0.3, 3),
		CFrame = CFrame.new(layout.resetPad.x, 0.35, layout.resetPad.z),
		Color = Color3.fromRGB(140, 30, 30),
		Material = Enum.Material.Neon,
		Name = "ResetPad",
	}, folder)
	handles.resetPad = pad

	folder.Parent = workspace
	return handles
end

-- A small dark disc under a chair after each unobserved rotation: the second corroborating trace
-- (fairness contract: every change leaves recoverable physical evidence).
function Blockout.addSmudge(handles, chairHandle)
	if chairHandle.smudges >= 5 then
		return
	end
	chairHandle.smudges += 1
	local base = chairHandle.model.PrimaryPart.Position
	makePart({
		Size = Vector3.new(2.6 + chairHandle.smudges * 0.3, 0.06, 2.6 + chairHandle.smudges * 0.3),
		CFrame = CFrame.new(base.X, 0.22, base.Z),
		Color = Color3.fromRGB(52, 50, 48),
		Material = Enum.Material.Concrete,
		Transparency = 0.35,
		Name = "Smudge",
	}, handles.folder)
end

function Blockout.clearSmudges(handles)
	for _, child in handles.folder:GetChildren() do
		if child.Name == "Smudge" then
			child:Destroy()
		end
	end
	for _, chairHandle in handles.chairs do
		chairHandle.smudges = 0
	end
end

return Blockout
