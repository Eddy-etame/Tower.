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

-- SHIP B — THE LIGHT IS THE THREAD.
-- Project Bible: "Every completed encounter changes how the player approaches the next."
-- ONE battery for the whole descent: it drains in EVERY room, recharges slowly, and is wiped only when the
-- loop restarts at the Beginning. Each room therefore begins with less light than the last, so difficulty
-- escalates on its own and Encounter IV's choice is EARNED (your own light is nearly gone by then).
-- Deliberately within-descent only: no upgrades, no meta, nothing carried between runs — the Bible excludes
-- "large progression systems". This is a resource under judgment, never power.
local flashOn, flashAt = {}, {} -- live client-reported light state (NOT session: it dies with the run)
local drainPaused = false -- a stage may pause the drain during a frozen window (rules card / caught screen)
local lightAccum = 0

-- the client's cone starts ENABLED (Flashlight.client: `local enabled = true`) and reports once on spawn.
-- If that first report is ever missed, nil must read as ON — otherwise the player would silently burn no
-- battery while their light is visibly shining, and the Watcher could never be frozen.
local function lightIsOn(uid)
	return flashOn[uid] ~= false
end

local function batteryOf(uid)
	if session.battery == nil then
		session.battery = {}
	end
	local b = session.battery[uid]
	if b == nil then
		b = 1
		session.battery[uid] = b
	end
	return b
end

-- surviving a room earns a BREATH of light back (SHIP B stays demanding, never a dead end)
local function refundAll(amount)
	for _, p in Players:GetPlayers() do
		local uid = p.UserId
		session.battery[uid] = math.min(1, batteryOf(uid) + (amount or 0))
	end
end

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
		-- who can currently FREEZE (light on AND charged) — the Watcher reads this
		lighting = function()
			local m = {}
			for _, p in Players:GetPlayers() do
				local uid = p.UserId
				m[uid] = lightIsOn(uid) and batteryOf(uid) > tuning.BATTERY_MIN
			end
			return m
		end,
		-- pause the drain while the player cannot act (fair-learning: never charge them for a frozen window)
		pauseDrain = function(v)
			drainPaused = v and true or false
		end,
		-- a breath between rooms: safe chambers hand a little light back, so the descent is survivable
		refund = refundAll,
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
	-- SHIP B: the light is NOT refilled on stage entry any more — it is the thread through the whole descent.
	-- Push the CURRENT level so the bar is truthful the instant the room loads; the heartbeat keeps it live.
	if flashlightRemote then
		flashlightRemote:FireClient(player, {
			managed = true,
			level = batteryOf(player.UserId),
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
	drainPaused = false -- never carry a stage's frozen-window pause into the next room
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

-- the plain next room in the list (the loop wraps at the end: the Ending returns you to the Beginning)
local function linearNext()
	local nxt = current + 1
	if nxt > #stages then
		nxt = 1
	end
	return nxt
end

local function indexOfName(name)
	for i, st in stages do
		if st.name == name then
			return i
		end
	end
	return nil
end

-- BRANCHING ROUTER (Floor 2's dilemma rooms: the choice you made BUILDS the next room).
-- A stage may declare `Stage.next` as: a stage NAME (string), an index (number), or a function(session)
-- returning either. Absent = the linear next, so Floor 1 is completely unchanged.
-- INVARIANT: this can never strand the descent — every failure path falls back to the linear next and says
-- so loudly, because a player stuck in a dead room is the worst outcome this codebase can produce.
local function resolveNext()
	local decl = active and active.next
	if decl == nil then
		return linearNext()
	end
	if type(decl) == "function" then
		local ok, res = pcall(decl, session)
		if not ok then
			warn("[GameService] stage '" .. tostring(active.name) .. "' next() errored: " .. tostring(res))
			return linearNext()
		end
		decl = res
	end
	if type(decl) == "string" then
		local i = indexOfName(decl)
		if i then
			return i
		end
		warn("[GameService] stage '" .. tostring(active.name) .. "' routed to unknown stage '" .. decl .. "'")
		return linearNext()
	end
	if type(decl) == "number" and stages[decl] then
		return decl
	end
	warn("[GameService] stage '" .. tostring(active.name) .. "' declared an unusable next; going linear")
	return linearNext()
end

function GameService.advance(gen)
	if gen ~= nil and gen ~= generation then
		return -- a stale clear() from an already-torn-down stage; ignore it
	end
	refundAll(tuning.BATTERY_ROOM_REFUND) -- you survived a room: take a breath of light with you
	GameService.startStage(resolveNext())
end

function GameService.init(stageList, sliceTuning, remote, flashRemote)
	stages = stageList
	tuning = sliceTuning
	uiRemote = remote
	flashlightRemote = flashRemote

	-- ONE global handler for the client's light on/off report (was per-stage, so the economy only existed in
	-- Encounter I). Validates type and coalesces redundant same-value spam, never dropping a real change.
	flashlightRemote.OnServerEvent:Connect(function(player, on)
		if typeof(on) ~= "boolean" then
			return
		end
		local uid, now = player.UserId, os.clock()
		if flashOn[uid] == on and now - (flashAt[uid] or 0) < tuning.FLASH_MIN_INTERVAL then
			return
		end
		flashAt[uid] = now
		flashOn[uid] = on
	end)

	RunService.Heartbeat:Connect(function(dt)
		-- the descent's light economy, driven in EVERY room at the shared tick
		lightAccum += dt
		if lightAccum >= tuning.CHECK_INTERVAL then
			local step = lightAccum
			lightAccum = 0
			local suppressed = active ~= nil and active.suppressFlashlight == true
			for _, p in Players:GetPlayers() do
				local uid = p.UserId
				local b = batteryOf(uid)
				if not drainPaused and not suppressed then
					if lightIsOn(uid) then
						b = math.max(0, b - tuning.BATTERY_DRAIN * step)
					else
						b = math.min(1, b + tuning.BATTERY_RECHARGE * step)
					end
					session.battery[uid] = b
				end
				flashlightRemote:FireClient(p, { managed = true, level = b, disabled = suppressed })
			end
		end
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
