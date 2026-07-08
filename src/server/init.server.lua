-- Project 001 MVP bootstrap: lobby -> encounter one -> ending hall -> back to lobby. Server-authoritative:
-- every observation, log entry, objective, and door state is computed here. The one remote is
-- server->client UI only; the client sends nothing.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))
local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local MapLayout = require(script.MapLayout)
local Blockout = require(script.Blockout)
local SessionLog = require(script.SessionLog)
local WitnessService = require(script.WitnessService)
local DossierService = require(script.DossierService)
local NotesService = require(script.NotesService)

print(
	("[Project001][Server] booted — v%d.%d.%d (%s)"):format(
		version.major,
		version.minor,
		version.patch,
		version.stage
	)
)

local OBJECTIVE_LOBBY = "ENTER."
local OBJECTIVE_START = "FIND THE WAY OUT."
local OBJECTIVE_RECORD = "THE DOOR WANTS THE COMPLETE RECORD."
local OBJECTIVE_READ = "FIND YOUR FILE. READ IT."
local OBJECTIVE_LEAVE = "THE DOOR IS OPEN. LEAVE."
local DOOR_REFUSAL = "THE RECORD IS INCOMPLETE.\nIT IS STILL WRITING YOU."
local LOCKED_DOOR_LINE = "NOT YET."

local uiRemote = Instance.new("RemoteEvent")
uiRemote.Name = "SliceUI"
uiRemote.Parent = ReplicatedStorage

local world = Blockout.build(MapLayout, tuning)
WitnessService.init(world, MapLayout, SessionLog, tuning)
DossierService.init(MapLayout, SessionLog, tuning)
NotesService.init(SessionLog)

local states = {} -- [userId] = per-player tracking state
local dossierRead = {} -- [userId] = true once their record has been opened and held

local function stateFor(player)
	local state = states[player.UserId]
	if not state then
		state = {
			room = nil,
			entered = false,
			sampleTimer = 0,
			stillTime = 0,
			pauseAnchor = nil,
			lastPosition = nil,
			won = false,
			reading = false,
		}
		states[player.UserId] = state
	end
	return state
end

local function sendObjective(player, text)
	uiRemote:FireClient(player, { kind = "objective", text = text })
end

local function fullReset(player)
	SessionLog.reset(player)
	WitnessService.resetWorld()
	states[player.UserId] = nil
	dossierRead[player.UserId] = nil
	local character = player.Character
	if character and character.PrimaryPart then
		character:PivotTo(CFrame.new(0, 3.5, 0))
	end
	sendObjective(player, OBJECTIVE_LOBBY)
end

world.doorPrompt.Triggered:Connect(function(player)
	if dossierRead[player.UserId] then
		return
	end
	world.doorSound:Play()
	uiRemote:FireClient(player, { kind = "note", text = DOOR_REFUSAL })
	sendObjective(player, OBJECTIVE_RECORD)
end)

-- reading the record is the exit condition: the payload goes to the client, and after the reading
-- window the door at the far end unseals
world.boardPrompt.Triggered:Connect(function(player)
	local state = stateFor(player)
	if state.reading or dossierRead[player.UserId] then
		return
	end
	state.reading = true
	uiRemote:FireClient(player, { kind = "record", data = DossierService.buildPayload(player) })
	task.delay(tuning.RECORD_OPEN_SECONDS, function()
		if not player.Parent then
			return
		end
		dossierRead[player.UserId] = true
		stateFor(player).reading = false
		Blockout.openDoor(world)
		sendObjective(player, OBJECTIVE_LEAVE)
	end)
end)

for noteId, note in world.notes do
	note.prompt.Triggered:Connect(function(player)
		uiRemote:FireClient(player, { kind = "note", text = NotesService.textFor(player, noteId) })
	end)
end

for _, lockedDoor in world.lockedDoors do
	lockedDoor.prompt.Triggered:Connect(function(player)
		uiRemote:FireClient(player, { kind = "note", text = LOCKED_DOOR_LINE })
	end)
