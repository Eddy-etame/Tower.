-- Factory for an honestly-labeled STUB encounter (Rule 2: a stub is labeled a stub, never demoed as done).
-- Builds a small lit room that names the archetype and its emotional core, with a pad to proceed. Each of the
-- three remaining Bible encounters is one file that calls this — "adding an encounter = filling in one file".
local Players = game:GetService("Players")
local BuildKit = require(script.Parent.Parent.BuildKit)

local Stub = {}

function Stub.make(def)
	local Stage = {}
	Stage.name = def.name
	Stage.title = def.title

	function Stage.build(ctx)
		local folder = ctx.folder
		BuildKit.room(folder, { minX = 0, maxX = 40, minZ = -14, maxZ = 14 })
		BuildKit.pool(folder, 20, 10.5, 0, Color3.fromRGB(214, 226, 240), 1.7, 32)
		BuildKit.sign(
			folder,
			CFrame.lookAt(Vector3.new(20, 5, -13.4), Vector3.new(20, 5, 0)),
			def.title .. "\n\n[ NOT YET BUILT — STUB ]\n\n" .. def.emotion,
			BuildKit.PAPER
		)
		local pad = BuildKit.pad(folder, Vector3.new(36, 0.35, 0), BuildKit.GREEN)
		local h = { spawn = Vector3.new(4, 3.5, 0), cleared = false }
		pad.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player and not h.cleared then
				h.cleared = true
				ctx.clear()
			end
		end)
		return h
	end

	function Stage.onPlayerEnter(h, ctx, player)
		local char = player.Character
		if char and char.PrimaryPart then
			char:PivotTo(CFrame.new(h.spawn))
		end
		ctx.send(player, { kind = "objective", text = "NOT BUILT YET — STEP ON THE PAD TO CONTINUE." })
	end

	return Stage
end

return Stub
