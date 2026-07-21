-- The top-level game FSM: one playable experience — Beginning -> four Encounters -> Ending -> (loop).
-- One stage is active at a time; GameService builds it, teleports the player in, runs its per-tick update,
-- and advances when the stage calls ctx.clear(). Adding an encounter = adding one module to the ordered list
-- (v1-spec RoomService pattern; Rule 21). The Bible's "what's behind the next door" flow, made real.
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LightingService = game:GetService("Lighting")

local GameService = {}

local stages, tuning, uiRemote, flashlightRemote
local current, active, activeHandles, activeFolder, activeCtx
local generation = 0 -- bumped each stage build; a stale delayed clear() from a torn-down stage is ignored
local session = {} -- cross-stage state for ONE descent (e.g. the moral choice); wiped when the loop restarts

local applyMood -- forward-declared (defined below); ctx closures call it late-bound

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
		setMood = function(mood)
			applyMood(mood) -- a stage may shift the world's light mid-beat (e.g. the world darkens as a light dies)
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

-- PER-ROOM MOOD: every door opens into a different WORLD (the tower promise). A stage may declare
-- Stage.mood = { ambient={r,g,b}, fog={r,g,b}, saturation=n } (0..1 channels); absent fields fall back to
-- the base grade. Applied as a slow crossfade on stage start — the world's light changes under the entry fade.
local MOOD_BASE = { ambient = { 0.15, 0.16, 0.19 }, fog = { 0.07, 0.08, 0.1 }, saturation = -0.25 }
function applyMood(mood)
	mood = mood or {}
	local amb = mood.ambient or MOOD_BASE.ambient
	local fog = mood.fog or MOOD_BASE.fog
	local sat = mood.saturation or MOOD_BASE.saturation
	local info = TweenInfo.new(tuning.MOOD_TWEEN_SECS, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local ambient = Color3.new(amb[1], amb[2], amb[3])
	TweenService:Create(LightingService, info, {
		Ambient = ambient,
		OutdoorAmbient = ambient,
		FogColor = Color3.new(fog[1], fog[2], fog[3]),
	}):Play()
	local grade = LightingService:FindFirstChild("HorrorGrade")
	if grade then
		TweenService:Create(grade, info, { Saturation = sat }):Play()
	end
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
	applyMood(active.mood)
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
			-- fresh characters spawn on the lone StagingGround pad (far at x=-400, away from ALL stage geometry — a
			-- sealed respawn BOX once overlapped the room and walled the player in; a flat pad can never do that);
			-- a short beat for parts, then the stage teleports them in
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
