-- The Watcher — SERVER BRAIN. The server owns exactly ONE invisible, anchored LogicRoot: its position, whether
-- it is frozen (observed+lit) or advancing, and the catch. Everything the freeze/catch measure is this root, so
-- the VISIBLE body lives only on the client (WatcherRig + Watcher.client.lua), following this root, so a client
-- CANNOT move/hide/spoof the body to dodge the catch (there is no Watcher body on the server to spoof).
-- KNOWN CEILING (bounded, not a win-grant): the freeze reads the PLAYER's own client-owned Head look as the gaze
-- proxy, which an executor could aim at the Watcher while running/looking away to hold it frozen — but freezing
-- never advances the stage (only server-validated breaker restores + the door do) and the server drains the
-- battery, so it only makes the game EASIER for that one cheater.
--
-- The rule, enforced here and never lied about (Trust pillar): while a player has it in view + line of sight +
-- close enough for their light to reach, it cannot move; the instant that breaks, it advances. The client reads
-- the WatcherState attribute (idle/frozen/grace/advancing/surge) ONE-WAY to drive the alive-layer and teach the
-- rule wordlessly (it breathes/gazes while advancing, snaps taut-still the instant lit).
local CollectionService = game:GetService("CollectionService")

local Threat = {}

local SPAWN = Vector3.new(46, 0, 12) -- starts deep in the room, off the direct entrance->objective line
-- face the throat/entrance (-X, where players arrive) at rest, so the common approach needs little reorient
local SPAWN_CF = CFrame.lookAt(SPAWN + Vector3.new(0, 0.2, 0), SPAWN + Vector3.new(-1, 0.2, 12))
local TAG = "WatcherLogicRoot"

function Threat.build(parentFolder)
	local root = Instance.new("Part")
	root.Name = "WatcherLogicRoot"
	root.Size = Vector3.new(2.4, 0.2, 2.4)
	root.CFrame = SPAWN_CF
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
	return { root = root, spawn = SPAWN_CF }
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

local function observedBy(character, threatPos, tuning, excludeChars)
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
	-- exclude ALL player characters (not just the observer) so only STATIC geometry can occlude — a teammate
	-- standing on the line of sight must not block the freeze
	params.FilterDescendantsInstances = excludeChars
	local hit = workspace:Raycast(head.Position, to, params)
	-- the LogicRoot is CanQuery=false and there is no visible body on the server, so a CLEAR ray (hit == nil)
	-- means only a wall/pillar could occlude it; clear = observed = frozen
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

	-- every player character occludes the observation ray for EVERYONE unless excluded; build the exclude set once
	local exclude = {}
	for _, player in players do
		if player.Character then
			exclude[#exclude + 1] = player.Character
		end
	end

	-- frozen if ANY living player is both LIGHTING it and observing it
	for _, player in players do
		local char = player.Character
		if char and char.PrimaryPart and lighting[player.UserId] and observedBy(char, aim, tuning, exclude) then
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

	-- advance toward the nearest player STILL INSIDE THE ROOM (past the door = out of range and safe;
	-- the Watcher never leaves the room, so it can never catch someone who already escaped)
	local target, best
	for _, player in players do
		local char = player.Character
		local root = char and char.PrimaryPart
		if root and root.Position.X <= tuning.ROOM_MAX_X then
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
		setMoving(handle, false) -- caught: cut the move loop + stop broadcasting "advancing" under the caught screen
		setState(handle, "idle")
		return Threat.playerOf(players, target)
	end

	-- surge lunge: the FIRST time it actually starts closing during a surge it COILS — gathers in place for a beat
	-- (the client leans it back), THEN releases. Driven by one server state ("coil") so the visual can't desync
	-- into a back-leaning skid. Coils once per surge (handle.coiled), aligned to the real lunge start regardless
	-- of how long the player kept it frozen after the power blew.
	local moving = true
	if surging then
		if not handle.coiled then
			handle.coiled = true
			handle.coilUntil = os.clock() + tuning.WATCHER_COIL_SECS
		end
		if handle.coilUntil and os.clock() < handle.coilUntil then
			setState(handle, "coil")
			moving = false
		else
			setState(handle, "surge")
		end
	else
		setState(handle, "advancing")
	end
	if moving then
		local dir = Vector3.new(target.Position.X - pos.X, 0, target.Position.Z - pos.Z)
		if dir.Magnitude > 0.1 then
			dir = dir.Unit
			local newPos = pos + dir * speed * dt
			-- STAY IN THE ROOM: the root has no collision (it is a logic point, not a body), so without this it walks
			-- in a straight line THROUGH walls and out into the throat (Eddy, 2026-07-09: "the watcher moves through
			-- walls"). Clamp to the room interior — x[5,62] keeps it off the west throat mouth and the east exit
			-- wall; z[-18,18] off the side walls. It approaches within the room and can never clip out of it.
			local cx = math.clamp(newPos.X, 5, 62)
			local cz = math.clamp(newPos.Z, -18, 18)
			-- move the authoritative root only; the client smoothly follows it (no PivotTo — there is no body here)
			handle.root.CFrame =
				CFrame.lookAt(Vector3.new(cx, pos.Y, cz), Vector3.new(target.Position.X, pos.Y, target.Position.Z))
		end
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

-- the power-restored lunge: for a short window the Watcher moves faster (Threat.step reads surgeUntil). handle.coiled
-- is cleared so the next time it actually starts closing it gathers (the "coil" state) once before releasing.
function Threat.surge(handle, tuning)
	handle.surgeUntil = os.clock() + tuning.SURGE_SECONDS
	handle.coiled = false
end

function Threat.reset(handle)
	setMoving(handle, false)
	handle.unlitFor = 0
	handle.surgeUntil = nil
	handle.coiled = false
	handle.coilUntil = nil
	handle.root.CFrame = handle.spawn
	setState(handle, "idle")
	-- bump the Snap token so clients hard-snap the visual to spawn instead of lerping the body across the room
	handle.root:SetAttribute("Snap", (handle.root:GetAttribute("Snap") or 0) + 1)
end

return Threat
