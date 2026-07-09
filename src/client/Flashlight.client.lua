-- The flashlight: a tight cone that follows where you look, in a scene crushed to near-black. It is a MASK —
-- you see the sliver you point at, the dark hides everything else, and the room sees all of you regardless.
-- Client-side per-player (never server-updated); only scare flickers are server-authoritative (future).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

-- mobile renders darker + auto-drops local-light shadows; brighten the cone and lift exposure so a phone
-- at ~50% brightness can still navigate (research: never sign off darkness on a PC monitor)
if isMobile then
	Lighting.ExposureCompensation = 0.35
end

local CONE_ANGLE = isMobile and 48 or 45
local CONE_RANGE = 55
local CONE_BRIGHTNESS = isMobile and 6 or 4
local CONE_COLOR = Color3.fromRGB(232, 238, 248) -- cold-neutral: a light that does not comfort (The Threshold)

local enabled = true
local lastToggle = 0
local light, fill, anchor

local function build(character)
	local head = character:WaitForChild("Head")
	anchor = Instance.new("Part")
	anchor.Name = "FlashlightAnchor"
	anchor.Size = Vector3.new(0.2, 0.2, 0.2)
	anchor.Transparency = 1
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.Massless = true
	anchor.CastShadow = false
	anchor.Parent = character

	light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Front
	light.Angle = CONE_ANGLE
	light.Range = CONE_RANGE
	light.Brightness = CONE_BRIGHTNESS
	light.Color = CONE_COLOR
	light.Shadows = true
	light.Enabled = enabled
	light.Parent = anchor

	-- near-field fill so the player isn't blind at their own feet on a dark screen
	fill = Instance.new("PointLight")
	fill.Range = 8
	fill.Brightness = 0.4
	fill.Color = CONE_COLOR
	fill.Shadows = false
	fill.Enabled = enabled
	fill.Parent = anchor

	local smoothed = camera.CFrame
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		if not anchor.Parent then
			connection:Disconnect()
			return
		end
		smoothed = smoothed:Lerp(camera.CFrame, math.clamp(dt * 12, 0, 1))
		anchor.CFrame = CFrame.lookAt(head.Position, head.Position + smoothed.LookVector)
	end)
end

local function toggle(_, state)
	if state ~= Enum.UserInputState.Begin then
		return
	end
	if os.clock() - lastToggle < 0.35 then
		return
	end
	lastToggle = os.clock()
	enabled = not enabled
	if light then
		light.Enabled = enabled
		fill.Enabled = enabled
	end
end

ContextActionService:BindAction("Flashlight", toggle, true, Enum.KeyCode.F, Enum.KeyCode.ButtonR2)
ContextActionService:SetTitle("Flashlight", "LIGHT")
ContextActionService:SetPosition("Flashlight", UDim2.new(1, -140, 0.5, -30))

if player.Character then
	build(player.Character)
end
player.CharacterAdded:Connect(build)
