-- Silent Witness slice bootstrap. Server-authoritative by construction: every observation, log entry, and
-- dossier mark is computed here; the client renders and requests, nothing more.
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

print(
	("[Project001][Server] booted — v%d.%d.%d (%s)"):format(
		version.major,
		version.minor,
		version.patch,
		version.stage
	)
)

local world = Blockout.build(MapLayout, tuning)
WitnessService.init(world, MapLayout, SessionLog, tuning)
DossierService.init(world.board, MapLayout, SessionLog, tuning)

local states = {} -- [userId] = per-player tracking state

local function stateFor(player)
	local state = states[player.UserId]
	if not state then
		state = { room = nil, sampleTimer = 0, stillTime = 0, pauseAnchor = nil, lastPosition = nil }
		states[player.UserId] = state
	end
	return state
end

local function fullReset(player)
	SessionLog.reset(player)
	DossierService.reset(player)
	WitnessService.resetWorld()
	states[player.UserId] = nil
	local character = player.Character
	if character and character.PrimaryPart then
		character:PivotTo(CFrame.new(0, 3.5, 0))
	end
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

Players.PlayerRemoving:Connect(function(player)
	SessionLog.reset(player)
	DossierService.reset(player)
	states[player.UserId] = nil
	resetDebounce[player.UserId] = nil
end)

local function processPlayer(player, dt, now)
	local character = player.Character
	local root = character and character.PrimaryPart
	if not root then
		return
	end
	local state = stateFor(player)
	local position = root.Position

	-- room transitions drive the click/tick/dossier beats
	local room = MapLayout.roomAt(position.X, position.Z)
	local roomId = room and room.id or nil
	local previousId = state.room and state.room.id or nil
	if roomId ~= previousId then
		state.room = room
		if room then
			WitnessService.onEntry(player, room, position)
			if room.id == "ANNEX" then
				DossierService.generate(player)
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

	WitnessService.chairsCheck(player, character, position, now)
	DossierService.update(player, character, dt)
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
