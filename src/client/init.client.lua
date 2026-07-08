-- Project 001 MVP client: objective line, note popups, the end card, and the fullscreen RECORD document —
-- each player renders their OWN dossier from server payload (multiplayer-correct by construction).
-- The client renders and requests; the server decides — this script only LISTENS (one-directional remote).
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))
local tuning = require(ReplicatedStorage.Shared.SliceTuning)

print(
	("[Project001][Client] booted — v%d.%d.%d (%s)"):format(
		version.major,
		version.minor,
		version.patch,
		version.stage
	)
)

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "SliceUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local INK_LIGHT = Color3.fromRGB(230, 224, 210)
local PAPER = Color3.fromRGB(216, 210, 196)
local INK = Color3.fromRGB(40, 38, 34)
local FAINT = Color3.fromRGB(150, 143, 128)
local HATCH = Color3.fromRGB(196, 188, 172)

local objective = Instance.new("TextLabel")
objective.AnchorPoint = Vector2.new(0.5, 0)
objective.Position = UDim2.new(0.5, 0, 0, 14)
objective.Size = UDim2.new(0.9, 0, 0, 30)
objective.BackgroundTransparency = 1
objective.Font = Enum.Font.SpecialElite
objective.TextSize = 22
objective.TextColor3 = INK_LIGHT
objective.TextStrokeTransparency = 0.4
objective.Text = ""
objective.Parent = gui

local noteFrame = Instance.new("Frame")
noteFrame.AnchorPoint = Vector2.new(0.5, 0.5)
noteFrame.Position = UDim2.fromScale(0.5, 0.62)
noteFrame.Size = UDim2.new(0.7, 0, 0, 110)
noteFrame.BackgroundColor3 = Color3.fromRGB(18, 17, 16)
noteFrame.BackgroundTransparency = 0.25
noteFrame.BorderSizePixel = 0
noteFrame.Visible = false
noteFrame.Parent = gui

local noteText = Instance.new("TextLabel")
noteText.Size = UDim2.fromScale(1, 1)
noteText.BackgroundTransparency = 1
noteText.Font = Enum.Font.SpecialElite
noteText.TextSize = 24
noteText.TextColor3 = INK_LIGHT
noteText.TextWrapped = true
noteText.Text = ""
noteText.Parent = noteFrame

local endCard = Instance.new("Frame")
endCard.Size = UDim2.fromScale(1, 1)
endCard.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
endCard.BackgroundTransparency = 0.1
endCard.BorderSizePixel = 0
endCard.Visible = false
endCard.Parent = gui

local endLines = {}
for index = 1, 3 do
	local line = Instance.new("TextLabel")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Position = UDim2.fromScale(0.5, 0.34 + index * 0.09)
	line.Size = UDim2.new(0.9, 0, 0, 40)
	line.BackgroundTransparency = 1
	line.Font = Enum.Font.SpecialElite
	line.TextSize = index == 1 and 42 or 26
	line.TextColor3 = INK_LIGHT
	line.Text = ""
	line.Parent = endCard
	endLines[index] = line
end

-- the RECORD document: a paper sheet over a darkened screen
local recordDim = Instance.new("Frame")
recordDim.Size = UDim2.fromScale(1, 1)
recordDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
recordDim.BackgroundTransparency = 0.35
recordDim.BorderSizePixel = 0
recordDim.Visible = false
recordDim.Parent = gui

local recordSheet = Instance.new("Frame")
recordSheet.AnchorPoint = Vector2.new(0.5, 0.5)
recordSheet.Position = UDim2.fromScale(0.5, 0.5)
recordSheet.Size = UDim2.fromScale(0.86, 0.86)
recordSheet.BackgroundColor3 = PAPER
recordSheet.BorderSizePixel = 0
recordSheet.Parent = recordDim

local function sheetLabel(text, xScale, yScale, wScale, hScale, color, xAlign)
	local textLabel = Instance.new("TextLabel")
	textLabel.Position = UDim2.fromScale(xScale, yScale)
	textLabel.Size = UDim2.fromScale(wScale, hScale)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.SpecialElite
	textLabel.TextScaled = true
	textLabel.TextColor3 = color or INK
	textLabel.TextXAlignment = xAlign or Enum.TextXAlignment.Left
	textLabel.Text = text
	textLabel.Parent = recordSheet
	return textLabel
end

