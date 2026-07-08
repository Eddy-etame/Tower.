-- Builds the slice world from MapLayout at server start. Blockout on purpose (Bible: fast, simple, cheap) —
-- but readable: explicit per-room tints and lights, human-scale furniture, ceilings so cameras can't spoil
-- the annex, and a spawn yard that funnels the player to the entrance.

local Blockout = {}

local WALL_COLOR = Color3.fromRGB(104, 104, 112)
local CEILING_COLOR = Color3.fromRGB(78, 78, 84)
local WOOD = Color3.fromRGB(132, 112, 90)
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
		Size = Vector3.new(3, 1.4, 3),
		CFrame = CFrame.new(def.x, 0.7, def.z),
		Color = WOOD,
		Material = Enum.Material.WoodPlanks,
		Name = "Seat",
	}, model)
	makePart({
		Size = Vector3.new(3, 4, 0.5),
		CFrame = CFrame.new(def.x, 3.2, def.z - 1.25),
		Color = WOOD,
		Material = Enum.Material.WoodPlanks,
		Name = "Back",
	}, model)
	model.PrimaryPart = seat
	model.Parent = folder
	local base = CFrame.lookAt(Vector3.new(def.x, 1.4, def.z), Vector3.new(def.faceX, 1.4, def.faceZ))
	model:PivotTo(base)
	return model, base
end

local function buildPainting(folder, def)
	-- rooms sit south of the north wall, so the painting's front must face -Z (into the room)
	local part = makePart({
		Size = Vector3.new(4.5, 3.2, 0.3),
		CFrame = CFrame.lookAt(Vector3.new(def.x, 5.2, def.z), Vector3.new(def.x, 5.2, def.z - 4)),
		Color = Color3.fromRGB(60, 54, 48),
		Material = Enum.Material.WoodPlanks,
		Name = "Painting_" .. def.room,
	}, folder)
	-- pale canvas as a SurfaceGui so it tilts with the frame (an anchored child part would float behind)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = Vector2.new(450, 320)
	gui.Parent = part
	local canvas = Instance.new("Frame")
	canvas.AnchorPoint = Vector2.new(0.5, 0.5)
	canvas.Position = UDim2.fromScale(0.5, 0.5)
	canvas.Size = UDim2.fromScale(0.82, 0.75)
	canvas.BackgroundColor3 = PAPER
	canvas.BorderSizePixel = 0
	canvas.Parent = gui
	return part, part.CFrame
end

