-- MVP client UI: the stated objective, the title card, the caught blackout, the escape card, and a red edge
-- vignette that intensifies as the Watcher closes (feel, don't read — no distance meter). The client renders
-- and requests; the server decides — this script only LISTENS.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

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

-- the 3-second-understanding onboarding: threat + rule + objective + control, read at a glance then gone.
-- Data-driven so each encounter sends its own card: kind="rules", lines = { {t=text, y=scale, s=size, c={r,g,b}} }
local rules = Instance.new("Frame")
rules.Size = UDim2.fromScale(1, 1)
rules.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
rules.BackgroundTransparency = 1
rules.BorderSizePixel = 0
rules.Visible = false
rules.Parent = gui

local function rulesLine(text, yScale, size, color)
	local l = Instance.new("TextLabel")
	l.AnchorPoint = Vector2.new(0.5, 0.5)
	l.Position = UDim2.fromScale(0.5, yScale)
	l.Size = UDim2.new(0.92, 0, 0, size + 10)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.SpecialElite
	l.TextSize = size
	l.TextColor3 = color or INK
	l.Text = text
	l.Parent = rules
	return l
end

local rulesParts = {}
local function buildRules(lines)
	for _, l in rulesParts do
		l:Destroy()
	end
	rulesParts = {}
	for _, line in ipairs(lines or {}) do
		local color = line.c and Color3.fromRGB(line.c[1], line.c[2], line.c[3]) or INK
		table.insert(rulesParts, rulesLine(line.t, line.y, line.s, color))
	end
end

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

-- a brief text-only banner (no screen-filling background) for good beats like escaping
local banner = Instance.new("TextLabel")
banner.AnchorPoint = Vector2.new(0.5, 0.5)
banner.Position = UDim2.fromScale(0.5, 0.4)
banner.Size = UDim2.new(0.9, 0, 0, 64)
banner.BackgroundTransparency = 1
banner.Font = Enum.Font.SpecialElite
banner.TextSize = 50
banner.TextColor3 = INK
banner.TextStrokeTransparency = 0.3
banner.TextTransparency = 1
banner.Text = ""
banner.Parent = gui

local function showBanner(text)
	banner.Text = text
	banner.TextTransparency = 1
	TweenService:Create(banner, TweenInfo.new(0.4), { TextTransparency = 0 }):Play()
	task.delay(1.8, function()
		TweenService:Create(banner, TweenInfo.new(0.9), { TextTransparency = 1 }):Play()
	end)
end

-- a stage title, shown briefly on entering each stage
local titleLabel = Instance.new("TextLabel")
titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
titleLabel.Position = UDim2.fromScale(0.5, 0.28)
titleLabel.Size = UDim2.new(0.92, 0, 0, 50)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.SpecialElite
titleLabel.TextSize = 34
titleLabel.TextColor3 = INK
titleLabel.TextStrokeTransparency = 0.4
titleLabel.TextTransparency = 1
titleLabel.Text = ""
titleLabel.Parent = gui

local function showTitle(text)
	titleLabel.Text = text
	titleLabel.TextTransparency = 1
	TweenService:Create(titleLabel, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
	task.delay(2.6, function()
		TweenService:Create(titleLabel, TweenInfo.new(1), { TextTransparency = 1 }):Play()
	end)
end

local function showCard(text, color)
	cardText.Text = text
	fullCard.BackgroundColor3 = color
	fullCard.Visible = true
	fullCard.BackgroundTransparency = 1
	cardText.TextTransparency = 1
	TweenService:Create(fullCard, TweenInfo.new(0.35), { BackgroundTransparency = 0.05 }):Play()
	TweenService:Create(cardText, TweenInfo.new(0.5), { TextTransparency = 0 }):Play()
end

-- the pass-through blackout (Encounter III): fade to total black, hold, fade back
local blackout = Instance.new("Frame")
blackout.Size = UDim2.fromScale(1, 1)
blackout.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blackout.BackgroundTransparency = 1
blackout.BorderSizePixel = 0
blackout.ZIndex = 50
blackout.Visible = false
blackout.Parent = gui

local function playBlackout(seconds)
	seconds = tonumber(seconds) or 1.5
	blackout.Visible = true
	blackout.BackgroundTransparency = 1
	TweenService:Create(blackout, TweenInfo.new(0.12), { BackgroundTransparency = 0 }):Play()
	task.delay(math.max(0.3, seconds - 0.4), function()
		TweenService:Create(blackout, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
		task.delay(0.4, function()
			blackout.Visible = false
		end)
	end)
end

-- the tape playback reveal (Encounter III): two rows of impulse marks — YOUR steps, and a SECOND set half a beat
-- behind that keeps going one step after yours stop. The muted player and the stream viewer both READ it.
local tapePanel
local function playTape(steps)
	if tapePanel then
		tapePanel:Destroy()
	end
	steps = math.clamp(tonumber(steps) or 7, 3, 11)
	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.fromOffset(540, 250)
	panel.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	panel.BackgroundTransparency = 0.06
	panel.BorderSizePixel = 0
	panel.ZIndex = 40
	panel.Parent = gui
	tapePanel = panel

	local function label(text, y, size, color, x, align)
		local l = Instance.new("TextLabel")
		l.Position = UDim2.fromOffset(x or 24, y)
		l.Size = UDim2.fromOffset(align and 490 or 120, size + 6)
		l.BackgroundTransparency = 1
		l.Font = Enum.Font.SpecialElite
		l.TextSize = size
		l.TextXAlignment = align or Enum.TextXAlignment.Left
		l.TextColor3 = color or INK
		l.Text = text
		l.ZIndex = 41
		l.Parent = panel
	end
	label("TAPE — PLAYBACK", 16, 24, INK, 24, Enum.TextXAlignment.Center)

	local function dotRow(y, count, color, offsetPx)
		for i = 1, count do
			local dot = Instance.new("Frame")
			dot.Size = UDim2.fromOffset(11, 11)
			dot.Position = UDim2.fromOffset(150 + offsetPx + (i - 1) * 34, y)
			dot.BackgroundColor3 = color
			dot.BorderSizePixel = 0
			dot.ZIndex = 41
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(1, 0)
			c.Parent = dot
			dot.Parent = panel
		end
	end
	label("YOU", 96, 22, INK)
	dotRow(100, steps, Color3.fromRGB(228, 222, 208), 0)
	label("?", 150, 22, Color3.fromRGB(210, 60, 60))
	dotRow(154, steps, Color3.fromRGB(150, 150, 150), 17) -- half a beat behind...
	-- ...and one extra step, after yours stop
	local extra = Instance.new("Frame")
	extra.Size = UDim2.fromOffset(11, 11)
	extra.Position = UDim2.fromOffset(150 + 17 + steps * 34, 154)
	extra.BackgroundColor3 = Color3.fromRGB(210, 60, 60)
	extra.BorderSizePixel = 0
	extra.ZIndex = 41
	local ec = Instance.new("UICorner")
	ec.CornerRadius = UDim.new(1, 0)
	ec.Parent = extra
	extra.Parent = panel
	label("there are two sets of footsteps.", 208, 18, Color3.fromRGB(180, 120, 120), 24, Enum.TextXAlignment.Center)

	task.delay(5, function()
		if tapePanel == panel then
			TweenService:Create(panel, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
			for _, ch in panel:GetDescendants() do
				if ch:IsA("TextLabel") then
					TweenService:Create(ch, TweenInfo.new(0.8), { TextTransparency = 1 }):Play()
				elseif ch:IsA("Frame") then
					TweenService:Create(ch, TweenInfo.new(0.8), { BackgroundTransparency = 1 }):Play()
				end
			end
			task.delay(0.9, function()
				panel:Destroy()
			end)
		end
	end)
end

local function hideCard()
	TweenService:Create(fullCard, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
	TweenService:Create(cardText, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
	task.delay(0.5, function()
		fullCard.Visible = false
	end)
end

-- the rules card clears the instant you move (so it never covers your view), or after RULES_SECONDS
local rulesConn
local function dismissRules()
	if not rules.Visible then
		return
	end
	if rulesConn then
		rulesConn:Disconnect()
		rulesConn = nil
	end
	TweenService:Create(rules, TweenInfo.new(0.4), { BackgroundTransparency = 1 }):Play()
	for _, l in rulesParts do
		TweenService:Create(l, TweenInfo.new(0.4), { TextTransparency = 1 }):Play()
	end
	task.delay(0.45, function()
		rules.Visible = false
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
		showTitle(payload.title or "")
	elseif payload.kind == "rules" then
		hideCard()
		buildRules(payload.lines)
		rules.Visible = true
		rules.BackgroundTransparency = 0.35
		for _, l in rulesParts do
			l.TextTransparency = 0
		end
		local shownAt = os.clock()
		if rulesConn then
			rulesConn:Disconnect()
		end
		rulesConn = RunService.Heartbeat:Connect(function()
			local char = player.Character
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			local moving = hum and hum.MoveDirection.Magnitude > 0.1
			if moving or (os.clock() - shownAt > tuning.RULES_SECONDS) then
				dismissRules()
			end
		end)
	elseif payload.kind == "banner" then
		showBanner(payload.text or "")
	elseif payload.kind == "tape" then
		playTape(payload.steps)
	elseif payload.kind == "blackout" then
		playBlackout(payload.seconds)
	elseif payload.kind == "danger" then
		local lvl = math.clamp(tonumber(payload.level) or 0, 0, 1)
		TweenService:Create(vignette, TweenInfo.new(0.2), { ImageTransparency = 1 - lvl * 0.72 }):Play()
	elseif payload.kind == "surge" then
		-- the power died: a hard red flash spike (the danger vignette resumes control on the next tick)
		vignette.ImageTransparency = 0.2
		TweenService:Create(vignette, TweenInfo.new(0.6), { ImageTransparency = 0.55 }):Play()
		showBanner("RUN.")
	elseif payload.kind == "retry" then
		-- back in after a catch: clear the caught card + reset the vignette (no rules re-show)
		hideCard()
		TweenService:Create(vignette, TweenInfo.new(0.4), { ImageTransparency = 1 }):Play()
	elseif payload.kind == "caught" then
		TweenService:Create(vignette, TweenInfo.new(0.15), { ImageTransparency = 0.2 }):Play()
		showCard("IT REACHED YOU.", Color3.fromRGB(20, 0, 0))
	elseif payload.kind == "escaped" then
		TweenService:Create(vignette, TweenInfo.new(0.6), { ImageTransparency = 1 }):Play()
		showBanner("YOU GOT OUT.") -- brief text, no screen-fill, so the safe chamber is visible immediately
	end
end)
