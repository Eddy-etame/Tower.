-- The room doing something TO you — the escalation the encounter is built on:
--   Act I  (room one):   it notices you arrive — the entrance light dies behind you.
--   Act II (room two):   it tracks you — the chair turns to face you the instant you stop looking at it.
--   Act III(room three): it records you — writing behind the wall keeps pace with your footsteps.
-- "Observed" means the player is actually LOOKING at the object (in view AND clear line of sight), so the
-- turn lands the moment they look away and is discovered when they look back: never seen moving, seen having moved.

local Blockout = require(script.Parent.Blockout)

local WitnessService = {}

local world, SessionLog, tuning
local scratchActive = false

function WitnessService.init(worldHandles, sessionLog, sliceTuning)
	world = worldHandles
	SessionLog = sessionLog
	tuning = sliceTuning
	world.scratchSound.Looped = true
end

local function dipLight(roomHandle)
	task.spawn(function()
		local light = roomHandle.light
		local base = roomHandle.baseBrightness
		for _ = 1, 2 do
			light.Brightness = base * tuning.CLICK_DIP
			task.wait(tuning.CLICK_DIP_SECONDS)
			light.Brightness = base
			task.wait(tuning.CLICK_DIP_SECONDS)
		end
	end)
end

-- observed = the object is in the player's view cone AND nothing blocks the line to their head
local function isObserved(anchorPosition, exclude, character)
	local head = character:FindFirstChild("Head")
	local root = character.PrimaryPart
	if not head or not root then
		return false
	end
	local toObject = anchorPosition - head.Position
	if root.CFrame.LookVector:Dot(toObject.Unit) < tuning.VIEW_CONE_DOT then
		return false -- outside the view cone: unobserved, free to move
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { exclude, character }
	local hit = workspace:Raycast(head.Position, toObject, params)
	return hit == nil -- clear line while in view = the player is looking at it
end

local function anchorOf(watchable)
	return watchable.model and watchable.model.PrimaryPart.Position or watchable.part.Position
end

-- turn a chair to face the player directly (Act II: it tracks YOU, not a doorway)
local function facePlayer(watchable, playerPosition, now)
	if (watchable.lastTurn or 0) + tuning.CHAIR_COOLDOWN > now then
		return false
	end
	local seat = watchable.model.PrimaryPart.Position
	local desired = Vector3.new(playerPosition.X - seat.X, 0, playerPosition.Z - seat.Z)
	if desired.Magnitude < 1 then
		return false
	end
	desired = desired.Unit
	local look = watchable.model:GetPivot().LookVector
	look = Vector3.new(look.X, 0, look.Z)
	if look.Magnitude > 0 then
		local angle = math.deg(math.acos(math.clamp(look.Unit:Dot(desired), -1, 1)))
		if angle < tuning.CHAIR_MIN_ANGLE then
			return false
		end
	end
	watchable.model:PivotTo(CFrame.lookAt(seat, seat + desired))
	watchable.lastTurn = now
	return true
end

local function tiltPainting(watchable, playerPosition, now)
	if (watchable.lastTurn or 0) + tuning.CHAIR_COOLDOWN > now then
		return false
	end
	local side = playerPosition.X < watchable.part.Position.X and -1 or 1
	if watchable.tiltSide == side then
		return false
	end
	watchable.tiltSide = side
	watchable.part.CFrame = watchable.base
		* CFrame.new(side * tuning.PAINTING_SLIDE, 0, 0)
		* CFrame.Angles(0, 0, math.rad(side * tuning.PAINTING_TILT_DEG))
	watchable.lastTurn = now
	return true
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
	dipLight(handle)
end

-- every tick: watchables turn to face the player whenever the player is NOT looking at them
function WitnessService.watchablesCheck(player, character, position, now)
	for _, watchable in world.watchables do
		if isObserved(anchorOf(watchable), watchable.model or watchable.part, character) then
			continue
		end
		local turned
		if watchable.kind == "chair" then
			turned = facePlayer(watchable, position, now)
		else
			turned = tiltPainting(watchable, position, now)
		end
		if turned then
			Blockout.addSmudge(world, watchable)
			SessionLog.addReorient(player)
		end
	end
end

-- Act III: writing behind the quiet room's wall, playing only while the subject is moving nearby.
function WitnessService.setScratch(active)
	if active == scratchActive then
		return
	end
	scratchActive = active
	if active then
		world.scratchSound.PlaybackSpeed = tuning.SCRATCH_SPEED
		world.scratchSound:Play()
	else
		world.scratchSound:Stop()
	end
end

function WitnessService.resetWorld()
	Blockout.clearSmudges(world)
	Blockout.restoreEntranceLamp(world)
	Blockout.clearFile(world)
	WitnessService.setScratch(false)
	for _, watchable in world.watchables do
		watchable.lastTurn = nil
		watchable.tiltSide = nil
		if watchable.kind == "chair" then
			watchable.model:PivotTo(watchable.base)
		else
			watchable.part.CFrame = watchable.base
		end
	end
	Blockout.closeDoor(world)
end

return WitnessService