function Blockout.build(layout, tuning)
	local folder = Instance.new("Folder")
	folder.Name = "SliceBlockout"

	for _, wall in layout.walls do
		buildWallSegment(folder, layout, wall)
	end

	local handles = { folder = folder, rooms = {}, watchables = {} }

	local function buildSpace(space, withRelay)
		local centerX = (space.minX + space.maxX) / 2
		local centerZ = (space.minZ + space.maxZ) / 2
		local width = space.maxX - space.minX
		local depth = space.maxZ - space.minZ
		makePart({
			Size = Vector3.new(width, 0.2, depth),
			CFrame = CFrame.new(centerX, 0.1, centerZ),
			Color = space.floorColor,
			Material = Enum.Material.Concrete,
			Name = (space.id or "Space") .. "_Floor",
		}, folder)
		if not space.noCeiling then
			makePart({
				Size = Vector3.new(width + 2, 0.5, depth + 2),
				CFrame = CFrame.new(centerX, layout.WALL_HEIGHT + 0.25, centerZ),
				Color = CEILING_COLOR,
				Name = (space.id or "Space") .. "_Ceiling",
			}, folder)
		end
		local relay = makePart({
			Size = Vector3.new(0.8, 0.8, 0.8),
			CFrame = CFrame.new(centerX, layout.WALL_HEIGHT - 0.7, centerZ),
			Color = CEILING_COLOR,
			Transparency = 0.3,
			Name = (space.id or "Space") .. "_Relay",
		}, folder)
		local light = Instance.new("PointLight")
		light.Range = 42
		light.Brightness = 1.8
		light.Color = space.lightColor
		light.Parent = relay
		if not withRelay then
			return nil
		end
		return { def = space, relay = relay, light = light }
	end

	for _, space in layout.extraSpaces do
		buildSpace(space, false)
	end

	for _, room in layout.rooms do
		local roomHandle = buildSpace(room, true)

		if room.relay then
			local sound = Instance.new("Sound")
			sound.SoundId = tuning.CLICK_SOUND
			sound.PlaybackSpeed = tuning.CLICK_SPEED
			sound.Volume = tuning.CLICK_VOLUME
			sound.RollOffMaxDistance = 70
			sound.Parent = roomHandle.relay
			roomHandle.clickSound = sound

			-- tick plate beside the room's west doorway, eye height: the click's visible twin
			local plate = makePart({
				Size = Vector3.new(3.4, 2.2, 0.3),
				CFrame = CFrame.lookAt(Vector3.new(room.minX + 0.7, 5, 4.4), Vector3.new(room.minX + 6, 5, 4.4)),
				Color = PAPER,
				Material = Enum.Material.SmoothPlastic,
				Name = room.id .. "_TickPlate",
			}, folder)
			local gui = Instance.new("SurfaceGui")
			gui.Face = Enum.NormalId.Front
			gui.CanvasSize = Vector2.new(340, 220)
			gui.Parent = plate
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
		local model, base = buildChair(folder, chairDef)
		table.insert(handles.watchables, {
			kind = "chair",
			room = chairDef.room,
			model = model,
			base = base,
			smudges = 0,
		})
	end
	for _, paintingDef in layout.paintings do
		local part, base = buildPainting(folder, paintingDef)
		table.insert(handles.watchables, {
			kind = "painting",
			room = paintingDef.room,
			part = part,
			base = base,
			smudges = 0,
		})
	end
	for _, tableDef in layout.tables do
		makePart({
			Size = Vector3.new(6, 0.7, 3.5),
			CFrame = CFrame.new(tableDef.x, 3, tableDef.z),
			Color = WOOD,
			Material = Enum.Material.WoodPlanks,
			Name = "TableTop",
		}, folder)
		makePart({
			Size = Vector3.new(5.4, 2.7, 2.9),
			CFrame = CFrame.new(tableDef.x, 1.35, tableDef.z),
			Color = Color3.fromRGB(96, 82, 66),
			Material = Enum.Material.WoodPlanks,
			Name = "TableBase",
		}, folder)
	end

	-- the pull: warm light leaking through the fin gap
	local leak = makePart({
		Size = Vector3.new(layout.leak.width, 0.12, 1.6),
		CFrame = CFrame.new(layout.leak.x, 0.26, layout.leak.z),
		Color = Color3.fromRGB(255, 200, 130),
		Material = Enum.Material.Neon,
		Name = "AnnexLeak",
	}, folder)
	local leakLight = Instance.new("PointLight")
	leakLight.Range = 10
	leakLight.Brightness = 1.4
	leakLight.Color = Color3.fromRGB(255, 200, 130)
	leakLight.Parent = leak

	-- the scratch source (audio played by WitnessService when someone is near)
	local scratch = makePart({
		Size = Vector3.new(0.4, 0.4, 0.4),
		CFrame = CFrame.new(layout.scratchPoint.x, layout.scratchPoint.y, layout.scratchPoint.z),
		Transparency = 1,
		CanCollide = false,
		Name = "ScratchPoint",
	}, folder)
	local scratchSound = Instance.new("Sound")
	scratchSound.SoundId = tuning.CLICK_SOUND
	scratchSound.PlaybackSpeed = tuning.SCRATCH_SPEED
	scratchSound.Volume = tuning.SCRATCH_VOLUME
	scratchSound.RollOffMaxDistance = 36
	scratchSound.Parent = scratch
	handles.scratchPart = scratch
	handles.scratchSound = scratchSound

	-- THE EXIT DOOR: the visible goal. Sealed until the dossier's live line has been read.
	local doorDef = layout.exitDoor
	local doorCenter = Vector3.new(doorDef.x, layout.DOOR_HEIGHT / 2, (doorDef.zFrom + doorDef.zTo) / 2)
	local door = makePart({
		Size = Vector3.new(1.3, layout.DOOR_HEIGHT, doorDef.zTo - doorDef.zFrom),
		CFrame = CFrame.new(doorCenter),
		Color = Color3.fromRGB(48, 46, 44),
		Material = Enum.Material.DiamondPlate,
		Name = "ExitDoor",
	}, folder)
	handles.door = door
	handles.doorClosedCFrame = door.CFrame
	local doorPrompt = Instance.new("ProximityPrompt")
	doorPrompt.ActionText = "Open"
	doorPrompt.ObjectText = "Exit Door"
	doorPrompt.MaxActivationDistance = 9
	doorPrompt.RequiresLineOfSight = false
	doorPrompt.Parent = door
	handles.doorPrompt = doorPrompt
	local doorLamp = makePart({
		Size = Vector3.new(0.6, 0.6, 2),
		CFrame = CFrame.new(doorDef.x - 0.6, layout.DOOR_HEIGHT + 0.8, 0),
		Color = Color3.fromRGB(200, 40, 40),
		Material = Enum.Material.Neon,
		Name = "ExitLamp",
	}, folder)
	local doorLampLight = Instance.new("PointLight")
	doorLampLight.Range = 14
	doorLampLight.Brightness = 1.6
	doorLampLight.Color = doorLamp.Color
	doorLampLight.Parent = doorLamp
	handles.doorLamp = doorLamp
	local doorSound = Instance.new("Sound")
	doorSound.SoundId = tuning.CLICK_SOUND
	doorSound.PlaybackSpeed = 0.25
	doorSound.Volume = 0.8
	doorSound.Parent = door
	handles.doorSound = doorSound

	-- the win pad: stand here, outside, in daylight
	handles.winPad = makePart({
		Size = Vector3.new(4, 0.3, 8),
		CFrame = CFrame.new(layout.winPad.x, 0.25, layout.winPad.z),
		Color = Color3.fromRGB(235, 230, 214),
		Material = Enum.Material.Neon,
		Name = "WinPad",
	}, folder)

	-- readable notes: the session log speaking back
	handles.notes = {}
	for _, noteDef in layout.notes do
		local cframe
		if noteDef.onWall then
			cframe = CFrame.new(noteDef.x, noteDef.y, noteDef.z) * CFrame.Angles(0, math.rad(180), 0)
		else
			cframe = CFrame.new(noteDef.x, noteDef.y, noteDef.z)
				* CFrame.Angles(math.rad(-90), math.rad(noteDef.yaw), 0)
		end
		local paper = makePart({
			Size = Vector3.new(1.7, 2.3, 0.08),
			CFrame = cframe,
			Color = PAPER,
			Material = Enum.Material.SmoothPlastic,
			Name = "Note_" .. noteDef.id,
		}, folder)
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Read"
		prompt.ObjectText = "Note"
		prompt.MaxActivationDistance = 7
		prompt.RequiresLineOfSight = false
		prompt.Parent = paper
		handles.notes[noteDef.id] = { part = paper, prompt = prompt }
	end

	local boardDef = layout.board
	handles.board = makePart({
		Size = Vector3.new(boardDef.width, boardDef.height, 0.4),
		CFrame = CFrame.lookAt(
			Vector3.new(boardDef.x, boardDef.y, boardDef.z),
			Vector3.new(boardDef.x, boardDef.y, boardDef.z + 1)
		),
		Color = PAPER,
		Material = Enum.Material.SmoothPlastic,
		Name = "DossierBoard",
	}, folder)

	makePart({
		Size = Vector3.new(10, 3, 2.5),
		CFrame = CFrame.new(layout.desk.x, 1.5, layout.desk.z),
		Color = Color3.fromRGB(88, 74, 60),
		Material = Enum.Material.WoodPlanks,
		Name = "Desk",
	}, folder)

	handles.resetPad = makePart({
		Size = Vector3.new(3, 0.3, 3),
		CFrame = CFrame.new(layout.resetPad.x, 0.35, layout.resetPad.z),
		Color = Color3.fromRGB(140, 30, 30),
		Material = Enum.Material.Neon,
		Name = "ResetPad",
	}, folder)

	folder.Parent = workspace
	return handles