local function renderRecord(data)
	recordSheet:ClearAllChildren()
	sheetLabel(string.format("SUBJECT %04d", data.subject), 0.03, 0.02, 0.5, 0.08)
	sheetLabel("OBSERVATION RECORD — ONGOING", 0.03, 0.1, 0.5, 0.045, FAINT)

	-- map area: left half, true pixel aspect from world bounds (fractions would stretch the plan)
	local bounds = data.bounds
	local worldWidth = bounds.maxX - bounds.minX
	local worldDepth = bounds.maxZ - bounds.minZ
	local sheetSize = recordSheet.AbsoluteSize
	local mapOriginX = sheetSize.X * 0.03
	local mapOriginY = sheetSize.Y * 0.2
	local scale = math.min((sheetSize.X * 0.5) / worldWidth, (sheetSize.Y * 0.72) / worldDepth)
	local function toMap(x, z)
		return mapOriginX + (x - bounds.minX) * scale, mapOriginY + (bounds.maxZ - z) * scale
	end

	for _, room in data.rooms do
		local px, py = toMap(room.minX, room.maxZ)
		local roomFrame = Instance.new("Frame")
		roomFrame.Position = UDim2.fromOffset(px, py)
		roomFrame.Size = UDim2.fromOffset((room.maxX - room.minX) * scale, (room.maxZ - room.minZ) * scale)
		roomFrame.BackgroundColor3 = room.relay and PAPER or HATCH
		roomFrame.BorderSizePixel = 2
		roomFrame.BorderColor3 = INK
		roomFrame.Parent = recordSheet
	end

	local previous
	for _, point in data.route do
		local px, py = toMap(point.x, point.z)
		if previous then
			local dot = Instance.new("Frame")
			dot.AnchorPoint = Vector2.new(0.5, 0.5)
			dot.Position = UDim2.fromOffset((px + previous.x) / 2, (py + previous.y) / 2)
			dot.Size = UDim2.fromOffset(4, 4)
			dot.BackgroundColor3 = INK
			dot.BorderSizePixel = 0
			dot.Parent = recordSheet
		end
		local mark = Instance.new("Frame")
		mark.AnchorPoint = Vector2.new(0.5, 0.5)
		mark.Position = UDim2.fromOffset(px, py)
		mark.Size = UDim2.fromOffset(3, 3)
		mark.BackgroundColor3 = INK
		mark.BorderSizePixel = 0
		mark.Parent = recordSheet
		previous = { x = px, y = py }
	end

	for _, entry in data.entries do
		local px, py = toMap(entry.x, entry.z)
		local mark = Instance.new("TextLabel")
		mark.AnchorPoint = Vector2.new(0.5, 0.5)
		mark.Position = UDim2.fromOffset(px, py)
		mark.Size = UDim2.fromOffset(18, 16)
		mark.BackgroundTransparency = 1
		mark.Font = Enum.Font.SpecialElite
		mark.TextSize = 13
		mark.TextColor3 = FAINT
		mark.Text = tostring(entry.n)
		mark.Parent = recordSheet
	end

	-- right column: tallies, pauses, corrections
	local y = 0.2
	for _, tally in data.tallies do
		local groups = math.floor(tally.count / 5)
		local marks = string.rep("||||| ", groups) .. string.rep("|", tally.count % 5)
		sheetLabel(string.format("%s   %s", tally.label, marks), 0.57, y, 0.4, 0.042)
		y += 0.055
	end
	y += 0.03
	for _, pause in data.pauses do
		sheetLabel(string.format("STOOD %ds — %s", pause.seconds, pause.label), 0.57, y, 0.4, 0.038)
		y += 0.048
	end
	y += 0.03
	sheetLabel(string.format("ROOM ADJUSTMENTS NOTED: %d", data.corrections), 0.57, y, 0.4, 0.038)

	-- the live line: typed while you read, because it is being written about you right now
	local live = sheetLabel("", 0.03, 0.94, 0.9, 0.05)
	task.delay(tuning.LIVE_LINE_DELAY_SECONDS, function()
		for index = 1, #data.liveLine do
			if not live.Parent then
				return
			end
			live.Text = string.sub(data.liveLine, 1, index)
			task.wait(tuning.LIVE_LINE_CHAR_SECONDS)
		end
	end)
end

local noteHideThread
local recordHideThread

local uiRemote = ReplicatedStorage:WaitForChild("SliceUI")
uiRemote.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.kind == "objective" then
		endCard.Visible = false
		objective.Text = payload.text or ""
	elseif payload.kind == "note" then
		noteText.Text = payload.text or ""
		noteFrame.Visible = true
		if noteHideThread then
			task.cancel(noteHideThread)
		end
		noteHideThread = task.delay(tuning.NOTE_POPUP_SECONDS, function()
			noteFrame.Visible = false
			noteHideThread = nil
		end)
	elseif payload.kind == "record" then
		renderRecord(payload.data or {})
		recordDim.Visible = true
		if recordHideThread then
			task.cancel(recordHideThread)
		end
		recordHideThread = task.delay(tuning.RECORD_VIEW_SECONDS, function()
			recordDim.Visible = false
			recordHideThread = nil
		end)
	elseif payload.kind == "endcard" then
		noteFrame.Visible = false
		recordDim.Visible = false
		for index, line in endLines do
			line.Text = (payload.lines and payload.lines[index]) or ""
		end
		endCard.Visible = true
	end
end)
