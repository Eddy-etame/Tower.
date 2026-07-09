-- The observer's read of the subject. Not counts — CHARACTERIZATION. Every line is forensically true
-- (derived from real logged behavior this session) but expressed as a profiler's judgment, so the file
-- feels like something studied you, not a pedometer. This is the violation the encounter is FOR.

local BehaviorProfile = {}

local profiles = {}

local function ensure(player)
	local p = profiles[player.UserId]
	if not p then
		p = {
			samples = 0,
			zSum = 0, -- +z = north side, -z = south side
			absZSum = 0, -- distance from centre line (wall-hugging)
			lookBack = 0, -- samples facing back the way they came
			speedSum = 0,
			hesitations = 0, -- pauses at thresholds
			lastHesitationClock = 0,
			notesRead = 0,
			sawChairTurn = false, -- set true if they were looking near a chair right after it turned
			startClock = os.clock(),
		}
		profiles[player.UserId] = p
	end
	return p
end

-- called every sample with the player's real state
function BehaviorProfile.observe(player, position, lookVector, speed, doorways, tuning)
	local p = ensure(player)
	p.samples += 1
	p.zSum += position.Z
	p.absZSum += math.abs(position.Z)
	p.speedSum += speed
	if lookVector.X < -0.35 then -- forward progress is +X; facing -X = looking back
		p.lookBack += 1
	end
	if speed < tuning.PAUSE_SPEED then
		for _, doorway in doorways do
			if math.abs(position.X - doorway.x) < 4 and math.abs(position.Z - doorway.z) < 3.5 then
				if os.clock() - p.lastHesitationClock > 2 then
					p.hesitations += 1
					p.lastHesitationClock = os.clock()
				end
				break
			end
		end
	end
end

function BehaviorProfile.noteRead(player)
	ensure(player).notesRead += 1
end

function BehaviorProfile.markSawChairTurn(player)
	ensure(player).sawChairTurn = true
end

-- a single qualitative line for a note read mid-encounter, keyed to the room's theme
function BehaviorProfile.roomLine(player, roomId)
	local p = ensure(player)
	if roomId == "R1" then
		return "SUBJECT 1041.\nOBSERVATION HAS BEGUN."
	elseif roomId == "R2" then
		if p.samples > 0 and p.absZSum / p.samples > 4.2 then
			return "SUBJECT KEEPS TO THE WALLS.\nSUBJECT DOES NOT TRUST THE OPEN."
		end
		return "IT TURNED TO FACE YOU.\nSO DID WE."
	elseif roomId == "R3" then
		if p.samples > 0 and p.lookBack / p.samples > 0.18 then
			return "SUBJECT KEEPS LOOKING BACK.\nTHERE IS NOTHING BEHIND YOU.\nYET."
		end
		return "YOU HEAR US WRITING.\nWE ARE WRITING THIS."
	end
	return "THE REST OF THE FILE\nIS KEPT BEHIND THE QUIET ROOM."
end

-- the climax: the wall of the file. 5-7 lines, all TRUE, ordered from framing -> characterization -> closer.
function BehaviorProfile.composeFile(player, sessionLog)
	local p = ensure(player)
	local log = sessionLog.get(player)
	local n = math.max(1, p.samples)
	local lines = {}

	table.insert(lines, "SUBJECT 1041 — FILE OPEN")

	-- pace read
	local avgSpeed = p.speedSum / n
	if avgSpeed > 9 then
		table.insert(lines, "Moves quickly. Nervous. Wants this over.")
	elseif avgSpeed < 4.5 then
		table.insert(lines, "Moves slowly. Careful. Looking for us.")
	else
		table.insert(lines, "Measured. Controlled. Thinks it is not afraid.")
	end

	-- spatial read
	if p.absZSum / n > 4.2 then
		table.insert(lines, "Keeps to the walls. Avoids the centre of every room.")
	elseif p.zSum / n > 2 then
		table.insert(lines, "Favours the north side. Always has.")
	elseif p.zSum / n < -2 then
		table.insert(lines, "Favours the south side. Always has.")
	end

	-- attention read
	if p.lookBack / n > 0.16 then
		table.insert(lines, "Looks back before every door. It suspects.")
	end

	-- threshold read
	if p.hesitations >= 2 then
		table.insert(lines, "Hesitates at every threshold. Good. It should.")
	end

	-- the reorientations it caused (real, from the world)
	if log.reorients > 0 then
		table.insert(lines, "Did not see us move the furniture. We moved it anyway.")
	end

	-- reading read
	if p.notesRead >= 3 then
		table.insert(lines, "Reads everything we leave. It wants to understand.")
	elseif p.notesRead == 0 then
		table.insert(lines, "Reads nothing we leave. It does not want to know.")
	end

	-- guarantee at least a few characterizations even for a fast, blank run
	if #lines < 4 then
		table.insert(lines, "Unremarkable. We keep the file anyway.")
	end

	return lines
end

function BehaviorProfile.liveLine()
	return "SUBJECT IS READING THIS NOW."
end

function BehaviorProfile.closingLine()
	return "SUBJECT LEFT. THE FILE STAYS OPEN."
end

function BehaviorProfile.reset(player)
	profiles[player.UserId] = nil
end

return BehaviorProfile
