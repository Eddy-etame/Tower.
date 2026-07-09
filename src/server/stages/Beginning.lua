-- The Beginning: a framed threshold room that names the game and poses the Bible's core question, then a pad
-- to descend. Zero cutscene, playable in seconds (2026 watch: sub-30s time-to-fun amplifies "understand in seconds").
local Players = game:GetService("Players")
local BuildKit = require(script.Parent.Parent.BuildKit)

local Beginning = {}
Beginning.name = "Beginning"
Beginning.title = "THE THRESHOLD"

function Beginning.build(ctx)
	local folder = ctx.folder
	BuildKit.room(folder, { minX = 0, maxX = 34, minZ = -12, maxZ = 12 })
	BuildKit.pool(folder, 17, 10.5, 0, Color3.fromRGB(255, 236, 205), 1.8, 32)
	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(17, 5, -11.4), Vector3.new(17, 5, 0)),
		"PROJECT 001\nTHE THRESHOLD\n\nWHAT'S BEHIND\nTHE NEXT DOOR?",
		BuildKit.PAPER
	)
	local pad = BuildKit.pad(folder, Vector3.new(30, 0.35, 0), BuildKit.GREEN)
	local h = { spawn = Vector3.new(4, 3.5, 0), started = false }
	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not h.started then
			h.started = true
			ctx.clear()
		end
	end)
	return h
end

function Beginning.onPlayerEnter(h, ctx, player)
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.new(h.spawn))
	end
	ctx.send(player, { kind = "objective", text = "STEP ONTO THE PAD TO ENTER." })
end

return Beginning
