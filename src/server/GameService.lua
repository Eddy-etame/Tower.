-- The top-level game FSM: one playable experience — Beginning -> four Encounters -> Ending -> (loop).
-- One stage is active at a time; GameService builds it, teleports the player in, runs its per-tick update,
-- and advances when the stage calls ctx.clear(). Adding an encounter = adding one module to the ordered list
-- (v1-spec RoomService pattern; Rule 21). The Bible's "what's behind the next door" flow, made real.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local GameService = {}

local stages, tuning, uiRemote, flashlightRemote
local current, active, activeHandles, activeFolder, activeCtx
local generation = 0 -- bumped each stage build; a stale delayed clear() from a torn-down stage is ignored
local session = {} -- cross-stage state for ONE descent (e.g. the moral choice); wiped when the loop restarts

local function ctxFor(folder, gen)
	return {
		folder = folder,
		tuning = tuning,
		session = session,
		flashlightRemote = flashlightRemote,
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
		-- advance ONLY if this ctx belongs to the still-current stage — so two players finishing within the
		-- 5s escape window (or any stale scheduled clear) can't double-advance and skip an encounter
		clear = function()
			GameService.advance(gen)
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
	-- reset the flashlight to unmanaged/full on entering any stage; a stage that rations light (the Watcher)
	-- takes over with managed battery updates, and a stage whose fiction NEEDS the dark (the Moral Collapse —
	-- the companion must be your only light or the choice has no weight) declares suppressFlashlight
	if flashlightRemote then
		flashlightRemote:FireClient(player, {
			managed = false,
			level = 1,
			disabled = active.suppressFlashlight == true,
		})
	end
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
	generation += 1
	if index == 1 then
		table.clear(session) -- a fresh descent: the previous run's choices don't carry (only DataStore would, later)
	end
	current = index
	active = stages[index]
	activeFolder = Instance.new("Folder")
	activeFolder.Name = "Stage_" .. (active.name or tostring(index))
	activeFolder.Parent = workspace
	activeCtx = ctxFor(activeFolder, generation)
	activeHandles = active.build(activeCtx)
	for _, player in Players:GetPlayers() do
		enterPlayer(player)
	end
end

function GameService.advance(gen)
	if gen ~= nil and gen ~= generation then
		return -- a stale clear() from an already-torn-down stage; ignore it
	end
	local nxt = current + 1
	if nxt > #stages then
		nxt = 1 -- Ending loops back to the Beginning (a fresh descent)
	end
	GameService.startStage(nxt)
end

function GameService.init(stageList, sliceTuning, remote, flashRemote)
	stages = stageList
	tuning = sliceTuning
	uiRemote = remote
	flashlightRemote = flashRemote

	RunService.Heartbeat:Connect(function(dt)
		if active and active.update then
			active.update(activeHandles, dt)
		end
	end)

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function()
			-- fresh characters spawn in the sealed LandingCloset (never in stage geometry — stages get destroyed,
			-- and respawning over a destroyed stage was a void-fall); a short beat for parts, then the stage takes them
			task.delay(0.5, function()
				if player.Parent then
					enterPlayer(player)
				end
			end)
		end)
	end)

	GameService.startStage(1)
end

return GameService
