-- The top-level game FSM: one playable experience — Beginning -> four Encounters -> Ending -> (loop).
-- One stage is active at a time; GameService builds it, teleports the player in, runs its per-tick update,
-- and advances when the stage calls ctx.clear(). Adding an encounter = adding one module to the ordered list
-- (v1-spec RoomService pattern; Rule 21). The Bible's "what's behind the next door" flow, made real.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameService = {}

local stages, tuning, uiRemote
local current, active, activeHandles, activeFolder, activeCtx

local function ctxFor(folder)
	return {
		folder = folder,
		tuning = tuning,
		send = function(player, payload)
			uiRemote:FireClient(player, payload)
		end,
		broadcast = function(payload)
			for _, p in Players:GetPlayers() do
				uiRemote:FireClient(p, payload)
			end
		end,
		players = function()
			return Players:GetPlayers()
		end,
		clear = function()
			GameService.advance()
		end,
	}
end

local function enterPlayer(player)
	if not active then
		return
	end
	local char = player.Character
	if char and char.PrimaryPart and activeHandles and activeHandles.spawn then
		char:PivotTo(CFrame.new(activeHandles.spawn))
	end
	uiRemote:FireClient(player, { kind = "title", title = active.title or active.name or "" })
	if active.onPlayerEnter then
		active.onPlayerEnter(activeHandles, activeCtx, player)
	end
end

local function teardown()
	if active and active.teardown then
		active.teardown(activeHandles)
	end
	if activeFolder then
		activeFolder:Destroy()
	end
	active, activeHandles, activeFolder, activeCtx = nil, nil, nil, nil
end

function GameService.startStage(index)
	teardown()
	current = index
	active = stages[index]
	activeFolder = Instance.new("Folder")
	activeFolder.Name = "Stage_" .. (active.name or tostring(index))
	activeFolder.Parent = workspace
	activeCtx = ctxFor(activeFolder)
	activeHandles = active.build(activeCtx)
	for _, player in Players:GetPlayers() do
		enterPlayer(player)
	end
end

function GameService.advance()
	local nxt = current + 1
	if nxt > #stages then
		nxt = 1 -- Ending loops back to the Beginning (a fresh descent)
	end
	GameService.startStage(nxt)
end

function GameService.init(stageList, sliceTuning, remote)
	stages = stageList
	tuning = sliceTuning
	uiRemote = remote

	RunService.Heartbeat:Connect(function(dt)
		if active and active.update then
			active.update(activeHandles, dt)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			task.delay(1.2, function()
				if player.Parent then
					enterPlayer(player)
				end
			end)
		end)
	end)

	GameService.startStage(1)
end

return GameService
