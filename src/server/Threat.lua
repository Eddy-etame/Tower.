-- The Watcher — SERVER BRAIN. The server owns exactly ONE invisible, anchored LogicRoot: its position, whether
-- it is frozen (observed+lit) or advancing, and the catch. Everything the freeze/catch measure is this root, so
-- it is unexploitable — the client never decides whether the Watcher is frozen. The VISIBLE body lives only on
-- the client (WatcherRig + Watcher.client.lua), following this root; nothing here is a body part, so there is
-- provably nothing for a client to spoof into the observation math.
--
-- The rule, enforced here and never lied about (Trust pillar): while a player has it in view + line of sight +
-- close enough for their light to reach, it cannot move; the instant that breaks, it advances. The client reads
-- the WatcherState attribute (idle/frozen/grace/advancing/surge) ONE-WAY to drive the alive-layer and teach the
-- rule wordlessly (it breathes/gazes while advancing, snaps taut-still the instant lit).
local CollectionService = game:GetService("CollectionService")

local Threat = {}

local SPAWN = Vector3.new(46, 0, 12) -- starts deep in the room, off the direct entrance->objective line
local TAG = "WatcherLogicRoot"

function Threat.build(parentFolder)
	local root = Instance.new("Part")
	root.Name = "WatcherLogicRoot"
	root.Size = Vector3.new(2.4, 0.2, 2.4)
	root.CFrame = CFrame.new(SPAWN + Vector3.new(0, 0.2, 0))
	root.Anchored = true
	root.Locked = true
	root.CanCollide = false
	root.CanQuery = false -- never blocks its own observation ray
	root.Transparency = 1
	root:SetAttribute("WatcherState", "idle") -- client reads this to drive the alive-layer
	root:SetAttribute("Boldness", 0) -- = breakers restored; the client can let it breathe harder as it grows bolder
	root:SetAttribute("Snap", 0) -- bumped on build/reset so the client hard-snaps instead of sliding across the room
	root.Parent = parentFolder
	CollectionService:AddTag(root, TAG)
	return { root = root, spawn = CFrame.new(SPAWN + Vector3.new(0, 0.2, 0)) }
end

-- the Watcher's spatial move sound: attached to the (true) LogicRoot, plays ONLY while advancing, silent while
-- frozen. The fair-fear tell (2026 watch) — the ear hears it closing behind you with your light pointed away.
-- It rides the TRUE position (not the smoothed visual) so the sound never lies about where the danger is.
function Threat.attachSound(handle, tuning)
	local s = Instance.new("Sound")
	s.SoundId = tuning.WATCHER_MOVE_SOUND
	s.PlaybackSpeed = tuning.WATCHER_MOVE_SPEED
	s.Volume = tuning.WATCHER_MOVE_VOLUME
	s.Looped = true
	s.RollOffMode = Enum.RollOffMode.InverseTapered
	s.RollOffMinDistance = 8
	s.RollOffMaxDistance = 70
	s.Parent = handle.root
	handle.moveSound = s
end

local function setMoving(handle, moving)
	if not handle.moveSound or handle.wasMoving == moving then
		return
	end
	handle.wasMoving = moving
	if moving then
		handle.moveSound:Play()
	else
		handle.moveSound:Stop()
	end
end

-- edge-guarded: write the state attribute only when it changes, so the client's alive-layer transitions fire
-- once and we never spam replication at 10Hz
local function setState(handle, state)
	if handle._state ~= state then
		handle._state = state
		handle.root:SetAttribute("WatcherState", state)
	end
end

local function observedBy(character, threatPos, tuning)
	local head = character:FindFirstChild("Head")
	local hrp = character.PrimaryPart
	if not head or not hrp then
		return false
	end
	local to = threatPos - head.Position
	local dist = to.Magnitude
	if dist > tuning.OBSERVE_RANGE then
		return false
	end
	-- use the head look (first person faces camera; third person faces move/camera dir) as the gaze proxy
	if head.CFrame.LookVector:Dot(to.Unit) < tuning.VIEW_DOT then
		return false
	end
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }
	local hit = workspace:Raycast(head.Position, to, params)
	-- the LogicRoot is CanQuery=false and there is no visible body on the server, so a CLEAR ray (hit == nil)
	-- means nothing but the Watcher is between eye and it = observed = frozen; any hit is world geometry
	-- occluding it (a pillar, a wall) = not observed
	return hit == nil
