-- Builds the per-player dossier PAYLOAD from the session log; the client renders it fullscreen.
-- Multiplayer-correct by construction: every player reads their own record (a shared SurfaceGui could
-- only ever show one player's session — playtest 3 structural fix). Every mark is forensically true.

local DossierService = {}

local layout, SessionLog, tuning

function DossierService.init(mapLayout, sessionLog, sliceTuning)
	layout = mapLayout
	SessionLog = sessionLog
	tuning = sliceTuning
end

function DossierService.buildPayload(player)
	local log = SessionLog.get(player)

	local rooms = {}
	for _, room in layout.rooms do
		table.insert(rooms, {
			minX = room.minX,
			maxX = room.maxX,
			minZ = room.minZ,
			maxZ = room.maxZ,
			relay = room.relay,
		})
	end

	local route = {}
	local samples = log.samples
	local step = math.max(1, math.ceil(#samples / tuning.MAX_ROUTE_POINTS))
	for index = 1, #samples, step do
		table.insert(route, { x = samples[index].x, z = samples[index].z })
	end

	local entries = {}
	for index, entry in log.entries do
		if index > tuning.MAX_ENTRY_MARKS then
			break
		end
		table.insert(entries, { x = entry.x, z = entry.z, n = entry.n })
	end

	local tallies = {}
	for _, room in layout.rooms do
		if room.relay then
			table.insert(tallies, { label = room.label, count = log.entryCounts[room.id] or 0 })
		end
	end

	local sortedPauses = table.clone(log.pauses)
	table.sort(sortedPauses, function(a, b)
		return a.duration > b.duration
	end)
	local pauses = {}
	for index, pause in sortedPauses do
		if index > tuning.MAX_PAUSE_LINES then
			break
		end
		local room = pause.roomId and layout.roomById(pause.roomId)
		table.insert(pauses, {
			label = room and room.label or "THE CORRIDOR",
			seconds = math.floor(pause.duration),
		})
	end

	return {
		subject = (player.UserId % 8999) + 1000,
		bounds = layout.bounds,
		rooms = rooms,
		route = route,
		entries = entries,
		tallies = tallies,
		pauses = pauses,
		corrections = log.reorients,
		liveLine = tuning.LIVE_LINE,
	}
end

return DossierService