end

function Blockout.openDoor(handles)
	handles.door.CFrame = handles.doorClosedCFrame - Vector3.new(0, handles.door.Size.Y - 0.4, 0)
	handles.doorPrompt.Enabled = false
	handles.doorLamp.Color = Color3.fromRGB(70, 200, 90)
	handles.doorLamp.PointLight.Color = handles.doorLamp.Color
	handles.doorSound:Play()
end

function Blockout.closeDoor(handles)
	handles.door.CFrame = handles.doorClosedCFrame
	handles.doorPrompt.Enabled = true
	handles.doorLamp.Color = Color3.fromRGB(200, 40, 40)
	handles.doorLamp.PointLight.Color = handles.doorLamp.Color
end

-- A small dark disc after each unobserved move: the second corroborating trace
-- (fairness contract: every change leaves recoverable physical evidence).
function Blockout.addSmudge(handles, watchable)
	if watchable.smudges >= 5 then
		return
	end
	watchable.smudges += 1
	local anchor = watchable.model and watchable.model.PrimaryPart.Position or watchable.part.Position
	makePart({
		Size = Vector3.new(3 + watchable.smudges * 0.3, 0.06, 3 + watchable.smudges * 0.3),
		CFrame = CFrame.new(anchor.X, 0.24, anchor.Z),
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
	for _, watchable in handles.watchables do
		watchable.smudges = 0
	end
end

return Blockout