end

-- returns the player it catches this step, or nil. breakersDone escalates its speed (the tension curve).
-- lighting[userId] = the player is effectively lighting it (flashlight on AND charged) — only then can they
-- freeze it; a dead flashlight cannot hold it (the light-rationing anti-camp).
function Threat.step(handle, dt, players, tuning, breakersDone, lighting)
	local pos = handle.root.Position
	local aim = pos + Vector3.new(0, 3, 0) -- body-center, so "looking at it" reads reliably
	local speed = tuning.ADVANCE_SPEED + (breakersDone or 0) * tuning.ADVANCE_SPEED_PER_BREAKER
	local surging = handle.surgeUntil ~= nil and os.clock() < handle.surgeUntil
	if surging then
		speed = speed * tuning.SURGE_MULT -- the power-restored lunge (still freezable; the door is open)
	end
	lighting = lighting or {}

	if handle._boldness ~= breakersDone then
		handle._boldness = breakersDone
		handle.root:SetAttribute("Boldness", breakersDone or 0)
	end

	-- frozen if ANY living player is both LIGHTING it and observing it
	for _, player in players do
		local char = player.Character
		if char and char.PrimaryPart and lighting[player.UserId] and observedBy(char, aim, tuning) then
			setMoving(handle, false) -- frozen: cut to silence (the audio teaches the rule)
			setState(handle, "frozen")
			handle.unlitFor = 0
			return nil
		end
	end

	-- not observed. GRACE window: the move sound starts AT ONCE (the telegraph), but it does not gain ground
	-- for a beat — so a momentary look-away is survivable and every death is one the player heard coming (fair
	-- on mobile, where camera drag is slow). Only after grace does it actually advance.
	setMoving(handle, true)
	handle.unlitFor = (handle.unlitFor or 0) + dt
	if handle.unlitFor < tuning.GRACE_SECONDS then
		setState(handle, "grace") -- waking, telegraphed (the client leans it forward), not yet closing
		return nil
	end

	-- advance toward the nearest player STILL INSIDE THE ROOM (x <= 64: past the door they are safe,
	-- the Watcher never leaves the room, so it can never catch someone who already escaped)
	local target, best
	for _, player in players do
		local char = player.Character
		local root = char and char.PrimaryPart
		if root and root.Position.X <= 64 then
			local d = (root.Position - pos).Magnitude
			if not best or d < best then
				best = d
				target = root
			end
		end
	end
	if not target then
		setMoving(handle, false)
		setState(handle, "idle")
		return nil
	end

	if best <= tuning.CATCH_DISTANCE then
		return Threat.playerOf(players, target)
	end

	setState(handle, surging and "surge" or "advancing")
	local dir = Vector3.new(target.Position.X - pos.X, 0, target.Position.Z - pos.Z)
	if dir.Magnitude > 0.1 then
		dir = dir.Unit
		local newPos = pos + dir * speed * dt
		-- move the authoritative root only; the client smoothly follows it (no PivotTo — there is no body here)
		handle.root.CFrame = CFrame.lookAt(
			Vector3.new(newPos.X, pos.Y, newPos.Z),
			Vector3.new(target.Position.X, pos.Y, target.Position.Z)
		)
	end
	return nil
end

function Threat.playerOf(players, root)
	for _, player in players do
		if player.Character and player.Character.PrimaryPart == root then
			return player
		end
	end
	return nil
end

-- the power-restored lunge: for a short window the Watcher moves faster (Threat.step reads surgeUntil)
function Threat.surge(handle, tuning)
	handle.surgeUntil = os.clock() + tuning.SURGE_SECONDS
end

function Threat.reset(handle)
	setMoving(handle, false)
	handle.unlitFor = 0
	handle.surgeUntil = nil
	handle.root.CFrame = handle.spawn
	setState(handle, "idle")
	-- bump the Snap token so clients hard-snap the visual to spawn instead of lerping the body across the room
	handle.root:SetAttribute("Snap", (handle.root:GetAttribute("Snap") or 0) + 1)
end

return Threat
