-- The notes are the session log speaking back: every line is generated from what THIS player actually did,
-- because the encounter's whole promise is that the evidence is real. N4 is the trail to the record.

local NotesService = {}

local SessionLog

function NotesService.init(sessionLog)
	SessionLog = sessionLog
end

local function totalEntries(log)
	local total = 0
	for _, count in log.entryCounts do
		total += count
	end
	return total
end

local function totalStillSeconds(log)
	local total = 0
	for _, pause in log.pauses do
		total += pause.duration
	end
	return math.floor(total)
end

function NotesService.textFor(player, noteId)
	local log = SessionLog.get(player)
	if noteId == "N1" then
		return string.format("SUBJECT HAS ENTERED ROOMS %d TIMES.\nEACH ONE IS WRITTEN DOWN.", totalEntries(log))
	elseif noteId == "N2" then
		local still = totalStillSeconds(log)
		if still <= 0 then
			return "SUBJECT HAS NOT STOOD STILL YET.\nSUBJECT WILL."
		end
		return string.format("SUBJECT HAS STOOD STILL FOR %d SECONDS SO FAR.\nWE COUNTED.", still)
	elseif noteId == "N3" then
		if log.reorients <= 0 then
			return "NOTHING HAS NEEDED CORRECTING YET.\nKEEP GOING."
		end
		return string.format("THE FURNITURE HAS BEEN CORRECTED %d TIMES BEHIND SUBJECT.", log.reorients)
	end
	return "THE COMPLETE RECORD IS KEPT\nBEHIND THE QUIET ROOM."
end

return NotesService
