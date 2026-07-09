-- MVP client UI: the stated objective, the title card, the caught blackout, the escape card, and a red edge
-- vignette that intensifies as the Watcher closes (feel, don't read — no distance meter). The client renders
-- and requests; the server decides — this script only LISTENS.
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
gui.Name = "MvpUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")

local INK = Color3.fromRGB(228, 222, 208)

local vignette = Instance.new("ImageLabel")
vignette.Size = UDim2.fromScale(1, 1)
vignette.BackgroundTransparency = 1
vignette.Image = "rbxasset://textures/ui/Vignette.png"
vignette.ImageColor3 = Color3.fromRGB(150, 0, 0)
vignette.ImageTransparency = 1
vignette.ScaleType = Enum.ScaleType.Stretch
vignette.Parent = gui

local objective = Instance.new("TextLabel")
objective.AnchorPoint = Vector2.new(0.5, 1)
objective.Position = UDim2.new(0.5, 0, 1, -24)
objective.Size = UDim2.new(0.9, 0, 0, 28)
objective.BackgroundTransparency = 1
objective.Font = Enum.Font.SpecialElite
objective.TextSize = 20
objective.TextColor3 = INK
objective.TextStrokeTransparency = 0.4
objective.Text = ""
objective.Parent = gui

local title = Instance.new("TextLabel")
title.AnchorPoint = Vector2.new(0.5, 0.5)
title.Position = UDim2.fromScale(0.5, 0.42)
title.Size = UDim2.new(0.9, 0, 0, 60)
title.BackgroundTransparency = 1
title.Font = Enum.Font.SpecialElite
title.TextSize = 52
title.TextColor3 = INK
title.TextTransparency = 1
title.Text = ""
title.Parent = gui

local fullCard = Instance.new("Frame")
fullCard.Size = UDim2.fromScale(1, 1)
fullCard.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
fullCard.BackgroundTransparency = 1
fullCard.BorderSizePixel = 0
fullCard.Visible = false
fullCard.Parent = gui

local cardText = Instance.new("TextLabel")
cardText.AnchorPoint = Vector2.new(0.5, 0.5)
cardText.Position = UDim2.fromScale(0.5, 0.5)
cardText.Size = UDim2.new(0.9, 0, 0, 60)
cardText.BackgroundTransparency = 1
cardText.Font = Enum.Font.SpecialElite
cardText.TextSize = 46
cardText.TextColor3 = INK
cardText.Text = ""
cardText.Parent = fullCard

local function showCard(text, color)
	cardText.Text = text
	fullCard.BackgroundColor3 = color
	fullCard.Visible = true
	fullCard.BackgroundTransparency = 1
	cardText.TextTransparency = 1
	TweenService:Create(fullCard, TweenInfo.new(0.35), { BackgroundTransparency = 0.05 }):Play()
	TweenService:Create(cardText, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
end

local function hideCard()
	TweenService:Create(fullCard, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(cardText, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
	task.delay(0.5, function()
		fullCard.Visible = false
	end)
end

local uiRemote = ReplicatedStorage:WaitForChild("MvpUI")
uiRemote.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	if payload.kind == "objective" then
		objective.Text = payload.text or ""
	elseif payload.kind == "title" then
		hideCard()
		title.Text = payload.title or ""
		title.TextTransparency = 0
		TweenService
			:Create(title, TweenInfo.new(tuning.TITLE_SECONDS, Enum.EasingStyle.Quint), { TextTransparency = 1 })
			:Play()
	elseif payload.kind == "danger" then
		local lvl = math.clamp(tonumber(payload.level) or 0, 0, 1)
		TweenService:Create(vignette, TweenInfo.new(0.2), { ImageTransparency = 1 - lvl * 0.72 }):Play()
	elseif payload.kind == "caught" then
		TweenService:Create(vignette, TweenInfo.new(0.15), { ImageTransparency = 0.2 }):Play()
		showCard("IT REACHED YOU.", Color3.fromRGB(20, 0, 0))
	elseif payload.kind == "escaped" then
		TweenService:Create(vignette, TweenInfo.new(0.6), { ImageTransparency = 1 }):Play()
		showCard("YOU GOT OUT.", Color3.fromRGB(4, 6, 8))
	end
end)
