-- Project 001 MVP — "The Watcher". One dark room, one threat, one stated objective, one rule.
-- Server-authoritative: the Watcher's freeze/advance, the catch, the lever, and the door are all decided here.
-- One remote (server -> client) drives UI only; the client renders + requests, never decides.
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

local OBJ_LEVER = "PULL THE LEVER. OPEN THE DOOR."
local OBJ_LEAVE = "THE DOOR IS OPEN. GET OUT."

local uiRemote = Instance.new("RemoteEvent")
uiRemote.Name = "MvpUI"
uiRemote.Parent = ReplicatedStorage

local arena = Arena.build(tuning)
local watcher = Threat.build(arena.folder)

local leverThrown = false
local holdUntil = os.clock() + tuning.RESET_PAUSE

local function send(player, payload)
	uiRemote:FireClient(player, payload)
end

local function beginRun(player)
	local char = player.Character
	if char and char.PrimaryPart then
		char:PivotTo(CFrame.new(arena.entrance))
	end
	send(player, { kind = "title", title = "THE WATCHER" })
	send(player, { kind = "objective", text = leverThrown and OBJ_LEAVE or OBJ_LEVER })
end

local function resetRun()
	leverThrown = false
	Arena.reset(arena)
	Threat.reset(watcher)
	holdUntil = os.clock() + tuning.RESET_PAUSE
end

arena.leverPrompt.Triggered:Connect(function()
	if leverThrown then
		return
	end
	leverThrown = true
	Arena.throwLever(arena)
	Arena.openDoor(arena)
	for _, p in Players:GetPlayers() do
		send(p, { kind = "objective", text = OBJ_LEAVE })
	end
end)

arena.doorTouch.Touched:Connect(function(hit)
	local player = Players:GetPlayerFromCharacter(hit.Parent)
	if not player or not leverThrown then
		return
	end
	send(player, { kind = "escaped" })
	task.delay(tuning.ESCAPED_SECONDS, function()
		if player.Parent then
			resetRun()
			beginRun(player)
		end
	end)
end)

local function onCaught(player)
	send(player, { kind = "caught" })
	task.delay(tuning.CAUGHT_SECONDS, function()
		if player.Parent then
			resetRun()
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
		return -- fair hold at run start / after a catch
	end
	local caught = Threat.step(watcher, step, Players:GetPlayers(), tuning)
	if caught and not caughtCooldown[caught.UserId] then
		caughtCooldown[caught.UserId] = true
		holdUntil = os.clock() + tuning.RESET_PAUSE + tuning.CAUGHT_SECONDS
		onCaught(caught)
		task.delay(tuning.CAUGHT_SECONDS + 0.5, function()
			caughtCooldown[caught.UserId] = nil
		end)
	end

	-- danger signal: closeness of the Watcher drives the red edge vignette (feel, don't read)
	local watcherPos = watcher.root.Position
	for _, p in Players:GetPlayers() do
		local root = p.Character and p.Character.PrimaryPart
		if root then
			local d = (root.Position - watcherPos).Magnitude
			local level = math.clamp(1 - (d - tuning.CATCH_DISTANCE) / 26, 0, 1)
			send(p, { kind = "danger", level = level })
		end
	end
end)

Players.PlayerRemoving:Connect(function(player)
	caughtCooldown[player.UserId] = nil
end)
