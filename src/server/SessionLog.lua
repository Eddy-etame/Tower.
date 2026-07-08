-- The server-side session record that powers the dossier. Everything the annex "knows" comes from here —
-- real logged behavior only, this session only, no account data, no player-authored content (design law §13).

local SessionLog = {}

local logs = {}

local function ensure(player)
	local log = logs[player.UserId]
	if not log then
		log = {
			samples = {}, -- { x, z, t }
			entries = {}, -- { room = id, x, z, t, n }
			entryCounts = {}, -- [roomId] = count
			pauses = {}, -- { x, z, duration, roomId }
			reorients = 0,
			startClock = os.clock(),
		}
		logs[player.UserId] = log
	end
	return log
end

function SessionLog.addSample(player, x, z, maxSamples)
	local log = ensure(player)
	if #log.samples >= maxSamples then
		return
	end
	table.insert(log.samples, { x = x, z = z, t = os.clock() - log.startClock })
end

function SessionLog.addEntry(player, roomId, x, z)
	local log = ensure(player)
	log.entryCounts[roomId] = (log.entryCounts[roomId] or 0) + 1
	table.insert(log.entries, { room = roomId, x = x, z = z, n = #log.entries + 1 })
end

function SessionLog.addPause(player, x, z, duration, roomId)
	local log = ensure(player)
	table.insert(log.pauses, { x = x, z = z, duration = duration, roomId = roomId })
end

function SessionLog.addReorient(player)
	local log = ensure(player)
	log.reorients += 1
end

function SessionLog.get(player)
	return ensure(player)
end

function SessionLog.reset(player)
	logs[player.UserId] = nil
end

return SessionLog
