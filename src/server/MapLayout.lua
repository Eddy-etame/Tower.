-- Blockout geometry for the Silent Witness slice, fully data-driven so the whole map is version-controlled.
-- Linear chain R1..R4 plus the annex hidden off ROOM THREE — the one room that never clicks (the annex-pointer).

local WALL_HEIGHT = 10
local DOOR_HALF_WIDTH = 2.5
local DOOR_HEIGHT = 8

local MapLayout = {}

MapLayout.WALL_HEIGHT = WALL_HEIGHT
MapLayout.DOOR_HEIGHT = DOOR_HEIGHT

-- Interior bounds per room. relay = whether entering this room clicks (R3 and the annex stay silent by design).
MapLayout.rooms = {
	{ id = "R1", label = "ROOM ONE", minX = 14, maxX = 38, minZ = -8, maxZ = 8, relay = true },
	{ id = "R2", label = "ROOM TWO", minX = 38, maxX = 62, minZ = -8, maxZ = 8, relay = true },
	{ id = "R3", label = "ROOM THREE", minX = 62, maxX = 86, minZ = -8, maxZ = 8, relay = false },
	{ id = "R4", label = "ROOM FOUR", minX = 86, maxX = 110, minZ = -8, maxZ = 8, relay = true },
	{ id = "ANNEX", label = "ANNEX", minX = 64, maxX = 84, minZ = -25, maxZ = -9, relay = false },
}

-- Wall segments. axis "x": wall plane at fixed X spanning Z from..to; axis "z": plane at fixed Z spanning X.
-- A gap is a doorway (full-height opening with a lintel above DOOR_HEIGHT).
MapLayout.walls = {
	{ axis = "z", fixed = 8.5, from = 13, to = 111 }, -- long north wall
	{ axis = "z", fixed = -8.5, from = 13, to = 62 }, -- south wall, rooms one and two
	{ axis = "z", fixed = -8.5, from = 62, to = 86, gap = { from = 78, to = 83 } }, -- room three south, annex doorway
	{ axis = "z", fixed = -8.5, from = 86, to = 111 }, -- south wall, room four
	{ axis = "x", fixed = 13.5, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } }, -- entrance
	{ axis = "x", fixed = 38, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 62, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 86, from = -9, to = 9, gap = { from = -DOOR_HALF_WIDTH, to = DOOR_HALF_WIDTH } },
	{ axis = "x", fixed = 110.5, from = -9, to = 9 }, -- east dead end
	-- the fin: blocks the direct sightline into the annex doorway, so finding it takes looking
	{ axis = "z", fixed = -6, from = 76, to = 84 },
	-- annex shell
	{ axis = "x", fixed = 63.5, from = -25, to = -9 },
	{ axis = "x", fixed = 84.5, from = -25, to = -9 },
	{ axis = "z", fixed = -25.5, from = 63, to = 85 },
}

-- Doorway reference points (chairs reorient to face the doorway nearest the player — the toward-you signature).
MapLayout.doorways = {
	{ x = 13.5, z = 0 },
	{ x = 38, z = 0 },
	{ x = 62, z = 0 },
	{ x = 86, z = 0 },
	{ x = 80.5, z = -8.5 },
}

-- One watchable chair per clicking room; ROOM THREE's deviance is absence.
MapLayout.chairs = {
	{ room = "R1", x = 26, z = -4, faceX = 26, faceZ = 8 },
	{ room = "R2", x = 50, z = 3, faceX = 38, faceZ = 0 },
	{ room = "R4", x = 98, z = -3, faceX = 110, faceZ = 0 },
}

MapLayout.board = { x = 74, y = 4.2, z = -24.4, width = 12, height = 5.5 }
MapLayout.desk = { x = 74, z = -22.3 }
MapLayout.resetPad = { x = 82.5, z = -23.5 }

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
