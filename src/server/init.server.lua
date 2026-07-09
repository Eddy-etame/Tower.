-- Project 001 MVP — "The Watcher". One dark room, one threat, one rule (frozen in your light, advancing the
-- instant it leaves), and a real objective: restore three breakers to power the door, then escape into the
-- safe chamber. Server-authoritative: freeze/advance/catch, breakers, door, escape, and replay are all here.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local version = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Version"))
local tuning = require(ReplicatedStorage.Shared.SliceTuning)
local Arena = require(script.Arena)
local Threat = require(script.Threat)

print(
	("[Project001][Server] booted — v%d.%d.%d (%s)"):format(
		version.major,
		version.minor,
		version.patch,
		version.stage
	)
)

local uiRemote = Instance.new("RemoteEvent")
uiRemote.Name = "MvpUI"
uiRemote.Parent = ReplicatedStorage

local arena = Arena.build(tuning)
local watcher = Threat.build(arena.folder)
Threat.attachSound(watcher, tuning)

local powered = false
local escaped = {} -- [userId] = true once out of the room (safe; no catch, no re-death)
local holdUntil = os.clock() + tuning.RULES_SECONDS

local function send(player, payload)
	uiRemote:FireClient(player, payload)
end

local function objectiveText()
	if powered then
		return "THE DOOR IS OPEN. GET OUT."
	end
	return ("RESTORE THE POWER — %d / 3"):format(Arena.activeCount(arena))
end

local function broadcastObjective()
	for _, p in Players:GetPlayers() do
		send(p, { kind = "objective", text = objectiveText() })
	end
end

local function beginRun(player)
	escaped[player.UserId] = nil
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.new(arena.entrance))
	end
	holdUntil = os.clock() + tuning.RULES_SECONDS -- the Watcher freezes while the rules are on screen
	send(player, { kind = "rules" })
	send(player, { kind = "objective", text = objectiveText() })
end

local function resetWorld()
	powered = false
	Arena.reset(arena)
	Threat.reset(watcher)
	holdUntil = os.clock() + tuning.RULES_SECONDS
end

for index, breaker in arena.breakers do
	breaker.prompt.Triggered:Connect(function()
		if powered or not Arena.restoreBreaker(arena, index) then
			return
		end
		if Arena.activeCount(arena) >= #arena.breakers then
			powered = true
			Arena.openDoor(arena)
		end
		broadcastObjective()
	end)
end

arena.doorTouch.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player or not powered or escaped[player.UserId] then
		return
	end
	escaped[player.UserId] = true
	arena.escapeSound:Play()
	send(player, { kind = "escaped" })
	send(player, { kind = "objective", text = "YOU'RE OUT. STEP ON THE PAD TO GO AGAIN." })
end)

local replayDebounce = 0
arena.replayPad.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player or os.clock() - replayDebounce < 2 then
		return
	end
	replayDebounce = os.clock()
	resetWorld()
	for _, p in Players:GetPlayers() do
		beginRun(p)
	end
end)

local function onCaught(player)
	send(player, { kind = "caught" })
	task.delay(tuning.CAUGHT_SECONDS, function()
		if player.Parent then
			resetWorld()
			beginRun(player)
		end
	end)
end

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		task.delay(1.5, function()
			if player.Parent then
				beginRun(player)
			end
		end)
	end)
end)

Players.PlayerRemoving:Connect(function(player)
	escaped[player.UserId] = nil
end)

local caughtCooldown = {}
local accumulator = 0
RunService.Heartbeat:Connect(function(dt)
	accumulator += dt
	if accumulator < tuning.CHECK_INTERVAL then
		return
	end
	local step = accumulator
	accumulator = 0
	if os.clock() < holdUntil then
		return
	end
	local caught = Threat.step(watcher, step, Players:GetPlayers(), tuning, Arena.activeCount(arena))
	if caught and not caughtCooldown[caught.UserId] and not escaped[caught.UserId] then
		caughtCooldown[caught.UserId] = true
		holdUntil = os.clock() + tuning.RULES_SECONDS + tuning.CAUGHT_SECONDS
		onCaught(caught)
		task.delay(tuning.CAUGHT_SECONDS + 0.5, function()
			caughtCooldown[caught.UserId] = nil
		end)
	end

	-- danger signal drives the red edge vignette (feel, don't read) — only while still in the room
	local watcherPos = watcher.root.Position
	for _, p in Players:GetPlayers() do
		local root = p.Character and p.Character.PrimaryPart
		if root then
			local level = 0
			if root.Position.X <= Arena.ROOM_MAX_X and not escaped[p.UserId] then
				local d = (root.Position - watcherPos).Magnitude
				level = math.clamp(1 - (d - tuning.CATCH_DISTANCE) / 26, 0, 1)
			end
			send(p, { kind = "danger", level = level })
		end
	end
end)
