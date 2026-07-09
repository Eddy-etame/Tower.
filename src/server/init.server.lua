-- Project 001 — Encounter One: The Silent Witness. Lobby -> the watch -> the file -> the way out -> lobby.
-- Server-authoritative: every observation, the room's escalation, the file, and the door are decided here.
-- One remote, server->client, UI only; the client sends nothing.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))
local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local MapLayout = require(script.MapLayout)
local Blockout = require(script.Blockout)
local SessionLog = require(script.SessionLog)
local BehaviorProfile = require(script.BehaviorProfile)
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

local OBJ_LOBBY = "ENTER."
local OBJ_START = "FIND THE WAY OUT."
local OBJ_RECORD = "IT KEEPS ITS FILE BEHIND THE QUIET ROOM."
local OBJ_HOLD = "DON'T MOVE."
local OBJ_LEAVE = "THE DOOR IS OPEN. LEAVE."
local DOOR_REFUSAL = "THE RECORD IS INCOMPLETE.\nIT IS STILL WRITING YOU."

local uiRemote = Instance.new("RemoteEvent")
uiRemote.Name = "SliceUI"
uiRemote.Parent = ReplicatedStorage

local world = Blockout.build(MapLayout, tuning)
WitnessService.init(world, SessionLog, tuning)
local scratchPoint = world.scratchPart.Position

local states = {}
local fileComplete = {} -- [userId] = true after the annex reveal finishes

local function stateFor(player)
	local state = states[player.UserId]
	if not state then
		state = { room = nil, committed = false, revealed = false, won = false, lastPos = nil, sampleTimer = 0 }
		states[player.UserId] = state
	end
	return state
end

local function objective(player, text)
	uiRemote:FireClient(player, { kind = "objective", text = text })
end

DossierService.init(world, tuning, SessionLog, function(player)
	fileComplete[player.UserId] = true
	Blockout.openDoor(world)
	objective(player, OBJ_LEAVE)
end)

local function fullReset(player)
	SessionLog.reset(player)
	BehaviorProfile.reset(player)
	DossierService.resetReveal()
	WitnessService.resetWorld()
	states[player.UserId] = nil
	fileComplete[player.UserId] = nil
	local character = player.Character
	if character and character.PrimaryPart then
		character:PivotTo(CFrame.new(0, 3.5, 0))
	end
	objective(player, OBJ_LOBBY)
end

world.doorPrompt.Triggered:Connect(function(player)
	if fileComplete[player.UserId] then
		return
	end
	world.doorSound:Play()
	uiRemote:FireClient(player, { kind = "note", text = DOOR_REFUSAL })
	objective(player, OBJ_RECORD)
end)

for noteId, note in world.notes do
	note.prompt.Triggered:Connect(function(player)
		uiRemote:FireClient(player, { kind = "note", text = NotesService.textFor(player, noteId) })
	end)
end

for _, lockedDoor in world.lockedDoors do
	lockedDoor.prompt.Triggered:Connect(function(player)
		uiRemote:FireClient(player, { kind = "note", text = "NOT YET." })
	end)
end

local resetDebounce = {}
world.resetPad.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
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
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player then
		return
	end
	local state = stateFor(player)
	if state.won or not fileComplete[player.UserId] then
		return
	end
	state.won = true
	uiRemote:FireClient(player, {
		kind = "endcard",
		lines = {
			"YOU LEFT.",
			"IT KEPT EVERYTHING IT WROTE.",
			BehaviorProfile.closingLine(),
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
				objective(player, OBJ_LOBBY)
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	SessionLog.reset(player)
	BehaviorProfile.reset(player)
	states[player.UserId] = nil
	fileComplete[player.UserId] = nil
	resetDebounce[player.UserId] = nil
end)

local function processPlayer(player, dt)
	local character = player.Character
	local root = character and character.PrimaryPart
	if not root then
		return
	end
	local state = stateFor(player)
	local position = root.Position
	local now = os.clock()

	local speed = 0
	if state.lastPos then
		speed = (position - state.lastPos).Magnitude / dt
	end
	state.lastPos = position

	-- Act I: the entrance light dies once the subject commits into room one
	if not state.committed and position.X > tuning.COMMIT_X then
		state.committed = true
		Blockout.killEntranceLamp(world)
	end

	-- room transitions: click/dip + objective beats + the annex reveal
	local room = MapLayout.roomAt(position.X, position.Z)
	local roomId = room and room.id or nil
	if roomId ~= (state.room and state.room.id) then
		state.room = room
		if room then
			WitnessService.onEntry(player, room, position)
			if room.id == "R1" and not state.startedObjective then
				state.startedObjective = true
				objective(player, OBJ_START)
			elseif room.id == "ANNEX" and not state.revealed then
				state.revealed = true
				objective(player, OBJ_HOLD)
				DossierService.reveal(player)
			end
		end
	end

	-- Act III: the writing follows the footsteps near the quiet room
	local nearScratch = (position - scratchPoint).Magnitude < tuning.SCRATCH_RANGE
	WitnessService.setScratch(nearScratch and speed > tuning.PAUSE_SPEED)

	-- the observer tracks you every tick
	WitnessService.watchablesCheck(player, character, position, now)

	-- behaviour sampling feeds the file
	state.sampleTimer += dt
	if state.sampleTimer >= tuning.SAMPLE_INTERVAL then
		state.sampleTimer = 0
		SessionLog.addSample(player, position.X, position.Z, tuning.MAX_SAMPLES)
		BehaviorProfile.observe(player, position, root.CFrame.LookVector, speed, MapLayout.doorways, tuning)
	end
end

local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < tuning.CHECK_INTERVAL then
		return
	end
	local step = accumulator
	accumulator = 0
	for _, player in Players:GetPlayers() do
		processPlayer(player, step)
	end
end)
