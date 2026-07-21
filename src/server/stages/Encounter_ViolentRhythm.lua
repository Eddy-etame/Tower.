-- Encounter II — The Violent Rhythm. The gallery breathes on a FIXED period: a SAFE window to move, a WARNING
-- (lamps cascade from the far origin + an inhale rises), then the SURGE — the open floor is lethal and the raised
-- green MARKS are safe islands. The rule: be on a mark when it surges; cross mark-to-mark to the door. Speed never
-- saves you (position + timing do). Server-authoritative schedule; miss a window and you wait one cycle, never a
-- life (bus-timetable law); swept sends you back to your furthest secured mark (no corpse-runs).
local Players = game:GetService("Players")
local Gallery = require(script.Parent.Parent.Gallery)

local Stage = {}
Stage.name = "ViolentRhythm"
Stage.title = "ENCOUNTER II — THE VIOLENT RHYTHM"
Stage.mood = { ambient = { 0.17, 0.15, 0.12 }, fog = { 0.1, 0.085, 0.06 }, saturation = -0.15 } -- machine amber; the surge red cuts through it

local RULES = {
	{ t = "THE VIOLENT RHYTHM", y = 0.3, s = 50 },
	{ t = "THE GALLERY BREATHES ON A BEAT.", y = 0.44, s = 30 },
	{ t = "WHEN IT SURGES, THE OPEN FLOOR KILLS.", y = 0.51, s = 30 },
	{ t = "STAND ON A GREEN MARK.", y = 0.61, s = 34, c = { 70, 220, 110 } },
	{ t = "CROSS TO THE DOOR. RUNNING WON'T SAVE YOU.", y = 0.71, s = 24, c = { 200, 60, 60 } },
	{ t = "MOVE ON THE CALM. STAND ON THE SURGE.", y = 0.82, s = 20, c = { 150, 143, 128 } },
}

local function markAt(g, pos, radius)
	for i, m in g.marks do
		local dx, dz = pos.X - m.pos.X, pos.Z - m.pos.Z
		-- SQUARE test so the whole visible green plate is safe (a circle left the diagonal corners lethal)
		if math.abs(dx) <= radius and math.abs(dz) <= radius then
			return i
		end
	end
	return nil
end

function Stage.build(ctx)
	local tuning = ctx.tuning
	local gallery = Gallery.build(tuning, ctx.folder)

	local h = {
		gallery = gallery,
		ctx = ctx,
		spawn = gallery.entranceSpawn,
		cycleT = 0,
		accum = 0,
		phase = "safe",
		graceUntil = os.clock() + tuning.RHYTHM_START_GRACE, -- witness one FULL breath before it can sweep you
		taught = {}, -- [userId] onboarded (per-player, so a co-op joiner still gets the card; survives respawn)
		escaped = {},
		lastMark = {}, -- [userId] = furthest mark index secured (forward respawn)
		lastDanger = {}, -- [userId] = last danger level sent (change-gate the vignette remote)
	}

	gallery.doorTouch.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if not player or h.escaped[player.UserId] then
			return
		end
		h.escaped[player.UserId] = true
		ctx.send(player, { kind = "danger", level = 0 }) -- clear the vignette + stale objective in the safe chamber
		ctx.send(player, { kind = "objective", text = "" })
		ctx.send(player, { kind = "banner", text = "YOU CROSSED IT." })
		task.delay(tuning.ESCAPED_SECONDS, function()
			if player.Parent then
				ctx.clear() -- the door leads onward
			end
		end)
	end)

	return h
end

function Stage.onPlayerEnter(h, ctx, player)
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.lookAt(h.gallery.entranceSpawn, h.gallery.entranceSpawn + Vector3.new(1, 0, 0)))
	end
	local uid = player.UserId
	h.escaped[uid] = nil -- re-arm the exit for a rejoining player
	h.lastMark[uid] = h.lastMark[uid] or 0 -- preserve furthest secured mark across respawn/reset
	if not h.taught[uid] then
		h.taught[uid] = true
		ctx.send(player, { kind = "rules", lines = RULES })
	end
	ctx.send(player, { kind = "objective", text = "CROSS THE GALLERY — STAND ON A MARK WHEN IT SURGES." })
