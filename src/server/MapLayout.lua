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
		id = "EXITCHAMBER",
		minX = 85,
		maxX = 96,
		minZ = -25,
		maxZ = -9,
		floorColor = Color3.fromRGB(96, 96, 100),
		lightColor = Color3.fromRGB(214, 214, 224),
	},
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
	{ axis = "z", fixed = -8.5, from = 86, to = 111, gap = { from = 90, to = 94 } }, -- room four south, exit chamber doorway
	{ axis = "x", fixed = 13.5, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } }, -- entrance
	{ axis = "x", fixed = 38, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 62, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 86, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 110.5, from = -9, to = 9 }, -- east dead end
	-- the fin: blocks the direct sightline into the annex doorway, so finding it takes looking
	{ axis = "z", fixed = -6, from = 76, to = 84 },
	-- annex shell
	{ axis = "x", fixed = 63.5, from = -25, to = -9 },
	{ axis = "x", fixed = 84.5, from = -25, to = -19 }, -- lower east wall...
	{ axis = "x", fixed = 84.5, from = -15, to = -9 }, -- ...upper east wall; the -19..-15 gap is the sealed exit
	{ axis = "z", fixed = -25.5, from = 63, to = 97 }, -- south wall, annex + exit chamber
	-- exit chamber shell
	{ axis = "x", fixed = 96.5, from = -25, to = -9 },
}

-- The sealed panel covering the annex->exit gap until the dossier's live line has been read.
MapLayout.seal = { x = 84.5, zFrom = -19, zTo = -15 }

-- Doorway reference points (watchables reorient toward the doorway nearest the player).
MapLayout.doorways = {
	{ x = 13.5, z = 0 },
	{ x = 38, z = 0 },
	{ x = 62, z = 0 },
	{ x = 86, z = 0 },
	{ x = 80.5, z = -8.5 },
	{ x = 92, z = -8.5 },
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
-- Light leak under the fin gap: the pull toward the hidden doorway.
MapLayout.leak = { x = 80.5, z = -8.5, width = 5 }

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
