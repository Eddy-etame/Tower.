-- The watching itself: entry clicks with a light-dip and visible tick twins; watchable furniture that
-- reorients toward the player's likely return door strictly while unobserved (never seen moving, always
-- seen HAVING moved); a guaranteed first change the moment the player leaves their first room; and the
-- note-taker's scratch behind ROOM THREE's wall. R3 never clicks: its silence is the annex-pointer.

local Blockout = require(script.Parent.Blockout)

local WitnessService = {}

local world, layout, SessionLog, tuning
local scratchRunning = false

function WitnessService.init(worldHandles, mapLayout, sessionLog, sliceTuning)
	world = worldHandles
	layout = mapLayout
	SessionLog = sessionLog
	tuning = sliceTuning
end

local function tallyText(count)
	local groups = math.floor(count / 5)
	return string.rep("||||| ", groups) .. string.rep("|", count % 5)
end

local function dipLight(roomHandle)
	task.spawn(function()
		local light = roomHandle.light
		local original = light.Brightness
		for _ = 1, 2 do
			light.Brightness = original * tuning.CLICK_DIP
			task.wait(tuning.CLICK_DIP_SECONDS)
			light.Brightness = original
			task.wait(tuning.CLICK_DIP_SECONDS)
		end
	end)
end

local function isObserved(anchorPosition, exclude, character)
	local head = character:FindFirstChild("Head")
	if not head then
		return false
	end
	local origin = anchorPosition + Vector3.new(0, 2, 0)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { exclude, character }
	local hit = workspace:Raycast(origin, head.Position - origin, params)
	-- clear line from object to head = observed; any wall between = safe to move
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

local function turnWatchable(watchable, playerPosition, now, force)
	if not force and (watchable.lastTurn or 0) + tuning.CHAIR_COOLDOWN > now then
		return false
	end
	local doorway = nearestDoorway(playerPosition)
	if watchable.kind == "chair" then
		local seatPosition = watchable.model.PrimaryPart.Position
		local desired = Vector3.new(doorway.x, seatPosition.Y, doorway.z) - seatPosition
		desired = Vector3.new(desired.X, 0, desired.Z)
		if desired.Magnitude < 1 then
			return false
		end
		desired = desired.Unit
		local flatLook = watchable.model:GetPivot().LookVector
		flatLook = Vector3.new(flatLook.X, 0, flatLook.Z)
		if not force and flatLook.Magnitude > 0 then
			local angle = math.deg(math.acos(math.clamp(flatLook.Unit:Dot(desired), -1, 1)))
			if angle < tuning.CHAIR_MIN_ANGLE then
				return false
			end
		end
		watchable.model:PivotTo(CFrame.lookAt(seatPosition, seatPosition + desired))
	else
		-- paintings tilt and slide a step toward the door side: readable at silhouette scale
		local side = doorway.x < watchable.part.Position.X and -1 or 1
		if watchable.tiltSide == side and not force then
			return false
		end
		watchable.tiltSide = side
		watchable.part.CFrame = watchable.base
			* CFrame.new(side * tuning.PAINTING_SLIDE, 0, 0)
			* CFrame.Angles(0, 0, math.rad(side * tuning.PAINTING_TILT_DEG))
	end
	watchable.lastTurn = now
	return true
end

local function anchorOf(watchable)
	return watchable.model and watchable.model.PrimaryPart.Position or watchable.part.Position
end

function WitnessService.onEntry(player, room, position, character, now)
	SessionLog.addEntry(player, room.id, position.X, position.Z)
	local handle = world.rooms[room.id]

	-- guaranteed first change: the room the player just left rearranges the moment they're gone,
	-- so the first re-entry anywhere always finds the toward-you signature (playtest 1 fix)
	local previousId = SessionLog.get(player).lastRoomLeft
	if previousId and previousId ~= room.id then
		for _, watchable in world.watchables do
			if watchable.room == previousId and not watchable.firstTurnDone then
				if not isObserved(anchorOf(watchable), watchable.model or watchable.part, character) then
					if turnWatchable(watchable, position, now, true) then
						watchable.firstTurnDone = true
						Blockout.addSmudge(world, watchable)
						SessionLog.addReorient(player)
					end
				end
			end
		end
	end
	SessionLog.get(player).lastRoomLeft = room.id

	if not handle or not room.relay then
		return
	end
	if handle.clickSound then
		handle.clickSound:Play()
	end
	dipLight(handle)
	if handle.tickLabel then
		handle.tickLabel.Text = tallyText(SessionLog.get(player).entryCounts[room.id] or 0)
	end
end

function WitnessService.watchablesCheck(player, character, position, now)
	local playerRoom = layout.roomAt(position.X, position.Z)
	for _, watchable in world.watchables do
		if playerRoom and playerRoom.id == watchable.room then
			continue -- never move in the player's own room
		end
		if isObserved(anchorOf(watchable), watchable.model or watchable.part, character) then
			continue
		end
		if turnWatchable(watchable, position, now, false) then
			Blockout.addSmudge(world, watchable)
			SessionLog.addReorient(player)
		end
	end
end

-- The note-taker at work: an irregular dry scratching behind room three's wall, only when someone is close
-- enough for it to matter. STUB audio reuses the click asset pitched far down (Rule 2: labeled placeholder).
function WitnessService.startScratchLoop(getNearestDistance)
	if scratchRunning then
		return
	end
	scratchRunning = true
	task.spawn(function()
		local rng = Random.new()
		while true do
			task.wait(rng:NextNumber(tuning.SCRATCH_GAP_MIN, tuning.SCRATCH_GAP_MAX))
			if getNearestDistance(world.scratchPart.Position) <= tuning.SCRATCH_RANGE then
				world.scratchSound.PlaybackSpeed = tuning.SCRATCH_SPEED * rng:NextNumber(0.9, 1.15)
				world.scratchSound:Play()
			end
		end
	end)
end

function WitnessService.resetWorld()
	Blockout.clearSmudges(world)
	for _, watchable in world.watchables do
		watchable.lastTurn = nil
		watchable.firstTurnDone = nil
		watchable.tiltSide = nil
		if watchable.kind == "chair" then
			watchable.model:PivotTo(watchable.base)
		else
			watchable.part.CFrame = watchable.base
		end
	end
	for _, roomHandle in world.rooms do
		if roomHandle.tickLabel then
			roomHandle.tickLabel.Text = ""
		end
	end
	Blockout.closeDoor(world)
end

return WitnessService
