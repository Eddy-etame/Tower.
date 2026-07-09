-- Builds the slice world from MapLayout at server start. Blockout on purpose (Bible: fast, simple, cheap) —
-- but readable: explicit per-room tints and lights, human-scale furniture, ceilings so cameras can't spoil
-- the annex, and a spawn yard that funnels the player to the entrance.

local Blockout = {}

-- Cold, desaturated, sickly palette (research: kill the default flat gray Color3(163,162,165) that IS the
-- untouched-blockout signature). Darkness comes from Lighting; albedo stays navigable for mobile.
local WALL_BASE = Color3.fromRGB(94, 97, 92) -- cold concrete
local FLOOR_BASE = Color3.fromRGB(70, 72, 71)
local CEIL_BASE = Color3.fromRGB(48, 50, 52) -- darker than walls so the ceiling looms
local TRIM = Color3.fromRGB(58, 50, 42) -- dark wood baseboard/casing
local WOOD = Color3.fromRGB(96, 80, 60)
local PAPER = Color3.fromRGB(214, 208, 194)
local INK = Color3.fromRGB(34, 32, 28)

-- jitter every architectural surface so no two adjacent parts match: gives light something to grade across
-- and breaks the "one giant flat card" read (research: the single biggest anti-flatness move)
local function jitter(base)
	local function ch(v)
		return math.clamp(v + math.random(-8, 8), 0, 255)
	end
	return Color3.fromRGB(ch(base.R * 255), ch(base.G * 255), ch(base.B * 255))
end