end

local resetDebounce = {}
world.resetPad.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = character and Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	if resetDebounce[player.UserId] and os.clock() - resetDebounce[player.UserId] < 3 then
		return
	end
	resetDebounce[player.UserId] = os.clock()
	fullReset(player)
end)

world.winPad.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = character and Players:GetPlayerFromCharacter(character)
	if not player then
		return
	end
	local state = stateFor(player)
	if state.won or not dossierRead[player.UserId] then
		return
	end
	state.won = true
	local log = SessionLog.get(player)
	local entries = 0
	for _, count in log.entryCounts do
		entries += count
	end
	local still = 0
	for _, pause in log.pauses do
		still += pause.duration
	end
	uiRemote:FireClient(player, {
		kind = "endcard",
		lines = {
			"YOU LEFT.",
			"IT KEPT THE NOTES.",
			string.format(
				"SUBJECT %04d — ENTRIES %d · STOOD %ds · CORRECTIONS %d",
				(player.UserId % 8999) + 1000,
				entries,
				math.floor(still),
				log.reorients
			),
		},
	})
	task.delay(tuning.ENDCARD_SECONDS, function()
		if player.Parent then
			fullReset(player)
		end
	end)
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.delay(2, function()
			if player.Parent then
				sendObjective(player, OBJECTIVE_LOBBY)
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	SessionLog.reset(player)
	states[player.UserId] = nil
	dossierRead[player.UserId] = nil
	resetDebounce[player.UserId] = nil
end)

WitnessService.startScratchLoop(function(fromPosition)
	local nearest = math.huge
	for _, player in Players:GetPlayers() do
		local root = player.Character and player.Character.PrimaryPart
		if root then
			nearest = math.min(nearest, (root.Position - fromPosition).Magnitude)
		end
	end
	return nearest
end)

local function processPlayer(player, dt, now)
	local character = player.Character
	local root = character and character.PrimaryPart
	if not root then
		return
	end
	local state = stateFor(player)
	local position = root.Position

	-- room transitions drive the click/tick/objective beats
	local room = MapLayout.roomAt(position.X, position.Z)
	local roomId = room and room.id or nil
	local previousId = state.room and state.room.id or nil
	if roomId ~= previousId then
		state.room = room
		if room then
			WitnessService.onEntry(player, room, position, character, now)
			if not state.entered and room.id == "R1" then
				state.entered = true
				sendObjective(player, OBJECTIVE_START)
			elseif room.id == "ANNEX" and not dossierRead[player.UserId] then
				sendObjective(player, OBJECTIVE_READ)
			end
		end
	end

	-- route sampling + pause detection
	state.sampleTimer += dt
	if state.sampleTimer >= tuning.SAMPLE_INTERVAL then
		local interval = state.sampleTimer
		state.sampleTimer = 0
		SessionLog.addSample(player, position.X, position.Z, tuning.MAX_SAMPLES)
		if state.lastPosition then
			local speed = (position - state.lastPosition).Magnitude / interval
			if speed < tuning.PAUSE_SPEED then
				state.stillTime += interval
				state.pauseAnchor = state.pauseAnchor or position
			else
				if state.stillTime >= tuning.PAUSE_MIN_SECONDS and state.pauseAnchor then
					local anchor = state.pauseAnchor
					local pauseRoom = MapLayout.roomAt(anchor.X, anchor.Z)
					SessionLog.addPause(player, anchor.X, anchor.Z, state.stillTime, pauseRoom and pauseRoom.id)
				end
				state.stillTime = 0
				state.pauseAnchor = nil
			end
		end
		state.lastPosition = position
	end

	WitnessService.watchablesCheck(player, character, position, now)
end

local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < tuning.CHECK_INTERVAL then
		return
	end
	local step = accumulator
	accumulator = 0
	local now = os.clock()
	for _, player in Players:GetPlayers() do
		processPlayer(player, step, now)
	end
end)
