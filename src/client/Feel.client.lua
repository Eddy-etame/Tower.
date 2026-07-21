-- GAME-FEEL: the camera is a body, not a tripod. Three quiet layers that make stock Roblox movement feel
-- authored: a walk bob (vertical + slight sway at step rhythm), a moving-FOV ease (motion reads as motion),
-- and a landing dip that recovers like knees, not a spring-loaded stick. All amplitudes are sub-perceptual
-- on purpose (feel it, never see it) and everything lerps — nothing snaps. Mobile-safe: pure camera math,
-- no input hooks, no per-frame allocations.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tuning = require(ReplicatedStorage.Shared.SliceTuning)

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local t = 0 -- bob phase (advances only while moving, so the bob never ticks while standing)
local fov = tuning.FEEL_FOV_BASE
local kick = 0 -- impact channel: any script sets the player's "FeelKick" attribute; it decays here
player:GetAttributeChangedSignal("FeelKick"):Connect(function()
	local v = player:GetAttribute("FeelKick")
	if typeof(v) == "number" and v > 0 then
		kick = math.clamp(v, 0, 1)
		player:SetAttribute("FeelKick", 0)
	end
end)
local dip = 0 -- current landing dip (springs back to 0)
local dipVel = 0

local humanoid -- tracked per character

local function onCharacter(char)
	humanoid = char:WaitForChild("Humanoid")
	humanoid.StateChanged:Connect(function(_, new)
		if new == Enum.HumanoidStateType.Landed then
			dip = -tuning.FEEL_LAND_DIP -- knees take the hit; the spring below stands us back up
			dipVel = 0
		end
	end)
end

if player.Character then
	onCharacter(player.Character)
end
player.CharacterAdded:Connect(onCharacter)

RunService.RenderStepped:Connect(function(dt)
	if not humanoid or humanoid.Health <= 0 then
		return
	end
	-- how much we're actually moving (0..1 of walk speed) drives every layer
	local speed = humanoid.RootPart and humanoid.RootPart.AssemblyLinearVelocity.Magnitude or 0
	local move = math.clamp(speed / math.max(humanoid.WalkSpeed, 1), 0, 1)

	-- walk bob: phase only advances while moving; amplitude follows move so it fades in/out with your feet
	t += dt * tuning.FEEL_BOB_HZ * 2 * math.pi * math.max(move, 0.01)
	local bobY = math.sin(t * 2) * tuning.FEEL_BOB_AMP * move -- double-frequency vertical (two footfalls per cycle)
	local swayX = math.sin(t) * tuning.FEEL_BOB_AMP * tuning.FEEL_SWAY_RATIO * move

	-- landing dip: critically-damped spring back to zero
	local k = tuning.FEEL_LAND_RECOVER
	local c = 2 * math.sqrt(k)
	dipVel += (-k * dip - c * dipVel) * dt
	dip += dipVel * dt

	humanoid.CameraOffset = Vector3.new(swayX, bobY + dip, 0)

	-- moving FOV: wider when moving, eased — never a snap zoom
	kick *= math.exp(-tuning.FEEL_KICK_DECAY * dt) -- the punch decays like a struck thing settling
	local targetFov = tuning.FEEL_FOV_BASE + tuning.FEEL_FOV_MOVE * move
	fov += (targetFov - fov) * (1 - math.exp(-tuning.FEEL_FOV_LERP * dt))
	camera.FieldOfView = fov + kick * tuning.FEEL_KICK_FOV
end)
