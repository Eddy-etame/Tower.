-- The flashlight: a tight cone that follows where you look, in a scene crushed to near-black. It is a MASK —
-- you see the sliver you point at, the dark hides everything else, and the room sees all of you regardless.
-- The client owns the cone + on/off and reports on/off to the server; the SERVER owns the battery and gates
-- whether the light can freeze the Watcher. When power runs low the light flickers; when it's dead it dims to
-- a floor so you're never fully blind — but it can no longer hold the Watcher.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local flashlightRemote = ReplicatedStorage:WaitForChild("Flashlight")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

if isMobile then
	-- keep the mobile boost RELATIVE to the new base exposure (0.25 in Lighting): small screens in bright rooms
	-- need more headroom than desktops in dim rooms
	Lighting.ExposureCompensation = 0.45
end

local CONE_ANGLE = isMobile and 48 or 45
local CONE_RANGE = 55
local CONE_BRIGHTNESS = isMobile and 9 or 8 -- verified too weak in-game at 4-6: the cone must OWN the dark
local CONE_COLOR = Color3.fromRGB(232, 238, 248)

local enabled = true
local suppressed = false -- stage-declared (server): a room whose fiction needs the dark turns the cone off entirely
local lastToggle = 0
local managed, level = false, 1 -- server-owned battery state (only in the rationing encounter)
local light, fill

-- battery bar (shown only while the light is rationed)
local gui = Instance.new("ScreenGui")
gui.Name = "FlashlightUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.Parent = player:WaitForChild("PlayerGui")
-- bottom-LEFT, clear of the right-side LIGHT button (mobile: never stack the resource meter under the control)
local barBack = Instance.new("Frame")
barBack.AnchorPoint = Vector2.new(0, 1)
barBack.Position = UDim2.new(0, 24, 1, -26)
barBack.Size = UDim2.fromOffset(150, 14)
barBack.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
barBack.BackgroundTransparency = 0.25
barBack.BorderSizePixel = 0
barBack.Visible = false
barBack.Parent = gui
local barFill = Instance.new("Frame")
barFill.Size = UDim2.fromScale(1, 1)
barFill.BackgroundColor3 = Color3.fromRGB(232, 238, 248)
barFill.BorderSizePixel = 0
barFill.Parent = barBack
local barLabel = Instance.new("TextLabel")
barLabel.AnchorPoint = Vector2.new(0, 1)
barLabel.Position = UDim2.fromOffset(0, -2)
barLabel.Size = UDim2.fromOffset(150, 16)
barLabel.BackgroundTransparency = 1
barLabel.Font = Enum.Font.SpecialElite
barLabel.TextSize = 13
barLabel.TextXAlignment = Enum.TextXAlignment.Left
barLabel.TextColor3 = Color3.fromRGB(150, 143, 128)
barLabel.Text = isMobile and "LIGHT — TAP" or "LIGHT — [F]" -- the meter teaches its own control (UX: never strand a player)
barLabel.Parent = barBack

local function applyLight()
	if not light then
		return
	end
	local on = enabled and not suppressed
	local dead = managed and level <= tuning.BATTERY_MIN
	light.Enabled = on
	fill.Enabled = on
	if not on then
		return
	end
	if dead then
		light.Brightness = CONE_BRIGHTNESS * 0.55 -- a dying floor: dim + cannot freeze, but you can still SEE to move
	else
		light.Brightness = CONE_BRIGHTNESS
	end
end

