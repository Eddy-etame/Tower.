-- Blockout geometry for the Silent Witness slice, fully data-driven so the whole map is version-controlled.
-- Linear chain R1..R4 plus the annex hidden off ROOM THREE — the one room that never clicks (the annex-pointer).
-- Iteration 2 (playtest 1: "empty rooms, no game"): spawn yard funnel, per-room identity, watchable furniture,
-- exit chamber with a sealed panel that opens after the dossier is read.

local WALL_HEIGHT = 10
local DOOR_HALF_WIDTH = 2.5
local DOOR_HEIGHT = 8

local MapLayout = {}

MapLayout.WALL_HEIGHT = WALL_HEIGHT
MapLayout.DOOR_HEIGHT = DOOR_HEIGHT

-- Interior bounds per room. relay = whether entering clicks (R3 and the annex stay silent by design).
-- Every room gets its own floor tint and light color: "every room has its own identity" (Bible).
MapLayout.rooms = {
	{
		id = "R1",
		label = "ROOM ONE",
		minX = 14,
		maxX = 38,
		minZ = -8,
		maxZ = 8,
		relay = true,
		floorColor = Color3.fromRGB(142, 134, 122),
		lightColor = Color3.fromRGB(255, 236, 205),
	},
	{
		id = "R2",
		label = "ROOM TWO",
		minX = 38,
		maxX = 62,
		minZ = -8,
		maxZ = 8,
		relay = true,
		floorColor = Color3.fromRGB(126, 138, 126),
		lightColor = Color3.fromRGB(226, 244, 214),
	},
	{
		id = "R3",
		label = "ROOM THREE",
		minX = 62,
		maxX = 86,
		minZ = -8,
		maxZ = 8,
		relay = false,
		floorColor = Color3.fromRGB(118, 126, 142),
		lightColor = Color3.fromRGB(208, 220, 248),
	},
	{
		id = "R4",
		label = "ROOM FOUR",
		minX = 86,
		maxX = 110,
		minZ = -8,
		maxZ = 8,
		relay = true,
		floorColor = Color3.fromRGB(146, 126, 122),
		lightColor = Color3.fromRGB(252, 224, 210),
	},
	{
		id = "ANNEX",
		label = "ANNEX",
		minX = 64,
		maxX = 84,
		minZ = -25,
		maxZ = -9,
		relay = false,
		floorColor = Color3.fromRGB(104, 100, 94),
		lightColor = Color3.fromRGB(255, 214, 170),
	},
}

-- Non-room built spaces (floors, ceilings, lights — no click, no tally).
MapLayout.extraSpaces = {
	{
		id = "LOBBY",
		minX = -6,
		maxX = 13,
		minZ = -8,
		maxZ = 8,
		floorColor = Color3.fromRGB(168, 164, 156),
		lightColor = Color3.fromRGB(255, 248, 235),
		noCeiling = true, -- the lobby sits under open sky; the game begins when you step inside
	},
	{
		id = "ENDHALL",
		minX = 111,
		maxX = 126,
		minZ = -7,
		maxZ = 7,
		floorColor = Color3.fromRGB(180, 176, 168),
		lightColor = Color3.fromRGB(255, 250, 240),
		noCeiling = true, -- you leave into daylight
	},
}

-- Lobby dressing: the game names itself, and the entrance is framed as the beginning.
MapLayout.title = { x = 13.2, y = 7.2, z = 0, width = 10, height = 2.6 }

-- The ending hall names what comes next: three sealed encounter doors, honestly locked.
MapLayout.lockedDoors = {
	{ label = "TWO", x = 114, z = 7.2 },
	{ label = "THREE", x = 118, z = 7.2 },
	{ label = "FOUR", x = 122, z = 7.2 },
}