end

function Stage.update(h, dt)
	local tuning = h.ctx.tuning
	-- run the schedule at 10Hz (not every Heartbeat) so the lamp/vignette/sweep work doesn't 60Hz-spam remotes;
	-- cycleT still advances by the exact accumulated time, so the surge timing stays precise
	h.accum += dt
	if h.accum < tuning.CHECK_INTERVAL then
		return
	end
	local step = math.min(h.accum, tuning.RHYTHM_WARN) -- one server hitch can't skip the whole WARN telegraph
	h.accum = 0
	local g = h.gallery
	local SAFE, WARN, SURGE = tuning.RHYTHM_SAFE, tuning.RHYTHM_WARN, tuning.RHYTHM_SURGE

	-- advance the breath and derive the phase
	h.cycleT += step
	if h.cycleT >= tuning.RHYTHM_PERIOD then
		h.cycleT -= tuning.RHYTHM_PERIOD
	end
	local phase, p
	if h.cycleT < SAFE then
		phase, p = "safe", h.cycleT / SAFE
	elseif h.cycleT < SAFE + WARN then
		phase, p = "warn", (h.cycleT - SAFE) / WARN
	else
		phase, p = "surge", (h.cycleT - SAFE - WARN) / SURGE
	end

	-- phase-edge events
	if phase ~= h.phase then
		if phase == "warn" then
			Gallery.playInhale(g)
		elseif phase == "surge" then
			Gallery.setSurge(g, true)
			h.ctx.broadcast({ kind = "kick", n = 0.45 }) -- the gallery slams; every camera in the room feels it
		elseif phase == "safe" then
			Gallery.setSurge(g, false)
		end
		h.phase = phase
	end
	Gallery.setLamps(g, phase, p)
	Gallery.updateSweep(g, phase, p) -- the witness beat: debris torn down the lane, the crate on the mark untouched

	-- sweep + progress + danger vignette, per player
	local live = os.clock() >= h.graceUntil
	for _, pl in Players:GetPlayers() do
		local root = pl.Character and pl.Character.PrimaryPart
		if root and not h.escaped[pl.UserId] then
			local uid = pl.UserId
			local pos = root.Position
			local inGallery = pos.X >= g.galleryMinX and pos.X <= g.galleryMaxX
			local onMark = markAt(g, pos, tuning.RHYTHM_MARK_RADIUS)
			if onMark then
				h.lastMark[uid] = math.max(h.lastMark[uid] or 0, onMark) -- secure forward progress
			end

			-- SURGE: the open floor kills. Continuous through the surge window so you can't step off after the edge
			-- (and can still dive onto a mark to survive). Swept => forward-respawn to your furthest mark.
			if phase == "surge" and live and inGallery and not onMark then
				local mi = h.lastMark[uid]
				local target = (mi and mi > 0) and g.marks[mi].pos or g.entranceSpawn
				root.CFrame = CFrame.new(target + Vector3.new(0, 3, 0))
				h.ctx.send(pl, { kind = "banner", text = "SWEPT." })
			end

			-- danger vignette: calm on the mezzanine/safe, ramps with the countdown, spikes on the surge
			local level = 0
			if inGallery then
				if phase == "warn" then
					level = p * 0.6
				elseif phase == "surge" then
					level = 0.85
				end
			end
			if math.abs(level - (h.lastDanger[uid] or -1)) > 0.02 then -- change-gate: no 10Hz same-value spam
				h.lastDanger[uid] = level
				h.ctx.send(pl, { kind = "danger", level = level })
			end
		end
	end
end

return Stage
