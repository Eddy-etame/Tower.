-- The companion light (Encounter IV) — CLIENT render. The server owns an invisible logic orb (its authoritative
-- position at 10Hz + the diegetic hum + an OrbState attribute); this script renders the visible warm light and
-- follows the logic orb SMOOTHLY at frame rate, so the emotional core never reads choppy off the server tick. It
-- reads server state ONE-WAY and never writes back, so it can't touch the spend/cross decision (that is the server's).
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local TAG = "CompanionOrb"
local WARM = Color3.fromRGB(255, 196, 120)

local M -- the single active mount, or nil

local function unmount()
	if not M then
		return
	end
	if M.conn then
		M.conn:Disconnect()
	end
	M.orb:Destroy()
	M = nil
end

local function step(dt)
	if not M then
		return
	end
	local lo = M.logicOrb
	if not lo or not lo.Parent then
		unmount()
		return
	end
	-- smooth, frame-rate-independent follow toward the logic orb's replicated position
	M.pos = M.pos:Lerp(lo.Position, 1 - math.exp(-tuning.MORAL_ORB_FOLLOW * dt))
	M.orb.Position = M.pos

	-- render brightness/opacity for the server's state (eased, so flips read as pulses not snaps)
	local state = lo:GetAttribute("OrbState") or "follow"
	local glow, alpha = 2.2, 1
	if state == "gutter" then
		glow = 0.6
	elseif state == "flare" then
		glow = 4.5
	elseif state == "drain" then
		M.drainT += dt
		local a = math.clamp(M.drainT / tuning.MORAL_DRAIN_SECONDS, 0, 1)
		glow, alpha = 2.2 * (1 - a), 1 - a -- fades to nothing over the drain, in sync with the hum stopping
	elseif state == "spent" then
		glow, alpha = 0, 0
	else
		M.drainT = 0
	end
	local k = math.clamp(dt * 10, 0, 1)
	M.glow += (glow - M.glow) * k
	M.alpha += (alpha - M.alpha) * k
	M.light.Brightness = M.glow
	M.orb.Transparency = 1 - M.alpha
end

local function mount(logicOrb)
	unmount()
	local orb = Instance.new("Part")
	orb.Name = "CompanionVisual"
	orb.Shape = Enum.PartType.Ball
	orb.Size = Vector3.new(1.3, 1.3, 1.3)
	orb.Anchored = true
	orb.CanCollide = false
	orb.CanQuery = false
	orb.CastShadow = false
	orb.Material = Enum.Material.Neon
	orb.Color = WARM
	orb.Position = logicOrb.Position
	local light = Instance.new("PointLight")
	light.Range = 26
	light.Color = WARM
	light.Shadows = false
	light.Brightness = 2.2
	light.Parent = orb
	orb.Parent = workspace
	M = {
		logicOrb = logicOrb,
		orb = orb,
		light = light,
		pos = logicOrb.Position,
		glow = 2.2,
		alpha = 1,
		drainT = 0,
	}
	M.conn = RunService.RenderStepped:Connect(step)
end

for _, inst in CollectionService:GetTagged(TAG) do
	mount(inst)
end
CollectionService:GetInstanceAddedSignal(TAG):Connect(mount)
CollectionService:GetInstanceRemovedSignal(TAG):Connect(function(inst)
	if M and M.logicOrb == inst then
		unmount()
	end
end)
