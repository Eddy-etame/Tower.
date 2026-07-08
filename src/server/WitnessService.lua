-- The watching itself: entry clicks with visible doorframe ticks (twin channels, same beat — audio-sibling law),
-- and chairs that reorient toward the player's likely return door strictly while unobserved.
-- ROOM THREE never clicks: its silence is the annex-pointer, not a broken rule.

local Blockout = require(script.Parent.Blockout)

local WitnessService = {}

local world, layout, SessionLog, tuning

function WitnessService.init(worldHandles, mapLayout, sessionLog, sliceTuning)
	world = worldHandles
	layout = mapLayout
	SessionLog = sessionLog
	tuning = sliceTuning
end

local function tallyText(count)
	local groups = math.floor(count / 5)
	local remainder = count % 5
	return string.rep("||||| ", groups) .. string.rep("|", remainder)
end

function WitnessService.onEntry(player, room, position)
	SessionLog.addEntry(player, room.id, position.X, position.Z)
	local handle = world.rooms[room.id]
	if not handle or not room.relay then
		return
	end
	if handle.clickSound then
		handle.clickSound:Play()
	end
	if handle.tickLabel then
		local log = SessionLog.get(player)
		handle.tickLabel.Text = tallyText(log.entryCounts[room.id] or 0)
	end
end

local function isObservedBy(chairModel, character)
	local head = character:FindFirstChild("Head")
	if not head then
		return false
	end
	local origin = chairModel.PrimaryPart.Position + Vector3.new(0, 2, 0)
	local direction = head.Position - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { chairModel, character }
	local hit = workspace:Raycast(origin, direction, params)
	-- nothing between chair and head = a clear line of sight = observed; any wall between = safe to move
	return hit == nil
end

local function nearestDoorway(position)
	local best, bestDistance
	for _, doorway in layout.doorways do
		local distance = (Vector3.new(doorway.x, 0, doorway.z) - Vector3.new(position.X, 0, position.Z)).Magnitude
		if not bestDistance or distance < bestDistance then
			best = doorway
			bestDistance = distance
		end
	end
	return best
end

function WitnessService.chairsCheck(player, character, position, now)
	local playerRoom = layout.roomAt(position.X, position.Z)
	for roomId, chairHandle in world.chairs do
		if playerRoom and playerRoom.id == roomId then
			continue -- never move in the player's own room: never seen moving, only seen HAVING moved
		end
		if (chairHandle.lastTurn or 0) + tuning.CHAIR_COOLDOWN > now then
			continue
		end
		if isObservedBy(chairHandle.model, character) then
			continue
		end
		local doorway = nearestDoorway(position)
		local seatPosition = chairHandle.model.PrimaryPart.Position
		local target = Vector3.new(doorway.x, seatPosition.Y, doorway.z)
		local currentLook = chairHandle.model:GetPivot().LookVector
		local desired = (target - seatPosition)
		if desired.Magnitude < 1 then
			continue
		end
		desired = Vector3.new(desired.X, 0, desired.Z).Unit
		local flatLook = Vector3.new(currentLook.X, 0, currentLook.Z)
		if flatLook.Magnitude > 0 then
			local angle = math.deg(math.acos(math.clamp(flatLook.Unit:Dot(desired), -1, 1)))
			if angle < tuning.CHAIR_MIN_ANGLE then
				continue
			end
		end
		chairHandle.model:PivotTo(CFrame.lookAt(seatPosition, seatPosition + desired))
		chairHandle.lastTurn = now
		Blockout.addSmudge(world, chairHandle)
		SessionLog.addReorient(player)
	end
end

function WitnessService.resetWorld()
	Blockout.clearSmudges(world)
	for _, chairDef in layout.chairs do
		local chairHandle = world.chairs[chairDef.room]
		chairHandle.lastTurn = nil
		chairHandle.model:PivotTo(
			CFrame.lookAt(Vector3.new(chairDef.x, 1.2, chairDef.z), Vector3.new(chairDef.faceX, 1.2, chairDef.faceZ))
		)
	end
	for _, roomHandle in world.rooms do
		if roomHandle.tickLabel then
			roomHandle.tickLabel.Text = ""
		end
	end
end

return WitnessService