-- Wall segments. axis "x": plane at fixed X spanning Z; axis "z": plane at fixed Z spanning X.
MapLayout.walls = {
	-- spawn yard funnel: the only way forward is the entrance
	{ axis = "z", fixed = 8.5, from = -6, to = 13 },
	{ axis = "z", fixed = -8.5, from = -6, to = 13 },
	{ axis = "x", fixed = -6.5, from = -9, to = 9 },
	-- main block
	{ axis = "z", fixed = 8.5, from = 13, to = 111 }, -- long north wall
	{ axis = "z", fixed = -8.5, from = 13, to = 62 }, -- south wall, rooms one and two
	{ axis = "z", fixed = -8.5, from = 62, to = 86, gap = { from = 78, to = 83 } }, -- room three south, annex doorway
	{ axis = "z", fixed = -8.5, from = 86, to = 111 }, -- south wall, room four
	{ axis = "x", fixed = 13.5, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } }, -- entrance
	{ axis = "x", fixed = 38, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 62, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 86, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	-- east wall of room four carries THE EXIT DOOR — the goal, visible from the moment you enter R4
	{ axis = "x", fixed = 110.5, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	-- the fin: breaks the direct sightline into the annex doorway WITHOUT hiding the way around it
	-- (playtest 3: the entrance must be findable — wide openings both ends, light spilling past both corners)
	{ axis = "z", fixed = -5, from = 77, to = 83 },
	-- annex shell
	{ axis = "x", fixed = 63.5, from = -25, to = -9 },
	{ axis = "x", fixed = 84.5, from = -25, to = -9 },
	{ axis = "z", fixed = -25.5, from = 63, to = 85 },
	-- ending hall shell (open sky, east end open to the win pad)
	{ axis = "z", fixed = 7.5, from = 110, to = 126 },
	{ axis = "z", fixed = -7.5, from = 110, to = 126 },
}

-- The exit door: fills the east gap until the dossier's live line has been read.
MapLayout.exitDoor = { x = 110.5, zFrom = -2.5, zTo = 2.5 }
-- Standing on this pad after the door opens completes the run.
MapLayout.winPad = { x = 123, z = 0 }

-- Doorway reference points (watchables reorient toward the doorway nearest the player).
MapLayout.doorways = {
	{ x = 13.5, z = 0 },
	{ x = 38, z = 0 },
	{ x = 62, z = 0 },
	{ x = 86, z = 0 },
	{ x = 80.5, z = -8.5 },
	{ x = 110.5, z = 0 },
}

-- Readable notes: the session log speaking back, and the trail to the record. N4 sits on the fin itself.
MapLayout.notes = {
	{ id = "N1", x = 20, z = 3, y = 3.5, yaw = 15, onWall = false },
	{ id = "N2", x = 56, z = -3, y = 3.5, yaw = -25, onWall = false },
	{ id = "N3", x = 92, z = 4, y = 3.5, yaw = 40, onWall = false },
	{ id = "N4", x = 80, z = -4.4, y = 4.6, yaw = 0, onWall = true },
}

-- Watchable furniture: reorients strictly while unobserved. ROOM THREE's deviance is absence.
MapLayout.chairs = {
	{ room = "R1", x = 26, z = -4, faceX = 26, faceZ = 8 },
	{ room = "R2", x = 50, z = 3, faceX = 38, faceZ = 0 },
	{ room = "R4", x = 98, z = -3, faceX = 110, faceZ = 0 },
}
MapLayout.paintings = {
	{ room = "R1", x = 30, z = 7.7 },
	{ room = "R2", x = 44, z = 7.7 },
	{ room = "R4", x = 104, z = 7.7 },
}
-- Static furniture for density (never moves — the contrast makes the movers readable).
MapLayout.tables = {
	{ x = 20, z = 3 },
	{ x = 56, z = -3 },
	{ x = 92, z = 4 },
}

-- The scratch source: behind room three's south wall, loudest at the annex side (the note-taker at work).
MapLayout.scratchPoint = { x = 81, y = 4, z = -8.2 }
-- Warm light spilling from the annex doorway AND around both fin corners: the pull must be visible
-- from the open room, not hidden behind its own concealment (playtest 3 fix).
MapLayout.leaks = {
	{ x = 80.5, z = -8.3, width = 5, depth = 1.6 },
	{ x = 76.4, z = -6.4, width = 1.4, depth = 3.4 },
	{ x = 83.6, z = -6.4, width = 1.4, depth = 3.4 },
}

MapLayout.board = { x = 74, y = 4.2, z = -24.4, width = 12, height = 5.5 }
MapLayout.desk = { x = 74, z = -22.3 }
MapLayout.resetPad = { x = 66, z = -23.5 }

-- World bounds for dossier map projection.
MapLayout.bounds = { minX = 13, maxX = 111, minZ = -26, maxZ = 9 }

function MapLayout.roomAt(x, z)
	for _, room in MapLayout.rooms do
		if x >= room.minX and x <= room.maxX and z >= room.minZ and z <= room.maxZ then
			return room
		end
	end
	return nil
end

function MapLayout.roomById(id)
	for _, room in MapLayout.rooms do
		if room.id == id then
			return room
		end
	end
	return nil
end

return MapLayout
