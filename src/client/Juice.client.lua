-- The living camera: idle breathing + velocity-keyed head-bob on Humanoid.CameraOffset. A locked default
-- camera reads as a screenshot/menu — this makes the frame feel like a body standing in a real place.
-- Pure math on one property: free on any device (amplitude trimmed on mobile so a small screen doesn't nauseate).
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local isMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local amp = isMobile and 0.7 or 1

local function drive(character)
	local humanoid = character:WaitForChild("Humanoid")
	local current = Vector3.zero
	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		if not humanoid.Parent or humanoid.Health <= 0 then
			connection:Disconnect()
			return
		end
		local clock = os.clock()
		local speed = humanoid.MoveDirection.Magnitude * (humanoid.WalkSpeed / 16)

		-- idle breathing: slow vertical rise/fall + faint sway
		local breatheY = math.sin(clock * 2 * math.pi * 0.22) * 0.06
		local swayX = math.sin(clock * 0.5) * 0.02

		-- walk bob: figure-eight keyed to movement, blended in by how fast we move
		local bobFreq = 1.6 * math.max(speed, 0.001)
		local walkBlend = math.clamp(speed, 0, 1)
		local bobY = math.abs(math.sin(clock * bobFreq * 2 * math.pi)) * 0.12 * walkBlend
		local bobX = math.cos(clock * bobFreq * math.pi) * 0.08 * walkBlend

		local target = Vector3.new((swayX + bobX) * amp, (breatheY + bobY) * amp, 0)
		current = current:Lerp(target, math.clamp(dt * 8, 0, 1))
		humanoid.CameraOffset = current
	end)
end

if player.Character then
	drive(player.Character)
end
player.CharacterAdded:Connect(drive)