local function makePart(props, parent)
	local part = Instance.new("Part")
	part.Anchored = true
	part.Locked = true
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Material = Enum.Material.Concrete
	part.Color = WALL_BASE
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
		makePart({ Size = size, CFrame = cframe, Color = jitter(WALL_BASE), Name = "Wall" }, folder)
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
			Color = jitter(FLOOR_BASE),
			Material = Enum.Material.Concrete,
			Name = (space.id or "Space") .. "_Floor",
		}, folder)
		-- every space is capped now (the sky is killed): darkness is the canvas, no daylight leaks in
		makePart({
			Size = Vector3.new(width + 2, 0.5, depth + 2),
			CFrame = CFrame.new(centerX, layout.WALL_HEIGHT + 0.25, centerZ),
			Color = jitter(CEIL_BASE),
			Name = (space.id or "Space") .. "_Ceiling",
		}, folder)
		-- baseboard trim along the two long walls: a shadow-catching edge that breaks the flat plane
		for _, side in { space.minZ, space.maxZ } do
			makePart({
				Size = Vector3.new(width, 0.9, 0.5),
				CFrame = CFrame.new(centerX, 0.55, side + (side < centerZ and 0.4 or -0.4)),
				Color = TRIM,
				Material = Enum.Material.WoodPlanks,
				Name = "Baseboard",
			}, folder)
		end

		-- the light POOL: a visible ceiling fixture + a downward cone, dark gaps between spaces (research:
		-- 60-70% of floor left dark; light is the rare, motivated exception, never a uniform fill)
		local fixture = makePart({
			Size = Vector3.new(2, 0.4, 2),
			CFrame = CFrame.new(centerX, layout.WALL_HEIGHT - 0.5, centerZ),
			Color = space.lightColor,
			Material = Enum.Material.Neon,
			Name = (space.id or "Space") .. "_Fixture",
		}, folder)
		local light = Instance.new("SpotLight")
		light.Face = Enum.NormalId.Bottom
		light.Angle = 70
		light.Range = 30
		light.Brightness = space.bright and 3.2 or 2.2
		light.Color = space.lightColor
		light.Shadows = false -- shadow budget goes to the flashlight; fixtures stay cheap for mobile
		light.Parent = fixture
		local flr = Instance.new("PointLight")
		flr.Range = 13
		flr.Brightness = 0.5
		flr.Color = space.lightColor
		flr.Shadows = false
		flr.Parent = fixture
		if not withRelay then
			return nil
		end
		return { def = space, relay = fixture, light = light, baseBrightness = light.Brightness }
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

	-- the pull: warm light spilling from the annex doorway and around both fin corners (findable, not hidden)
	for index, leakDef in layout.leaks do
		local leak = makePart({
			Size = Vector3.new(leakDef.width, 0.12, leakDef.depth),
			CFrame = CFrame.new(leakDef.x, 0.26, leakDef.z),
			Color = Color3.fromRGB(255, 200, 130),
			Material = Enum.Material.Neon,
			Name = "AnnexLeak" .. index,
		}, folder)
		local leakLight = Instance.new("PointLight")
		leakLight.Range = 10
		leakLight.Brightness = 1.4
		leakLight.Color = Color3.fromRGB(255, 200, 130)
		leakLight.Parent = leak
	end

	-- the entrance lamp: the last warm light of the lobby, mounted over the first doorway. When the subject
	-- commits into room one, it dies behind them (Act I — "the room notices you arrive"). Guaranteed, legible.
	local entranceLamp = makePart({
		Size = Vector3.new(2.4, 0.5, 2.4),
		CFrame = CFrame.new(14, layout.WALL_HEIGHT - 0.5, 0),
		Color = Color3.fromRGB(255, 236, 205),
		Material = Enum.Material.Neon,
		Name = "EntranceLamp",
	}, folder)
	local entranceLampLight = Instance.new("PointLight")
	entranceLampLight.Range = 30
	entranceLampLight.Brightness = 2
	entranceLampLight.Color = Color3.fromRGB(255, 236, 205)
	entranceLampLight.Parent = entranceLamp
	local entranceLampSound = Instance.new("Sound")
	entranceLampSound.SoundId = tuning.CLICK_SOUND
	entranceLampSound.PlaybackSpeed = 0.2 -- a low, dull thud as it dies
	entranceLampSound.Volume = 0.7
	entranceLampSound.RollOffMaxDistance = 80
	entranceLampSound.Parent = entranceLamp
	handles.entranceLamp = entranceLamp
	handles.entranceLampLight = entranceLampLight
	handles.entranceLampSound = entranceLampSound

	-- the lobby names the game: the beginning is framed, not implied
	local titleDef = layout.title
	local titlePlate = makePart({
		Size = Vector3.new(0.4, titleDef.height, titleDef.width),
		CFrame = CFrame.lookAt(
			Vector3.new(titleDef.x, titleDef.y, titleDef.z),
			Vector3.new(titleDef.x - 4, titleDef.y, titleDef.z)
		),
		Color = Color3.fromRGB(30, 29, 28),
		Material = Enum.Material.SmoothPlastic,
		Name = "TitlePlate",
	}, folder)
	local titleGui = Instance.new("SurfaceGui")
	titleGui.Face = Enum.NormalId.Front
	titleGui.CanvasSize = Vector2.new(1000, 260)
	titleGui.Parent = titlePlate
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.fromScale(1, 0.62)
	titleLabel.Position = UDim2.fromScale(0, 0.08)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.SpecialElite
	titleLabel.TextColor3 = PAPER
	titleLabel.TextScaled = true
	titleLabel.Text = "PROJECT 001"
	titleLabel.Parent = titleGui
	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Size = UDim2.fromScale(1, 0.26)
	subtitleLabel.Position = UDim2.fromScale(0, 0.7)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Font = Enum.Font.SpecialElite
	subtitleLabel.TextColor3 = Color3.fromRGB(150, 143, 128)
	subtitleLabel.TextScaled = true
	subtitleLabel.Text = "ENCOUNTER ONE — THE SILENT WITNESS"
	subtitleLabel.Parent = titleGui

	-- the ending hall's sealed doors: the rest of the prototype, honestly locked (a stub is labeled a stub)
	handles.lockedDoors = {}
	for _, lockedDef in layout.lockedDoors do
		local lockedDoor = makePart({
			Size = Vector3.new(4, 7, 0.6),
			CFrame = CFrame.new(lockedDef.x, 3.5, lockedDef.z),
			Color = Color3.fromRGB(48, 46, 44),
			Material = Enum.Material.DiamondPlate,
			Name = "LockedDoor_" .. lockedDef.label,
		}, folder)
		local lockedGui = Instance.new("SurfaceGui")
		lockedGui.Face = Enum.NormalId.Front
		lockedGui.CanvasSize = Vector2.new(300, 500)
		lockedGui.Parent = lockedDoor
		local lockedLabel = Instance.new("TextLabel")
		lockedLabel.Size = UDim2.fromScale(1, 0.3)
		lockedLabel.Position = UDim2.fromScale(0, 0.35)
		lockedLabel.BackgroundTransparency = 1
		lockedLabel.Font = Enum.Font.SpecialElite
		lockedLabel.TextColor3 = PAPER
		lockedLabel.TextScaled = true
		lockedLabel.Text = lockedDef.label
		lockedLabel.Parent = lockedGui
		local lockedPrompt = Instance.new("ProximityPrompt")
		lockedPrompt.ActionText = "Open"
		lockedPrompt.ObjectText = "Sealed Door"
		lockedPrompt.MaxActivationDistance = 8
		lockedPrompt.RequiresLineOfSight = false
		lockedPrompt.Parent = lockedDoor
		table.insert(handles.lockedDoors, { prompt = lockedPrompt, label = lockedDef.label })
	end

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

	-- THE FILE WALL: the climax staged in the room itself. You enter the annex and the south wall — the wall
	-- you face — is papered with blank sheets that fill, one by one, with observations about YOU.
	-- The central board types the live line. The room DOES something: it shows you its file on you.
	handles.filePanels = {}
	local panelCount = 6
	local annex = layout.roomById("ANNEX")
	local wallZ = annex.minZ + 0.3 -- just in front of the annex south wall, facing the entering player (+z)
	local startX, endX = 66, 82
	for index = 1, panelCount do
		local px = startX + (endX - startX) * ((index - 1) / (panelCount - 1))
		local sheet = makePart({
			Size = Vector3.new(2.4, 3, 0.06),
			CFrame = CFrame.lookAt(Vector3.new(px, 6.4, wallZ), Vector3.new(px, 6.4, wallZ + 1)),
			Color = PAPER,
			Material = Enum.Material.SmoothPlastic,
			Transparency = 0.15,
			Name = "FilePanel" .. index,
		}, folder)
		local sheetGui = Instance.new("SurfaceGui")
		sheetGui.Face = Enum.NormalId.Front
		sheetGui.CanvasSize = Vector2.new(240, 300)
		sheetGui.Parent = sheet
		local sheetLabel = Instance.new("TextLabel")
		sheetLabel.Size = UDim2.fromScale(0.9, 0.9)
		sheetLabel.Position = UDim2.fromScale(0.05, 0.05)
		sheetLabel.BackgroundTransparency = 1
		sheetLabel.Font = Enum.Font.SpecialElite
		sheetLabel.TextColor3 = INK
		sheetLabel.TextWrapped = true
		sheetLabel.TextYAlignment = Enum.TextYAlignment.Top
		sheetLabel.TextSize = 20
		sheetLabel.Text = ""
		sheetLabel.Parent = sheetGui
		table.insert(handles.filePanels, { part = sheet, label = sheetLabel })
	end

	-- the central board on the desk: the live line writes here, facing the entering player
	local boardDef = layout.board
	handles.board = makePart({
		Size = Vector3.new(boardDef.width, boardDef.height, 0.4),
		CFrame = CFrame.lookAt(
			Vector3.new(boardDef.x, boardDef.y, boardDef.z),
			Vector3.new(boardDef.x, boardDef.y, boardDef.z + 1)
		),
		Color = Color3.fromRGB(24, 23, 22),
		Material = Enum.Material.SmoothPlastic,
		Name = "LiveBoard",
	}, folder)
	local boardGui = Instance.new("SurfaceGui")
	boardGui.Face = Enum.NormalId.Front
	boardGui.CanvasSize = Vector2.new(1200, 550)
	boardGui.Parent = handles.board
	local boardLabel = Instance.new("TextLabel")
	boardLabel.Size = UDim2.fromScale(0.92, 0.92)
	boardLabel.Position = UDim2.fromScale(0.04, 0.04)
	boardLabel.BackgroundTransparency = 1
	boardLabel.Font = Enum.Font.SpecialElite
	boardLabel.TextColor3 = Color3.fromRGB(210, 60, 60)
	boardLabel.TextWrapped = true
	boardLabel.TextYAlignment = Enum.TextYAlignment.Bottom
	boardLabel.TextSize = 40
	boardLabel.Text = ""
	boardLabel.Parent = boardGui
	handles.boardLabel = boardLabel

	-- an overhead lamp over the desk so the file wall reads on entry
	local annexLamp = makePart({
		Size = Vector3.new(2, 0.4, 2),
		CFrame = CFrame.new(boardDef.x, layout.WALL_HEIGHT - 0.6, boardDef.z + 6),
		Color = Color3.fromRGB(255, 220, 180),
		Material = Enum.Material.Neon,
		Name = "AnnexLamp",
	}, folder)
	local annexLampLight = Instance.new("PointLight")
	annexLampLight.Range = 34
	annexLampLight.Brightness = 2.2
	annexLampLight.Color = Color3.fromRGB(255, 214, 170)
	annexLampLight.Parent = annexLamp

	makePart({
		Size = Vector3.new(10, 3, 2.5),
		CFrame = CFrame.new(layout.desk.x, 1.5, layout.desk.z),
		Color = Color3.fromRGB(58, 50, 42),
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

-- Act I: the entrance light dies behind the committed subject.
function Blockout.killEntranceLamp(handles)
	handles.entranceLampLight.Enabled = false
	handles.entranceLamp.Color = Color3.fromRGB(30, 28, 26)
	handles.entranceLamp.Material = Enum.Material.SmoothPlastic
	handles.entranceLampSound:Play()
end

function Blockout.restoreEntranceLamp(handles)
	handles.entranceLampLight.Enabled = true
	handles.entranceLamp.Color = Color3.fromRGB(255, 236, 205)
	handles.entranceLamp.Material = Enum.Material.Neon
end

-- The climax: fill one file panel with a true observation about the subject.
function Blockout.fillPanel(handles, index, text)
	local panel = handles.filePanels[index]
	if panel then
		panel.label.Text = text
		panel.part.Transparency = 0
	end
end

function Blockout.setLiveLine(handles, text)
	handles.boardLabel.Text = text
end

function Blockout.clearFile(handles)
	for _, panel in handles.filePanels do
		panel.label.Text = ""
		panel.part.Transparency = 0.15
	end
	handles.boardLabel.Text = ""
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
