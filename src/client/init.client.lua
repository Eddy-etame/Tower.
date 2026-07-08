-- Silent Witness MVP client: renders the objective line, note popups, and the end card.
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

local INK = Color3.fromRGB(230, 224, 210)

local objective = Instance.new("TextLabel")
objective.AnchorPoint = Vector2.new(0.5, 0)
objective.Position = UDim2.new(0.5, 0, 0, 14)
objective.Size = UDim2.new(0.9, 0, 0, 30)
objective.BackgroundTransparency = 1
objective.Font = Enum.Font.SpecialElite
objective.TextSize = 22
objective.TextColor3 = INK
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
noteText.TextColor3 = INK
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
	line.TextColor3 = INK
	line.Text = ""
	line.Parent = endCard
	endLines[index] = line
end

local noteHideThread

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
	elseif payload.kind == "endcard" then
		noteFrame.Visible = false
		for index, line in endLines do
			line.Text = (payload.lines and payload.lines[index]) or ""
		end
		endCard.Visible = true
	end
end)
