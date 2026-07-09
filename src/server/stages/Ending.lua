-- The Ending: you made it through all four. A warm, safe room; the Bible's memory beat ("you'll remember");
-- a pad to descend again (loops to the Beginning — the "one more" pull comes from the experience, not a grind).
local Players = game:GetService("Players")
local BuildKit = require(script.Parent.Parent.BuildKit)

local Ending = {}
Ending.name = "Ending"
Ending.title = "YOU MADE IT OUT"

function Ending.build(ctx)
	local folder = ctx.folder
	BuildKit.room(folder, { minX = 0, maxX = 34, minZ = -12, maxZ = 12 })
	-- warm but DIM: relief, carrying weight — not a bright reward room. You made it out; you'll remember.
	BuildKit.pool(folder, 17, 10.5, -3, Color3.fromRGB(236, 220, 192), 1.3, 28)
	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(17, 5, -11.4), Vector3.new(17, 5, 0)),
		"YOU MADE IT OUT.\n\nBUT YOU'LL\nREMEMBER.",
		BuildKit.PAPER
	)
	local pad = BuildKit.pad(folder, Vector3.new(30, 0.35, 0), BuildKit.GREEN)
	local h = { spawn = Vector3.new(4, 3.5, 0), done = false }
	pad.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not h.done then
			h.done = true
			ctx.clear()
		end
	end)
	return h
end

function Ending.onPlayerEnter(h, ctx, player)
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.lookAt(h.spawn, h.spawn + Vector3.new(1, 0, 0))) -- face the pad (+X), not a blank wall
	end
	ctx.send(player, { kind = "objective", text = "STEP ONTO THE PAD TO DESCEND AGAIN." })
end

return Ending
