-- Encounter One client: objective line, note popups, end card, and a slow red vignette that breathes in while
-- the file wall reveals in the annex (the violation, felt at the screen edge). The file itself lives in the
-- world — this UI only frames it. The client renders and requests; the server decides — this script LISTENS only.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

local INK_LIGHT = Color3.fromRGB(228, 222, 208)

-- edge vignette (a dark frame with a soft hole) — used for the annex "being watched" pressure
local vignette = Instance.new("ImageLabel")
vignette.Size = UDim2.fromScale(1, 1)
vignette.BackgroundTransparency = 1
vignette.Image = "rbxasset://textures/ui/Vignette.png" -- built-in; STUB until a bespoke mask is authored
vignette.ImageColor3 = Color3.fromRGB(120, 0, 0)
vignette.ImageTransparency = 1
vignette.ScaleType = Enum.ScaleType.Stretch
vignette.Parent = gui

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
noteFrame.Position = UDim2.fromScale(0.5, 0.66)
noteFrame.Size = UDim2.new(0.7, 0, 0, 120)
noteFrame.BackgroundColor3 = Color3.fromRGB(14, 13, 12)
noteFrame.BackgroundTransparency = 0.2
noteFrame.BorderSizePixel = 0
noteFrame.Visible = false
noteFrame.Parent = gui

local noteText = Instance.new("TextLabel")
noteText.Size = UDim2.fromScale(0.94, 0.94)
noteText.Position = UDim2.fromScale(0.03, 0.03)
noteText.BackgroundTransparency = 1
noteText.Font = Enum.Font.SpecialElite
noteText.TextSize = 26
noteText.TextColor3 = INK_LIGHT
noteText.TextWrapped = true
noteText.Text = ""
noteText.Parent = noteFrame

local endCard = Instance.new("Frame")
endCard.Size = UDim2.fromScale(1, 1)
endCard.BackgroundColor3 = Color3.fromRGB(6, 6, 6)
endCard.BackgroundTransparency = 0.05
endCard.BorderSizePixel = 0
endCard.Visible = false
endCard.Parent = gui

local endLines = {}
for index = 1, 3 do
	local line = Instance.new("TextLabel")
	line.AnchorPoint = Vector2.new(0.5, 0.5)
	line.Position = UDim2.fromScale(0.5, 0.36 + index * 0.09)
	line.Size = UDim2.new(0.9, 0, 0, 40)
	line.BackgroundTransparency = 1
	line.Font = Enum.Font.SpecialElite
	line.TextSize = index == 1 and 44 or 26
	line.TextColor3 = INK_LIGHT
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
		-- the annex hold beat brings the watched-pressure vignette in; anything else clears it
		if payload.text == "DON'T MOVE." then
			TweenService:Create(vignette, TweenInfo.new(3), { ImageTransparency = 0.35 }):Play()
		else
			TweenService:Create(vignette, TweenInfo.new(1.5), { ImageTransparency = 1 }):Play()
		end
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
		TweenService:Create(vignette, TweenInfo.new(1), { ImageTransparency = 1 }):Play()
		for index, line in endLines do
			line.Text = (payload.lines and payload.lines[index]) or ""
		end
		endCard.Visible = true
	end
end)
