-- The Ending: you made it through all four. A dim warm room; the Bible's memory beat ("you'll remember");
-- and one more DOOR — "AGAIN?" — that grinds open as you near it (loops to the Beginning — the "one more"
-- pull comes from the experience, not a grind loop).
--
-- THE AFTERMATH (the Moral Collapse's consequence, following you out): a beat after you arrive, the far-off
-- other one of whatever the companion was CALLS, across a dark gap — a distant glow high on the far wall.
-- If you KEPT yours (crossed), a nearer hum answers and the glow settles, alive. If you SPENT it, the call
-- searches... and nothing answers; the glow dims out. Two-channel (hum + glow) so the muted player reads it.
-- The world never says a word about it either way — it only remembers (ctx.session.moralChoice).
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local BuildKit = require(script.Parent.Parent.BuildKit)

local Ending = {}
Ending.name = "Ending"
Ending.title = "YOU MADE IT OUT"

function Ending.build(ctx)
	local folder = ctx.folder
	local tuning = ctx.tuning
	BuildKit.room(folder, { minX = 0, maxX = 34, minZ = -12, maxZ = 12 })
	-- warm but DIM: relief, carrying weight — not a bright reward room. You made it out; you'll remember.
	BuildKit.pool(folder, 17, 10.5, -3, Color3.fromRGB(236, 220, 192), 1.3, 28)
	BuildKit.sign(
		folder,
		CFrame.lookAt(Vector3.new(17, 5, -11.4), Vector3.new(17, 5, 0)),
		"YOU MADE IT OUT.\n\nBUT YOU'LL\nREMEMBER.",
		BuildKit.PAPER
	)
	-- the way down again is a DOOR, like everything here (no game-y pad): it grinds open as you near it
	local gate = BuildKit.grindDoor(folder, 34, tuning.SURGE_SOUND)
	BuildKit.sign(folder, CFrame.lookAt(Vector3.new(33.5, 8.6, 0), Vector3.new(0, 8.6, 0)), "AGAIN?", BuildKit.PAPER)

	-- the far glow: the OTHER one, across a dark gap — high in the room's far corner, unlit until it calls
	local farGlow = BuildKit.part({
		Size = Vector3.new(0.6, 0.6, 0.6),
		CFrame = CFrame.new(33, 9.2, 8),
		Color = Color3.fromRGB(255, 196, 120),
		Material = Enum.Material.Neon,
		Transparency = 0.4,
		CanCollide = false,
		CanQuery = false,
		Name = "FarGlow",
	}, folder)
	local glowLight = Instance.new("PointLight")
	glowLight.Range = 14
	glowLight.Brightness = 0
	glowLight.Color = farGlow.Color
	glowLight.Shadows = false
	glowLight.Parent = farGlow

	local function call(volume, speed, seconds)
		local s = Instance.new("Sound")
		s.SoundId = tuning.MORAL_HUM_SOUND
		s.PlaybackSpeed = speed
		s.Volume = volume
		s.Looped = true
		s.Parent = farGlow
		s:Play()
		task.delay(seconds, function()
			s:Stop()
			s:Destroy()
		end)
	end

	local h =
		{ ctx = ctx, spawn = Vector3.new(4, 3.5, 0), gate = gate, done = false, accum = 0, aftermathPlayed = false }

	-- the aftermath timeline (fires once, a beat after first arrival; silent no-op if IV was somehow skipped)
	function h.playAftermath()
		if h.aftermathPlayed then
			return
		end
		h.aftermathPlayed = true
		local choice = ctx.session.moralChoice
		if not choice then
			return
		end
		task.delay(3, function()
			if not farGlow.Parent then
				return -- stage torn down before the beat landed
			end
			if choice == "crossed" then
				-- the one you kept hums, behind you... and the far one RISES in answer. Both still here.
				call(0.18, tuning.MORAL_HUM_SPEED, 1.2)
				task.delay(2, function()
					if farGlow.Parent then
						call(0.25, tuning.MORAL_HUM_SPEED * 0.82, 1.2)
						TweenService:Create(glowLight, TweenInfo.new(0.8), { Brightness = 0.7 }):Play()
						task.delay(2.2, function()
							if farGlow.Parent then
								TweenService:Create(glowLight, TweenInfo.new(1.6), { Brightness = 0.3 }):Play()
							end
						end)
					end
				end)
			else
				-- spent: the far one calls once, searching... and nothing answers it. The glow dims out.
				call(0.25, tuning.MORAL_HUM_SPEED * 0.82, 1.2)
				TweenService:Create(glowLight, TweenInfo.new(0.8), { Brightness = 0.7 }):Play()
				task.delay(3.4, function()
					if farGlow.Parent then
						TweenService:Create(glowLight, TweenInfo.new(2.4), { Brightness = 0 }):Play()
						TweenService:Create(farGlow, TweenInfo.new(2.4), { Transparency = 0.9 }):Play()
					end
				end)
			end
		end)
	end

	gate.goZone.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player and not h.done then
			h.done = true
			ctx.clear() -- through the door again: a fresh descent
		end
	end)
	return h
end

function Ending.onPlayerEnter(h, ctx, player)
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.lookAt(h.spawn, h.spawn + Vector3.new(1, 0, 0))) -- face the door (+X), not a blank wall
	end
	ctx.send(player, { kind = "objective", text = "THE DOOR WAITS. DESCEND AGAIN — OR DON'T." })
	h.playAftermath()
end

function Ending.update(h, dt)
	h.accum += dt
	if h.accum < h.ctx.tuning.CHECK_INTERVAL then
		return
	end
	local step = h.accum
	h.accum = 0
	BuildKit.grindDoorUpdate(h.gate, step, h.ctx.tuning.DOOR_OPEN_DIST, h.ctx.tuning.DOOR_OPEN_SECONDS)
end

return Ending
