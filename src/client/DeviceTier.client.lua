-- Device-tier gate: the game's heavy fullscreen passes (DepthOfField, volumetric Atmosphere, Bloom) run
-- full-strength on desktop but cost real GPU on the ~70% mobile majority, so touch devices get them gated off
-- LOCALLY (a LocalScript destroying/disabling Lighting children affects only this client). When the Atmosphere
-- goes, the classic fog already configured in Lighting (FogStart/End + the same near-black FogColor) takes over
-- the same occlusion role at near-zero cost — the horror read survives, the frame budget comes back.
-- The knobs live in SliceTuning (MOBILE_*); ColorCorrection is cheap and stays everywhere.
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local tuning = require(ReplicatedStorage.Shared.SliceTuning)

local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
if not isMobile then
	return
end

if tuning.MOBILE_DISABLE_DOF then
	local dof = Lighting:FindFirstChild("DreadDoF")
	if dof then
		dof.Enabled = false
	end
end

if tuning.MOBILE_DISABLE_ATMOSPHERE then
	local atmos = Lighting:FindFirstChild("DreadAtmosphere")
	if atmos then
		atmos:Destroy() -- classic fog (FogStart/End/Color, already set) takes over the occlusion role
	end
end

if tuning.MOBILE_DISABLE_BLOOM then
	local bloom = Lighting:FindFirstChild("DreadBloom")
	if bloom then
		bloom.Enabled = false
	end
end
