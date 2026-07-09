-- The notes you find mid-encounter: the observer speaking to you, in character, about you. Never counts —
-- characterization (BehaviorProfile), always forensically true. Each escalates the concept: it noticed you,
-- it tracks you, it records you, and the record is kept behind the quiet room.

local BehaviorProfile = require(script.Parent.BehaviorProfile)

local NotesService = {}

function NotesService.textFor(player, noteId)
	BehaviorProfile.noteRead(player)
	-- N1..N3 live in rooms one/two/three; N4 is the trail. Map note ids to room themes.
	local roomByNote = { N1 = "R1", N2 = "R2", N3 = "R3", N4 = "ANNEX" }
	return BehaviorProfile.roomLine(player, roomByNote[noteId] or "R1")
end

return NotesService
