-- The reveal: renders the player's REAL session onto the annex board — route, numbered entries, tallies,
-- timed pauses — and, while they stand reading it, types one more line about them. Every mark is forensically
-- true because it comes from SessionLog; nothing is staged (the whole point of the encounter).

local DossierService = {}

local PAPER = Color3.fromRGB(216, 210, 196)
local INK = Color3.fromRGB(40, 38, 34)
local FAINT = Color3.fromRGB(150, 143, 128)
local HATCH = Color3.fromRGB(196, 188, 172)

local CANVAS = Vector2.new(1200, 600)
local MAP_OFFSET = Vector2.new(36, 90)
local MAP_SIZE = Vector2.new(600, 470)

local board, layout, SessionLog, tuning, onFirstRead
local gui, surface
local states = {} -- [userId] = { generated, liveLineShown, readTime, typing }

function DossierService.init(boardPart, mapLayout, sessionLog, sliceTuning, firstReadCallback)
	board = boardPart
	layout = mapLayout
	SessionLog = sessionLog
	tuning = sliceTuning
	onFirstRead = firstReadCallback

	gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.CanvasSize = CANVAS
	gui.ClipsDescendants = true
	gui.Parent = board

	surface = Instance.new("Frame")
	surface.Size = UDim2.fromScale(1, 1)
	surface.BackgroundColor3 = PAPER
	surface.BorderSizePixel = 0
	surface.Parent = gui
end

local function label(text, x, y, width, height, textSize, color, xAlign)
	local textLabel = Instance.new("TextLabel")
	textLabel.Position = UDim2.fromOffset(x, y)
	textLabel.Size = UDim2.fromOffset(width, height)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.SpecialElite
	textLabel.TextSize = textSize
	textLabel.TextColor3 = color or INK
	textLabel.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	textLabel.Text = text
	textLabel.Parent = surface
	return textLabel
end

local function mapScale()
	local bounds = layout.bounds
	local worldWidth = bounds.maxX - bounds.minX
	local worldDepth = bounds.maxZ - bounds.minZ
	return math.min(MAP_SIZE.X / worldWidth, MAP_SIZE.Y / worldDepth)
end

local function worldToMap(x, z)
	local bounds = layout.bounds
	local scale = mapScale()
	return MAP_OFFSET.X + (x - bounds.minX) * scale, MAP_OFFSET.Y + (bounds.maxZ - z) * scale
end

local function drawRooms()
	for _, room in layout.rooms do
		local px, py = worldToMap(room.minX, room.maxZ)
		local scale = mapScale()
		local frame = Instance.new("Frame")
		frame.Position = UDim2.fromOffset(px, py)
		frame.Size = UDim2.fromOffset((room.maxX - room.minX) * scale, (room.maxZ - room.minZ) * scale)
		frame.BackgroundColor3 = room.relay and PAPER or HATCH -- the silent rooms are marked differently
		frame.BorderSizePixel = 2
		frame.BorderColor3 = INK
		frame.Parent = surface
	end
end

local function drawRoute(log)
	local samples = log.samples
	if #samples < 2 then
		return
	end
	local step = math.max(1, math.ceil(#samples / tuning.MAX_ROUTE_POINTS))
	local previous
	for index = 1, #samples, step do
		local sample = samples[index]
		local px, py = worldToMap(sample.x, sample.z)
		if previous then
			local dx = px - previous.x
			local dy = py - previous.y
			local length = math.sqrt(dx * dx + dy * dy)
			if length > 1 then
				local segment = Instance.new("Frame")
				segment.AnchorPoint = Vector2.new(0.5, 0.5)
				segment.Position = UDim2.fromOffset((px + previous.x) / 2, (py + previous.y) / 2)
				segment.Size = UDim2.fromOffset(length, 2)
				segment.Rotation = math.deg(math.atan2(dy, dx))
				segment.BackgroundColor3 = INK
				segment.BorderSizePixel = 0
				segment.Parent = surface
			end
		end
		previous = { x = px, y = py }
	end
end

local function drawEntryMarks(log)
	for index, entry in log.entries do
		if index > tuning.MAX_ENTRY_MARKS then
			break
		end
		local px, py = worldToMap(entry.x, entry.z)
		label(tostring(entry.n), px - 8, py - 9, 16, 18, 14, FAINT, Enum.TextXAlignment.Center)
	end
end

local function drawColumn(log)
	local x = 680
	local y = 90
	for _, room in layout.rooms do
		if room.relay then
			local count = log.entryCounts[room.id] or 0
			local groups = math.floor(count / 5)
			local tally = string.rep("||||| ", groups) .. string.rep("|", count % 5)
			label(string.format("%s   %s", room.label, tally), x, y, 480, 26, 22)
			y += 34
		end
	end
	y += 18
	local sorted = table.clone(log.pauses)
	table.sort(sorted, function(a, b)
		return a.duration > b.duration
	end)
	for index, pause in sorted do
		if index > tuning.MAX_PAUSE_LINES then
			break
		end
		local room = pause.roomId and layout.roomById(pause.roomId)
		local where = room and room.label or "THE CORRIDOR"
		label(string.format("STOOD %ds — %s", math.floor(pause.duration), where), x, y, 480, 24, 20)
		y += 30
	end
	y += 18
	label(string.format("ROOM ADJUSTMENTS NOTED: %d", log.reorients), x, y, 480, 24, 20)
end

function DossierService.generate(player)
	local state = states[player.UserId] or {}
	states[player.UserId] = state
	if state.typing then
		return -- never rebuild mid-line; the pencil finishes its sentence
	end
	surface:ClearAllChildren()
	state.generated = true
	state.readTime = 0

	local log = SessionLog.get(player)
	label(string.format("SUBJECT %04d", (player.UserId % 8999) + 1000), 36, 18, 500, 44, 38)
	label("OBSERVATION RECORD — ONGOING", 36, 60, 500, 22, 18, FAINT)
	drawRooms()
	drawRoute(log)
	drawEntryMarks(log)
	drawColumn(log)

	state.liveLabel = label("", 36, CANVAS.Y - 44, 1100, 30, 24)
end

-- Called every server tick while the player exists: detects sustained reading and types the live line once.
function DossierService.update(player, character, dt)
	local state = states[player.UserId]
	if not state or not state.generated or state.liveLineShown or state.typing then
		return
	end
	local root = character.PrimaryPart
	if not root then
		return
	end
	local toBoard = board.Position - root.Position
	local facing = toBoard.Magnitude < tuning.READ_RANGE and root.CFrame.LookVector:Dot(toBoard.Unit) > 0.4
	if not facing then
		state.readTime = 0
		return
	end
	state.readTime += dt
	if state.readTime < tuning.READ_DETECT_SECONDS then
		return
	end
	state.typing = true
	task.spawn(function()
		local text = tuning.LIVE_LINE
		for index = 1, #text do
			state.liveLabel.Text = string.sub(text, 1, index)
			task.wait(tuning.LIVE_LINE_CHAR_SECONDS)
		end
		state.liveLineShown = true
		state.typing = false
		if onFirstRead then
			onFirstRead(player)
		end
	end)
end

function DossierService.reset(player)
	states[player.UserId] = nil
	surface:ClearAllChildren()
end

return DossierService