local function build(character)
	local head = character:WaitForChild("Head")
	-- myAnchor is FUNCTION-LOCAL on purpose: the render closure below must track THIS build's anchor. When it
	-- was the shared upvalue, a respawn re-pointed it at the NEW anchor, so the OLD closure never disconnected
	-- and kept pinning the cone to the dead character's head position, fighting the live one every frame.
	local myAnchor = Instance.new("Part")
	myAnchor.Name = "FlashlightAnchor"
	myAnchor.Size = Vector3.new(0.2, 0.2, 0.2)
	myAnchor.Transparency = 1
	myAnchor.CanCollide = false
	myAnchor.CanQuery = false
	myAnchor.Massless = true
	myAnchor.CastShadow = false
	myAnchor.Parent = character

	light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Front
	light.Angle = CONE_ANGLE
	light.Range = CONE_RANGE
	light.Brightness = CONE_BRIGHTNESS
	light.Color = CONE_COLOR
	-- SHADOWLESS EVERYWHERE (verified on-device): a moving shadowed SpotLight is the first thing weak GPUs /
	-- low quality levels cull — the cone must survive on every machine, dread be damped a notch. Playability first.
	light.Shadows = false
	light.Enabled = enabled
	light.Parent = myAnchor

	fill = Instance.new("PointLight")
	fill.Range = 12
	fill.Brightness = 1.1 -- the near-field must always be readable: your own feet, the wall you face
	fill.Color = CONE_COLOR
	fill.Shadows = false
	fill.Enabled = enabled
	fill.Parent = myAnchor

	applyLight()
	flashlightRemote:FireServer(enabled) -- report initial state

	local smoothed = camera.CFrame
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		if not myAnchor.Parent then
			connection:Disconnect()
			return
		end
		smoothed = smoothed:Lerp(camera.CFrame, math.clamp(dt * 12, 0, 1))
		myAnchor.CFrame = CFrame.lookAt(head.Position, head.Position + smoothed.LookVector)
	end)
end

local function toggle(_, state)
	if state ~= Enum.UserInputState.Begin then
		return
	end
	if suppressed then
		return -- the room took the light; the toggle does nothing here
	end
	if os.clock() - lastToggle < 0.35 then
		return
	end
	lastToggle = os.clock()
	enabled = not enabled
	-- the CLICK (the most-used interaction was mute): pitch up = on, down = off - the ear learns the state
	local click = Instance.new("Sound")
	click.SoundId = tuning.CLICK_SOUND
	click.PlaybackSpeed = enabled and 1.15 or 0.85
	click.Volume = tuning.CLICK_VOLUME
	click.Parent = camera
	click:Play()
	click.Ended:Once(function()
		click:Destroy()
	end)
	applyLight()
	flashlightRemote:FireServer(enabled)
end

ContextActionService:BindAction("Flashlight", toggle, true, Enum.KeyCode.F, Enum.KeyCode.ButtonR2)
ContextActionService:SetTitle("Flashlight", "LIGHT")
ContextActionService:SetPosition("Flashlight", UDim2.new(1, -140, 0.5, -30))

-- server battery state -> render (bar + low-power flicker + dead-floor dim)
flashlightRemote.OnClientEvent:Connect(function(payload)
	if typeof(payload) ~= "table" then
		return
	end
	local wasManaged = managed
	managed = payload.managed == true
	suppressed = payload.disabled == true -- stage entry declares whether this room allows the cone at all
	level = tonumber(payload.level) or 1
	barBack.Visible = managed
	if managed then
		barFill.Size = UDim2.fromScale(math.clamp(level, 0, 1), 1)
		barFill.BackgroundColor3 = level <= tuning.BATTERY_LOW and Color3.fromRGB(210, 70, 60)
			or Color3.fromRGB(232, 238, 248)
	end
	-- on the unmanaged reset (fired on entering any stage), re-report our actual on-state so the server's
	-- freeze logic matches the light the player is actually holding
	if not managed and wasManaged ~= nil then
		flashlightRemote:FireServer(enabled)
	end
	applyLight()
end)

-- low-power flicker: a scare beat that also warns you the light is running out
task.spawn(function()
	local rng = Random.new()
	while true do
		if
			light
			and enabled
			and not suppressed
			and managed
			and level > tuning.BATTERY_MIN
			and level <= tuning.BATTERY_LOW
		then
			light.Enabled = false
			fill.Enabled = false
			task.wait(rng:NextNumber(0.03, 0.08))
			if light then
				light.Enabled = enabled and not suppressed
				fill.Enabled = enabled and not suppressed
			end
			task.wait(rng:NextNumber(0.25, 0.7))
		else
			task.wait(0.15)
		end
	end
end)

if player.Character then
	build(player.Character)
end
player.CharacterAdded:Connect(build)
